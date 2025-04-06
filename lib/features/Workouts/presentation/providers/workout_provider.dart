import 'dart:developer';

import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutsProvider =
    StateNotifierProvider.autoDispose<WorkoutsNotifier, ProviderStates>((ref) {
  return WorkoutsNotifier(ref.read(workoutRepo));
});

class WorkoutsNotifier extends StateNotifier<ProviderStates> {
  final WorkoutRepo _workoutRepo;

  List<WorkoutSetModel> workoutList = [];

  bool selectMode = false;

  WorkoutSetModel newWorkout = WorkoutSetModel(
    name: '',
    description: '',
    workoutItems: [],
  );

  WorkoutsNotifier(this._workoutRepo) : super(ProviderStates());

  bool createWorkoutBtnState() {
    return (!state.isLoading &&
        (workoutList.isNotEmpty || HiveManager.workoutsBox.isNotEmpty));
  }

  Future<void> createWorkoutSet() async {
    try {
      state = ProviderStates(isLoading: true);
      if (ConnectivityChecker.isOnline!) {
        // Online: Create on server and update local
        await _workoutRepo.createWorkoutSet(newWorkout);
        await HiveManager.workoutsBox.add(newWorkout);
        // Refresh the list after creating
        await getWorkoutSets();
      } else {
        debugPrint('Saving workout offline...');

        // Step 1: Add to Hive workouts box
        await HiveManager.workoutsBox.add(newWorkout);

        // Step 2: Add pending operation
        await HiveManager.addPendingOperation(PendingOperation(
          entityType: 'workout',
          operationType: SyncOperationType.create,
          workout: newWorkout,
          timestamp: DateTime.now(),
        ));

        // Step 3: Update workout list
        workoutList = HiveManager.workoutsBox.values.toList();
      }

      state = ProviderStates(isSuccess: true);
    } catch (e) {
      debugPrint('EXCEPTION in createWorkoutSet: $e');
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> deleteWorkoutSet(int workoutID, int index) async {
    try {
      if (ConnectivityChecker.isOnline!) {
        // Online: Delete from server
        _workoutRepo.deleteWorkoutSet(workoutID);
      } else {
        // Offline: Track for later sync
        await HiveManager.addPendingOperation(
          PendingOperation(
            entityType: 'workout',
            operationType: SyncOperationType.delete,
            id: workoutID,
          ),
        );
      }

      // Update UI
      workoutList.removeWhere((workout) => workout.id == workoutID);

      // Remove from Hive
      await HiveManager.workoutsBox.delete(index);

      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  void fillNewWorkout({
    String? name,
    String? description,
    List<WorkoutItemModel>? workoutItems,
  }) {
    newWorkout = newWorkout.copyWith(
      name: name,
      description: description,
      workoutItems: workoutItems,
    );
  }

  Future<void> getWorkoutSets() async {
    try {
      if (ConnectivityChecker.isOnline!) {
        // Online: Get from server and update Hive
        state = ProviderStates(isLoading: true);
        workoutList = await _workoutRepo.getWorkoutSets();
        // Update Hive with fresh data
        await HiveManager.workoutsBox.clear();
        for (var workout in workoutList) {
          await HiveManager.workoutsBox.add(workout);
        }
      } else {
        // Offline: Load from Hive
        workoutList = HiveManager.workoutsBox.values.toList();
        updateWorkoutExerciseVideoPath(workoutList);
      }

      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> reorderWorkoutsList(List<WorkoutSetModel> workouts) async {
    List<Map<String, dynamic>> reorderedWorkoutsList = workouts
        .map(
            (workout) => {"id": workout.id, "order": workouts.indexOf(workout)})
        .toList();
    try {
      if (ConnectivityChecker.isOnline!) {
        // Online: Reorder on server

        await _workoutRepo.reorderWorkoutsList(reorderedWorkoutsList);
      } else {
        // Offline: Track for later sync

        await HiveManager.addPendingOperation(PendingOperation(
          entityType: 'workout',
          operationType: SyncOperationType.reorder,
          reorderWorkoutList: reorderedWorkoutsList,
          timestamp: DateTime.now(),
        ));
      }

      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  void resetNewWorkout() {
    newWorkout = WorkoutSetModel(
      name: '',
      description: '',
      workoutItems: [],
    );
  }

  toggleSelectMode() {
    selectMode = !selectMode;
    // Clear selected items when turning off select mode
    if (!selectMode) {
      newWorkout.workoutItems!.clear();
    }
    state = ProviderStates(isSuccess: true);
  }

  Future<void> updateLastWeight(
      int workoutID, int exerciseID, num weight) async {
    try {
      if (ConnectivityChecker.isOnline!) {
        // Online: Update on server
        state = ProviderStates(isLoading: true);
        await _workoutRepo.updateLastWeight(workoutID, exerciseID, weight);
        updateLastWeightLocal(workoutID, exerciseID, weight);
      } else {
        // Offline: Track for later sync
        await HiveManager.addPendingOperation(PendingOperation(
          entityType: 'workout_weight',
          operationType: SyncOperationType.update,
          workout: workoutList.firstWhere((workout) => workout.id == workoutID),
          exerciseId: exerciseID,
          weight: weight,
        ));

        // Update local Hive data
        updateLastWeightLocal(workoutID, exerciseID, weight);
      }
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> updateWorkoutSet(WorkoutSetModel workout) async {
    try {
      if (ConnectivityChecker.isOnline!) {
        // Online: Update on server
        state = ProviderStates(isLoading: true);
        await _workoutRepo.updateWorkoutSet(workout);
        await getWorkoutSets(); // Refresh the list after Editing
      } else {
        // Offline: Update local Hive data
        int index = HiveManager.workoutsBox.values
            .toList()
            .indexWhere((element) => element.id == workout.id);

        await HiveManager.workoutsBox.putAt(index, workout);
        // Offline: Track for later sync
        await HiveManager.addPendingOperation(
          PendingOperation(
            entityType: 'workout',
            operationType: SyncOperationType.update,
            workout: workout,
          ),
        );
      }

      resetNewWorkout();
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> updateLastWeightLocal(
      int workoutID, int exerciseID, num weight) async {
    /// Updates the local record of the last weight used for a specific exercise within a workout.
    ///
    /// This method modifies the local data to reflect the most recent weight used by the user for
    /// the specified exercise in a workout session. It doesn't persist the change to remote storage.
    ///
    /// Parameters:
    /// - [workoutID]: The unique identifier of the workout containing the exercise.
    /// - [exerciseID]: The unique identifier of the exercise whose weight is being updated.
    /// - [weight]: The new weight value to be recorded for the exercise.
    ///

    int index = HiveManager.workoutsBox.values
        .toList()
        .indexWhere((element) => element.id == workoutID);
    WorkoutSetModel workout = HiveManager.workoutsBox.getAt(index)!;
    int exerciseIndex = workout.workoutItems!
        .indexWhere((element) => element.exercise.id == exerciseID);
    workout.workoutItems![exerciseIndex].lastWeight = weight;
    await HiveManager.workoutsBox.putAt(index, workout);
  }

  updateWorkoutExerciseVideoPath(List<WorkoutSetModel> workoutList) async {
    debugPrint(
        'Updating workout exercise video paths for ${workoutList.length} workouts');

    // First, create a copy of all updated workouts without modifying Hive yet
    List<WorkoutSetModel> updatedWorkouts = [];

    for (var workout in workoutList) {
      bool workoutModified = false;

      if (workout.workoutItems != null) {
        for (int i = 0; i < workout.workoutItems!.length; i++) {
          var workoutItem = workout.workoutItems![i];

          final cachedExercise =
              HiveManager.exercisesBox.get(workoutItem.exercise.id);
          if (cachedExercise != null) {
            // Only update if different from current path
            if (workoutItem.exercise.video != cachedExercise.video) {
              // Create updated workout item
              workout.workoutItems![i] = workoutItem.copyWith(
                  exercise: workoutItem.exercise.copyWith(
                      video: cachedExercise.video,
                      targetedMuscles: cachedExercise.targetedMuscles));

              workoutModified = true;
            }
          } else {
            debugPrint(
                'No cached exercise found for ID: ${workoutItem.exercise.id}');
          }
        }
      }

      if (workoutModified) {
        updatedWorkouts.add(workout);
      }
    }

    // After collecting all updates, now update Hive
    for (var updatedWorkout in updatedWorkouts) {
      int index =
          HiveManager.workoutsBox.values.toList().indexOf(updatedWorkout);
      if (index >= 0) {
        await HiveManager.workoutsBox.putAt(index, updatedWorkout);
      }
    }
  }
}

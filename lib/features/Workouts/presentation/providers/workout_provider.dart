import 'dart:developer';

import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive/hive.dart';

final workoutsProvider =
    StateNotifierProvider.autoDispose<WorkoutsNotifier, ProviderStates>((ref) {
  return WorkoutsNotifier(ref.read(workoutRepo), ref);
});

class WorkoutsNotifier extends StateNotifier<ProviderStates> {
  final WorkoutRepo _workoutRepo;
  final Ref _ref;

  List<WorkoutSetModel> workoutList = [];

  bool selectMode = false;

  WorkoutSetModel newWorkout = WorkoutSetModel(
    name: '',
    description: '',
    workoutItems: [],
  );

  WorkoutsNotifier(this._workoutRepo, this._ref) : super(ProviderStates()) {
    if (ConnectivityChecker.isOnline!) {
      // _trySync();
      // HiveManager.clearPendingOperations();
    }
  }

  // Future<void> _trySync() async {
  //   if (!ConnectivityChecker.isOnline!) return;

  //   try {
  //     _ref.read(syncingProvider.notifier).state = true;

  //     // Debug before sync
  //     debugPrint('Before sync attempt:');
  //     HiveManager.debugPendingOperations();

  //     // Make sure the pending operations box is open
  //     if (!Hive.isBoxOpen('pendingOperations')) {
  //       await Hive.openBox<PendingOperation>('pendingOperations');
  //       debugPrint('Had to reopen pendingOperations box');
  //     }

  //     final syncService = _ref.read(syncServiceProvider);
  //     await syncService.syncPendingOperations();
  //     // await getWorkoutSets(); // Refresh the list after sync
  //   } catch (e) {
  //     debugPrint('Error during sync: $e');
  //   } finally {
  //     _ref.read(syncingProvider.notifier).state = false;
  //   }
  // }

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
      }

      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> reorderWorkoutsList(List<WorkoutSetModel> workouts) async {
    try {
      List<Map<String, dynamic>> reorderedWorkoutsList = workouts
          .map((workout) =>
              {"id": workout.id, "order": workouts.indexOf(workout)})
          .toList();

      await _workoutRepo.reorderWorkoutsList(reorderedWorkoutsList);
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
      await _workoutRepo.updateLastWeight(workoutID, exerciseID, weight);
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
}

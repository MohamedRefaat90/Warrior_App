import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutsProvider =
    NotifierProvider<WorkoutsNotifier, ProviderStates>(WorkoutsNotifier.new);

class WorkoutsNotifier extends Notifier<ProviderStates> {
  late WorkoutRepo _workoutRepo;

  List<WorkoutSetModel> workoutList = [];

  bool selectMode = false;

  WorkoutSetModel newWorkout = WorkoutSetModel(
    name: '',
    description: '',
    workoutItems: [],
  );

  bool get _isOnline => ConnectivityChecker.isOnline == true;

  @override
  ProviderStates build() {
    _workoutRepo = ref.read(workoutRepo);
    return ProviderStates();
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = ProviderStates();
    }
  }

  bool createWorkoutBtnState() {
    return (!state.isLoading &&
        (workoutList.isNotEmpty || HiveManager.workoutsBox.isNotEmpty));
  }

  Future<void> createWorkoutSet() async {
    try {
      // Validate workout data
      if (newWorkout.name?.trim().isEmpty ?? true) {
        state = ProviderStates(errorMessage: 'Workout name is required');
        TalkerService.warning(
            'Attempted to create workout without name', 'WORKOUT');
        return;
      }

      if (newWorkout.workoutItems?.isEmpty ?? true) {
        state =
            ProviderStates(errorMessage: 'Please add at least one exercise');
        TalkerService.warning(
            'Attempted to create workout without exercises', 'WORKOUT');
        return;
      }

      state = ProviderStates(isLoading: true);
      final numberOfWorkouts =
          SharedPref.getInt(StorageKeys.numberOfWorkouts) ?? 0;

      if (_isOnline) {
        // Online: Create on server and update local
        await _workoutRepo.createWorkoutSet(newWorkout);
        await HiveManager.workoutsBox.add(newWorkout);

        await SharedPref.setInt(
            StorageKeys.numberOfWorkouts, numberOfWorkouts + 1);

        // Refresh the list after creating
        await getWorkoutSets();
        TalkerService.info(
            'Workout created online: ${newWorkout.name}', 'WORKOUT');
      } else {
        TalkerService.info(
            'Creating workout offline: ${newWorkout.name}', 'WORKOUT');

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
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to create workout set', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to create workout: ${e.toString()}');
    }
  }

  Future<void> deleteWorkoutSet(int workoutID, int index) async {
    try {
      if (workoutID <= 0) {
        state = ProviderStates(errorMessage: 'Invalid workout ID');
        TalkerService.warning(
            'Attempted to delete workout with invalid ID: $workoutID',
            'WORKOUT');
        return;
      }

      if (_isOnline) {
        // Online: Delete from server
        _workoutRepo.deleteWorkoutSet(workoutID);
        TalkerService.info('Workout deleted online: ID $workoutID', 'WORKOUT');
      } else {
        // Offline: Track for later sync
        await HiveManager.addPendingOperation(
          PendingOperation(
            entityType: 'workout',
            operationType: SyncOperationType.delete,
            id: workoutID,
            timestamp: DateTime.now(),
          ),
        );
        TalkerService.info(
            'Workout deletion queued for sync: ID $workoutID', 'WORKOUT');
      }

      // Update UI
      workoutList.removeWhere((workout) => workout.id == workoutID);

      // Remove from Hive safely
      if (index >= 0 && index < HiveManager.workoutsBox.length) {
        await HiveManager.workoutsBox.deleteAt(index);
      }

      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to delete workout set', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to delete workout: ${e.toString()}');
    }
  }

  void disableSelectMode() {
    selectMode = false;
    newWorkout.workoutItems?.clear();
    TalkerService.info('Select mode explicitly disabled', 'WORKOUT');
    state = ProviderStates(isSuccess: true);
  }

  void fillNewWorkout({
    String? name,
    String? description,
    List<WorkoutItemModel>? workoutItems,
  }) {
    try {
      newWorkout = newWorkout.copyWith(
        name: name,
        description: description,
        workoutItems: workoutItems,
      );
    } catch (e) {
      TalkerService.error('Failed to update new workout data', 'WORKOUT', e);
    }
  }

  Future<void> getWorkoutSets() async {
    try {
      if (_isOnline) {
        // Online: Get from server and update Hive
        state = ProviderStates(isLoading: true);
        workoutList = await _workoutRepo.getWorkoutSets();

        // Update Hive with fresh data
        await HiveManager.workoutsBox.clear();
        for (var workout in workoutList) {
          await HiveManager.workoutsBox.add(workout);
        }
        TalkerService.info(
            'Loaded ${workoutList.length} workouts from server', 'WORKOUT');
      } else {
        // Offline: Load from Hive
        workoutList = HiveManager.workoutsBox.values.toList();
        updateWorkoutExerciseVideoPath(workoutList);
        TalkerService.info(
            'Loaded ${workoutList.length} workouts from cache', 'WORKOUT');
      }

      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to get workout sets', 'WORKOUT', e, stackTrace);

      // Fallback to cached data
      try {
        workoutList = HiveManager.workoutsBox.values.toList();
        updateWorkoutExerciseVideoPath(workoutList);
        state = ProviderStates(isSuccess: true);
        TalkerService.info(
            'Fallback to cached workouts: ${workoutList.length}', 'WORKOUT');
      } catch (fallbackError) {
        TalkerService.error(
            'Failed to load cached workouts', 'WORKOUT', fallbackError);
        state = ProviderStates(errorMessage: 'Failed to load workouts');
      }
    }
  }

  Future<void> reorderWorkoutsList(List<WorkoutSetModel> workouts) async {
    if (workouts.isEmpty) {
      TalkerService.warning(
          'Attempted to reorder empty workout list', 'WORKOUT');
      return;
    }

    final reorderedWorkoutsList = workouts
        .asMap()
        .entries
        .map((entry) => {
              "id": entry.value.id,
              "order": entry.key,
            })
        .toList();

    try {
      if (_isOnline) {
        // Online: Reorder on server
        await _workoutRepo.reorderWorkoutsList(reorderedWorkoutsList);
        TalkerService.info('Workouts reordered online', 'WORKOUT');
      } else {
        // Offline: Track for later sync
        await HiveManager.addPendingOperation(PendingOperation(
          entityType: 'workout',
          operationType: SyncOperationType.reorder,
          reorderWorkoutList: reorderedWorkoutsList,
          timestamp: DateTime.now(),
        ));
        TalkerService.info('Workout reorder queued for sync', 'WORKOUT');
      }

      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to reorder workouts', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to reorder workouts: ${e.toString()}');
    }
  }

  void resetNewWorkout() {
    newWorkout = WorkoutSetModel(
      name: '',
      description: '',
      workoutItems: [],
    );
  }

  void toggleSelectMode() {
    selectMode = !selectMode;
    // Clear selected items when turning off select mode
    if (!selectMode) {
      newWorkout.workoutItems?.clear();
      TalkerService.info(
          'Select mode ${selectMode ? 'enabled' : 'disabled'}', 'WORKOUT');
    }
    state = ProviderStates(isSuccess: true);
  }

  Future<void> updateLastWeight(
      int workoutID, int exerciseID, num weight) async {
    try {
      // Validate inputs
      if (workoutID <= 0 || exerciseID <= 0 || weight < 0) {
        state =
            ProviderStates(errorMessage: 'Invalid workout or exercise data');
        TalkerService.warning(
            'Invalid data for weight update: workout=$workoutID, exercise=$exerciseID, weight=$weight',
            'WORKOUT');
        return;
      }

      if (_isOnline) {
        // Online: Update on server
        state = ProviderStates(isLoading: true);
        await _workoutRepo.updateLastWeight(workoutID, exerciseID, weight);
        updateLastWeightLocal(workoutID, exerciseID, weight);
        TalkerService.info(
            'Weight updated online: workout=$workoutID, exercise=$exerciseID, weight=$weight',
            'WORKOUT');
      } else {
        // Offline: Track for later sync
        final workout = workoutList.firstWhere(
          (workout) => workout.id == workoutID,
          orElse: () => throw Exception('Workout not found'),
        );

        await HiveManager.addPendingOperation(PendingOperation(
          entityType: 'workout_weight',
          operationType: SyncOperationType.update,
          workout: workout,
          exerciseId: exerciseID,
          weight: weight,
          timestamp: DateTime.now(),
        ));

        // Update local Hive data
        updateLastWeightLocal(workoutID, exerciseID, weight);
        TalkerService.info(
            'Weight update queued for sync: workout=$workoutID, exercise=$exerciseID, weight=$weight',
            'WORKOUT');
      }

      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update last weight', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to update weight: ${e.toString()}');
    }
  }

  Future<void> updateLastWeightLocal(
      int workoutID, int exerciseID, num weight) async {
    try {
      final index = HiveManager.workoutsBox.values
          .toList()
          .indexWhere((element) => element.id == workoutID);

      if (index < 0) {
        throw Exception('Workout not found in local storage');
      }

      final workout = HiveManager.workoutsBox.getAt(index);
      if (workout == null) {
        throw Exception('Workout data is null');
      }

      final exerciseIndex = workout.workoutItems?.indexWhere(
            (element) => element.exercise.id == exerciseID,
          ) ??
          -1;

      if (exerciseIndex < 0) {
        throw Exception('Exercise not found in workout');
      }

      workout.workoutItems![exerciseIndex].lastWeight = weight;
      await HiveManager.workoutsBox.putAt(index, workout);

      TalkerService.info(
          'Local weight updated: workout=$workoutID, exercise=$exerciseID, weight=$weight',
          'WORKOUT');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update local weight', 'WORKOUT', e, stackTrace);
      rethrow;
    }
  }

  void updateWorkoutExerciseVideoPath(List<WorkoutSetModel> workoutList) async {
    try {
      TalkerService.info(
          'Updating workout exercise video paths for ${workoutList.length} workouts',
          'WORKOUT');

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
                    targetedMuscles: cachedExercise.targetedMuscles,
                  ),
                );
                workoutModified = true;
              }
            } else {
              TalkerService.warning(
                  'No cached exercise found for ID: ${workoutItem.exercise.id}',
                  'WORKOUT');
            }
          }
        }

        if (workoutModified) {
          updatedWorkouts.add(workout);
        }
      }

      // Update Hive with modified workouts
      for (var updatedWorkout in updatedWorkouts) {
        final index =
            HiveManager.workoutsBox.values.toList().indexOf(updatedWorkout);
        if (index >= 0) {
          await HiveManager.workoutsBox.putAt(index, updatedWorkout);
        }
      }

      TalkerService.info(
          'Video path update completed for ${updatedWorkouts.length} workouts',
          'WORKOUT');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update video paths', 'WORKOUT', e, stackTrace);
    }
  }

  Future<void> updateWorkoutSet(WorkoutSetModel workout) async {
    try {
      // Validate workout
      if (workout.name?.trim().isEmpty ?? true) {
        state = ProviderStates(errorMessage: 'Workout name is required');
        TalkerService.warning(
            'Attempted to update workout without name', 'WORKOUT');
        return;
      }

      if (_isOnline) {
        // Online: Update on server
        state = ProviderStates(isLoading: true);
        await _workoutRepo.updateWorkoutSet(workout);
        await getWorkoutSets(); // Refresh the list after editing
        TalkerService.info(
            'Workout updated online: ${workout.name}', 'WORKOUT');
      } else {
        // Offline: Update local Hive data
        final index = HiveManager.workoutsBox.values
            .toList()
            .indexWhere((element) => element.id == workout.id);

        if (index >= 0) {
          await HiveManager.workoutsBox.putAt(index, workout);

          // Track for later sync
          await HiveManager.addPendingOperation(
            PendingOperation(
              entityType: 'workout',
              operationType: SyncOperationType.update,
              workout: workout,
              timestamp: DateTime.now(),
            ),
          );
          TalkerService.info(
              'Workout update queued for sync: ${workout.name}', 'WORKOUT');
        } else {
          throw Exception('Workout not found in local storage');
        }
      }

      resetNewWorkout();
      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update workout set', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to update workout: ${e.toString()}');
    }
  }
}

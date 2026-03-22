import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/providers/cache_provider.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Workouts/data/models/exercise_set_record_model.dart';
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

  // Success message state
  bool shouldShowSuccessMessage = false;
  String? successWorkoutName;

  WorkoutSetModel newWorkout = WorkoutSetModel(
    name: '',
    description: '',
    workoutItems: [],
  );

  bool get _isOnline => ConnectivityChecker.isOnline == true;

  /// Updates the weight for ALL sets of an exercise to the specified value.
  /// Also updates the lastWeight default for future sets.
  /// Returns the weight_change locally calculated for immediate UI feedback.
  Future<num?> applyWeightToAllSets(
    int? workoutID,
    int exerciseID,
    num newWeight, {
    WorkoutSetModel? workout,
  }) async {
    try {
      // 1. Resolve Workout and Item
      WorkoutSetModel? resolvedWorkout = workout;
      if (resolvedWorkout == null && workoutID != null) {
        try {
          resolvedWorkout = workoutList.firstWhere((w) => w.id == workoutID);
        } catch (_) {}
      }

      if (resolvedWorkout == null) {
        state = ProviderStates(errorMessage: 'Workout not found');
        return null;
      }

      final itemIndex = resolvedWorkout.workoutItems?.indexWhere(
            (item) => item.exercise.id == exerciseID,
          ) ??
          -1;

      if (itemIndex < 0) {
        state = ProviderStates(errorMessage: 'Exercise not found');
        return null;
      }

      final workoutItem = resolvedWorkout.workoutItems![itemIndex];
      final originalWeight = workoutItem.lastWeight;

      // Calculate local weight change for immediate animation
      final localWeightChange = newWeight - originalWeight;

      // 2. Optimistic Local Update
      // Update Exercise Last Weight (Default for future sets)
      workoutItem.lastWeight = newWeight;

      // Update ALL existing sets in the workout item
      final updatedSets = (workoutItem.sets ?? []).asMap().entries.map((entry) {
        return entry.value.copyWith(weight: newWeight);
      }).toList();

      resolvedWorkout.workoutItems![itemIndex] =
          workoutItem.copyWith(sets: updatedSets);

      // 3. Save to Hive immediately
      final hiveIndex = HiveManager.workoutsBox.values.toList().indexWhere((w) {
        if (workoutID != null && workoutID > 0) {
          return w.id == workoutID;
        } else {
          return w == resolvedWorkout;
        }
      });

      if (hiveIndex >= 0) {
        await HiveManager.workoutsBox.putAt(hiveIndex, resolvedWorkout);
        workoutList = HiveManager.workoutsBox.values.toList();
      }

      // 4. Notify UI immediately (Success state triggers rebuilds)
      state = ProviderStates(isSuccess: true);

      TalkerService.info(
          'Optimistically updated weight to $newWeight for ALL sets',
          'WORKOUT');

      // 5. Trigger Background Sync (Fire and Forget)
      _syncWeightUpdateInBackground(
        workoutID: workoutID,
        exerciseID: exerciseID,
        newWeight: newWeight,
        updatedSets: updatedSets,
        resolvedWorkout: resolvedWorkout,
      );

      // Return local change so animation can start instantly in the UI
      return localWeightChange;
    } catch (e, stack) {
      TalkerService.error(
          'Failed optimistic apply weight', 'WORKOUT', e, stack);
      return null;
    }
  }

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

  /// Consume the success message (call after showing it)
  void consumeSuccessMessage() {
    shouldShowSuccessMessage = false;
    successWorkoutName = null;
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

      // Set success message flag
      setSuccessMessage(newWorkout.name ?? 'Workout');

      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to create workout set', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to create workout: ${e.toString()}');
    }
  }

  Future<void> deleteWorkoutSet(int? workoutID,
      {WorkoutSetModel? workout}) async {
    try {
      final isOfflineWorkout = workoutID == null || workoutID <= 0;

      if (!isOfflineWorkout) {
        if (_isOnline) {
          await _workoutRepo.deleteWorkoutSet(workoutID);
          TalkerService.info(
              'Workout deleted online: ID $workoutID', 'WORKOUT');
        } else {
          await HiveManager.addPendingOperation(
            PendingOperation(
              entityType: 'workout',
              operationType: SyncOperationType.delete,
              id: workoutID,
              timestamp: DateTime.now(),
            ),
          );
          TalkerService.info(
              'Workout deletion queued for sync: ID $workoutID',
              'WORKOUT');
        }
      }

      // Delete from Hive by key, not index
      await HiveManager.deleteWorkoutFromBox(
        workoutId: workoutID,
        workout: workout,
      );

      // Refresh list from Hive (single source of truth)
      workoutList = HiveManager.workoutsBox.values.toList();

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

        // cache exercises if not cached
        await ref
            .read(exerciseCacheManagerProvider)
            .autoCacheWorkoutExercises(workoutList);

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
        ref
            .read(exerciseCacheManagerProvider)
            .syncWorkoutExercisesWithCache(workoutList);
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
        ref
            .read(exerciseCacheManagerProvider)
            .syncWorkoutExercisesWithCache(workoutList);
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

  /// Notify listeners that workout items have changed
  void notifyWorkoutItemsChanged() {
    state = ProviderStates(isSuccess: true);
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

  /// Set success message to be shown once
  void setSuccessMessage(String workoutName) {
    shouldShowSuccessMessage = true;
    successWorkoutName = workoutName;
  }

  void toggleSelectMode() {
    selectMode = !selectMode;
    // Always reset to a fresh instance so we never share a list reference
    // with the actual workout stored in Hive (Hive Box returns same instances).
    // Mutating the old newWorkout.workoutItems would silently wipe workout data.
    resetNewWorkout();
    TalkerService.info(
        'Select mode ${selectMode ? 'enabled' : 'disabled'}', 'WORKOUT');
    state = ProviderStates(isSuccess: true);
  }

  /// Updates exercise sets for a workout.
  /// Works for both online and offline modes.
  /// Throws an error if the update fails.
  Future<void> updateExerciseSets({
    required int? workoutSetId,
    required int exerciseId,
    required List<Map<String, dynamic>> sets,
  }) async {
    try {
      // Validate inputs
      if (workoutSetId == null || workoutSetId <= 0) {
        state = ProviderStates(errorMessage: 'Invalid workout ID');
        TalkerService.warning(
            'Invalid workout ID for sets update: $workoutSetId', 'WORKOUT');
      }

      if (exerciseId <= 0) {
        state = ProviderStates(errorMessage: 'Invalid exercise ID');
        TalkerService.warning(
            'Invalid exercise ID for sets update: $exerciseId', 'WORKOUT');
      }

      if (_isOnline) {
        // Online: Update on server
        state = ProviderStates(isLoading: true);
        await _workoutRepo.updateExerciseSets(
          workoutSetId: workoutSetId!,
          exerciseId: exerciseId,
          sets: sets,
        );

        TalkerService.info(
            'Sets updated online: workout=$workoutSetId, exercise=$exerciseId',
            'WORKOUT');

        state = ProviderStates(isSuccess: true);
      } else {
        // Offline: Queue for later sync and update locally
        final workoutObj = workoutList.firstWhere(
          (w) => w.id == workoutSetId,
          orElse: () => throw Exception('Workout not found'),
        );

        await HiveManager.addPendingOperation(PendingOperation(
          entityType: 'workout_sets',
          operationType: SyncOperationType.update,
          workout: workoutObj,
          workoutSetId: workoutSetId,
          exerciseId: exerciseId,
          sets: sets,
          timestamp: DateTime.now(),
        ));

        // Update local Hive data with new sets
        await _updateExerciseSetsLocal(workoutSetId!, exerciseId, sets);

        TalkerService.info(
            'Sets update queued for sync: workout=$workoutSetId, exercise=$exerciseId',
            'WORKOUT');

        state = ProviderStates(isSuccess: true);
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update exercise sets', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to update sets: ${e.toString()}');
    }
  }

  /// Updates last weight for a workout exercise
  /// Works for both online workouts (with ID) and offline workouts (without ID)
  /// Returns weight_change if online
  Future<num?> updateLastWeight(int? workoutID, int exerciseID, num weight,
      {WorkoutSetModel? workout}) async {
    try {
      // Validate inputs
      if (exerciseID <= 0 || weight < 0) {
        state = ProviderStates(errorMessage: 'Invalid exercise data or weight');
        TalkerService.warning(
            'Invalid data for weight update: exercise=$exerciseID, weight=$weight',
            'WORKOUT');
        return null;
      }

      // For offline workouts without ID, we need the workout object
      if (workoutID == null && workout == null) {
        state = ProviderStates(
            errorMessage: 'Either workoutID or workout object is required');
        TalkerService.warning(
            'Missing both workoutID and workout object', 'WORKOUT');
        return null;
      }

      num? weightChange;

      if (_isOnline && workoutID != null && workoutID > 0) {
        // Online: Update on server (only if workout has a server ID)
        state = ProviderStates(isLoading: true);
        weightChange =
            await _workoutRepo.updateLastWeight(workoutID, exerciseID, weight);
        updateLastWeightLocal(workoutID, exerciseID, weight);
        await _workoutRepo.fetchWorkoutById(workoutID);
        TalkerService.info(
            'Weight updated online: workout=$workoutID, exercise=$exerciseID, weight=$weight',
            'WORKOUT');
      } else {
        // Offline or workout without server ID
        if (workoutID != null && workoutID > 0) {
          // Offline workout with ID: Track for later sync
          final workoutObj = workoutList.firstWhere(
            (w) => w.id == workoutID,
            orElse: () => throw Exception('Workout not found'),
          );

          await HiveManager.addPendingOperation(PendingOperation(
            entityType: 'workout_weight',
            operationType: SyncOperationType.update,
            workout: workoutObj,
            exerciseId: exerciseID,
            weight: weight,
            timestamp: DateTime.now(),
          ));

          // Update local Hive data
          updateLastWeightLocal(workoutID, exerciseID, weight);
          TalkerService.info(
              'Weight update queued for sync: workout=$workoutID, exercise=$exerciseID, weight=$weight',
              'WORKOUT');
        } else {
          // Offline workout without ID: Update directly using workout object
          updateLastWeightForOfflineWorkout(workout!, exerciseID, weight);
          TalkerService.info(
              'Weight updated for offline workout without ID: exercise=$exerciseID, weight=$weight',
              'WORKOUT');
        }
      }

      state = ProviderStates(isSuccess: true);
      return weightChange;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update last weight', 'WORKOUT', e, stackTrace);
      state = ProviderStates(
          errorMessage: 'Failed to update weight: ${e.toString()}');
      return null;
    }
  }

  /// Updates last weight for offline workouts that don't have an ID yet
  Future<void> updateLastWeightForOfflineWorkout(
      WorkoutSetModel workout, int exerciseID, num weight) async {
    try {
      // Find the workout in Hive by comparing object references
      final index = HiveManager.workoutsBox.values
          .toList()
          .indexWhere((element) => element == workout);

      if (index < 0) {
        throw Exception('Workout not found in local storage');
      }

      final storedWorkout = HiveManager.workoutsBox.getAt(index);
      if (storedWorkout == null) {
        throw Exception('Workout data is null');
      }

      final exerciseIndex = storedWorkout.workoutItems?.indexWhere(
            (element) => element.exercise.id == exerciseID,
          ) ??
          -1;

      if (exerciseIndex < 0) {
        throw Exception('Exercise not found in workout');
      }

      storedWorkout.workoutItems![exerciseIndex].lastWeight = weight;
      await HiveManager.workoutsBox.putAt(index, storedWorkout);

      // Update the workout list
      workoutList = HiveManager.workoutsBox.values.toList();

      TalkerService.info(
          'Local weight updated for offline workout: exercise=$exerciseID, weight=$weight',
          'WORKOUT');

      state = ProviderStates(isSuccess: true);
    } catch (e, stackTrace) {
      TalkerService.error('Failed to update local weight for offline workout',
          'WORKOUT', e, stackTrace);
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

          // Refresh the workout list from Hive to update UI
          workoutList = HiveManager.workoutsBox.values.toList();

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

  /// Helper to synchronize weight updates in the background.
  void _syncWeightUpdateInBackground({
    required int? workoutID,
    required int exerciseID,
    required num newWeight,
    required List<ExerciseSetRecordModel> updatedSets,
    required WorkoutSetModel resolvedWorkout,
  }) async {
    try {
      final setsData = updatedSets
          .map((s) => {
                'set_number': s.setNumber,
                'reps': s.reps,
                'weight': s.weight,
              })
          .toList();

      if (_isOnline && workoutID != null && workoutID > 0) {
        // Online: Update server
        // 1. Update Default Weight
        await _workoutRepo.updateLastWeight(workoutID, exerciseID, newWeight);

        // 2. Update All Sets
        await _workoutRepo.updateExerciseSets(
          workoutSetId: workoutID,
          exerciseId: exerciseID,
          sets: setsData,
        );

        TalkerService.info(
            'Background sync successful for weight update', 'WORKOUT');
      } else {
        // Offline: Add to pending operations
        if (workoutID != null && workoutID > 0) {
          // Track weight change
          await HiveManager.addPendingOperation(PendingOperation(
            entityType: 'workout_weight',
            operationType: SyncOperationType.update,
            workout: resolvedWorkout,
            exerciseId: exerciseID,
            weight: newWeight,
          ));

          // Track sets change
          await HiveManager.addPendingOperation(PendingOperation(
            entityType: 'workout_sets',
            operationType: SyncOperationType.update,
            workout: resolvedWorkout,
            workoutSetId: workoutID,
            exerciseId: exerciseID,
            sets: setsData,
          ));

          TalkerService.info('Weight update queued for sync', 'WORKOUT');
        }
      }
    } catch (e, stack) {
      TalkerService.error('Background sync failed, queuing for retry',
          'WORKOUT', e, stack);

      // CRITICAL FIX: Queue pending operations on failure so they retry later
      if (workoutID != null && workoutID > 0) {
        try {
          final setsData = updatedSets
              .map((s) => {
                    'set_number': s.setNumber,
                    'reps': s.reps,
                    'weight': s.weight,
                  })
              .toList();

          await HiveManager.addPendingOperation(PendingOperation(
            entityType: 'workout_weight',
            operationType: SyncOperationType.update,
            workout: resolvedWorkout,
            exerciseId: exerciseID,
            weight: newWeight,
            timestamp: DateTime.now(),
          ));
          await HiveManager.addPendingOperation(PendingOperation(
            entityType: 'workout_sets',
            operationType: SyncOperationType.update,
            workout: resolvedWorkout,
            workoutSetId: workoutID,
            exerciseId: exerciseID,
            sets: setsData,
            timestamp: DateTime.now(),
          ));
        } catch (pendingError) {
          TalkerService.error(
              'Failed to queue pending operations after sync failure',
              'WORKOUT',
              pendingError);
        }
      }
    }
  }

  /// Updates exercise sets locally in Hive for offline mode.
  Future<void> _updateExerciseSetsLocal(
    int workoutSetId,
    int exerciseId,
    List<Map<String, dynamic>> sets,
  ) async {
    try {
      final index = HiveManager.workoutsBox.values
          .toList()
          .indexWhere((element) => element.id == workoutSetId);

      if (index < 0) {
        throw Exception('Workout not found in local storage');
      }

      final workout = HiveManager.workoutsBox.getAt(index);
      if (workout == null) {
        throw Exception('Workout data is null');
      }

      final exerciseIndex = workout.workoutItems?.indexWhere(
            (element) => element.exercise.id == exerciseId,
          ) ??
          -1;

      if (exerciseIndex < 0) {
        throw Exception('Exercise not found in workout');
      }

      // Convert sets data to ExerciseSetRecordModel list
      final updatedSets = sets.asMap().entries.map((entry) {
        final setData = entry.value;
        return ExerciseSetRecordModel(
          id: 0, // Local sets don't have server IDs yet
          setNumber: entry.key + 1,
          reps: (setData['reps'] as num?)?.toInt() ?? 0,
          weight: (setData['weight'] as num?) ?? 0.0,
        );
      }).toList();

      // Update the workout item with new sets
      final oldItem = workout.workoutItems![exerciseIndex];
      workout.workoutItems![exerciseIndex] = oldItem.copyWith(
        sets: updatedSets,
      );

      await HiveManager.workoutsBox.putAt(index, workout);

      // Update the workout list
      workoutList = HiveManager.workoutsBox.values.toList();

      TalkerService.info(
          'Local sets updated: workout=$workoutSetId, exercise=$exerciseId',
          'WORKOUT');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to update local sets', 'WORKOUT', e, stackTrace);
      rethrow;
    }
  }
}

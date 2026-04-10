# Fix Offline CRUD Operations in Workouts Feature

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Fix all critical and moderate bugs in the Workouts feature's offline CRUD operations — covering untracked background syncs, index-based deletion fragility, missing server IDs after offline creation, sync queue reliability, and operation deduplication.

**Architecture:** The app uses an offline-first pattern: mutations apply to Hive immediately, queue a `PendingOperation`, and sync when connectivity is restored. Fixes will harden this pattern by (1) adding proper equality to models so offline lookups work, (2) using ID/key-based Hive lookups instead of index-based, (3) always queuing pending ops for failed online calls, (4) refreshing server IDs after sync, (5) making the sync queue resilient to partial failures, and (6) deduplicating redundant operations before sync.

**Tech Stack:** Flutter, Riverpod (Notifier), Hive CE (local storage), Dio (HTTP), connectivity_plus

---

## File Structure

| File | Responsibility | Action |
|------|---------------|--------|
| `lib/features/Workouts/data/models/workoutset_model.dart` | WorkoutSetModel + WorkoutItemModel | Modify |
| `lib/features/Workouts/presentation/providers/workout_provider.dart` | All workout CRUD logic + state | Modify |
| `lib/features/Workouts/presentation/widgets/enhanced_workout_card.dart` | Workout card UI (delete call site) | Modify |
| `lib/features/Workouts/presentation/widgets/workouts_listview.dart` | Workout list UI (delete call site) | Modify |
| `lib/features/Exercises/presentation/screens/exercise_details_screen.dart` | Exercise details (updateExerciseSets call site) | Modify |
| `lib/core/services/sync.dart` | Pending operation sync engine | Modify |
| `lib/core/services/hive_boxes.dart` | Hive box management + pending ops helpers | Modify |

---

### Task 0: Add Value Equality to WorkoutSetModel

**Why:** `WorkoutSetModel` extends `HiveObject` and has **no `operator ==` or `hashCode` override**. Every task in this plan that looks up offline-created workouts (which have `id: null`) relies on object equality — but Hive deserializes into new instances, so referential `==` always fails. This is a prerequisite for all subsequent tasks.

**Files:**
- Modify: `lib/features/Workouts/data/models/workoutset_model.dart:158-282`

- [ ] **Step 1: Add `operator ==` and `hashCode` to `WorkoutSetModel`**

Add inside the `WorkoutSetModel` class, after the `_parseDateTime` method (before the closing brace at line 282):

```dart
@override
bool operator ==(Object other) {
  if (identical(this, other)) return true;
  if (other is! WorkoutSetModel) return false;

  // If both have server IDs, compare by ID
  if (id != null && id! > 0 && other.id != null && other.id! > 0) {
    return id == other.id;
  }

  // For offline workouts (no ID), compare by name + createdAt
  return name == other.name && createdAt == other.createdAt;
}

@override
int get hashCode {
  if (id != null && id! > 0) return id.hashCode;
  return Object.hash(name, createdAt);
}
```

- [ ] **Step 2: Verify the app compiles**

Run: `flutter analyze lib/features/Workouts/data/models/workoutset_model.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/Workouts/data/models/workoutset_model.dart
git commit -m "feat: add value equality to WorkoutSetModel for reliable offline workout lookups"
```

---

### Task 1: Fix Index-Based Hive Deletion — Use Key-Based Lookup

**Why:** `deleteWorkoutSet()` at line 252 uses `HiveManager.workoutsBox.deleteAt(index)` where `index` comes from the UI list. If the in-memory `workoutList` and the Hive box are ever out of sync (filtered view, failed refresh, race condition), this deletes the **wrong workout**.

**Files:**
- Modify: `lib/features/Workouts/presentation/providers/workout_provider.dart:214-263`
- Modify: `lib/core/services/hive_boxes.dart` (add helper)
- Modify: `lib/features/Workouts/presentation/widgets/enhanced_workout_card.dart:373-376`
- Modify: `lib/features/Workouts/presentation/widgets/workouts_listview.dart:247-251`

- [ ] **Step 1: Add a `deleteWorkoutFromBox` helper to HiveManager**

In `lib/core/services/hive_boxes.dart`, add a method that finds and deletes a workout by its Hive key (not positional index):

```dart
/// Deletes a workout from Hive by matching its server [id].
/// For offline workouts (id == null), falls back to value equality
/// (uses WorkoutSetModel's == override which compares name + createdAt).
/// Returns true if a workout was found and deleted.
static Future<bool> deleteWorkoutFromBox({
  int? workoutId,
  WorkoutSetModel? workout,
}) async {
  for (final key in workoutsBox.keys) {
    final stored = workoutsBox.get(key);
    if (stored == null) continue;

    if (workoutId != null && workoutId > 0 && stored.id == workoutId) {
      await workoutsBox.delete(key);
      return true;
    }
    if (workoutId == null && workout != null && stored == workout) {
      await workoutsBox.delete(key);
      return true;
    }
  }
  return false;
}
```

- [ ] **Step 2: Rewrite `deleteWorkoutSet` to use key-based deletion**

Replace the current `deleteWorkoutSet` method in `workout_provider.dart` (lines 214-263). Note: the `index` parameter is replaced with an optional `workout` named parameter:

```dart
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
```

- [ ] **Step 3: Update call site in `enhanced_workout_card.dart`**

File: `lib/features/Workouts/presentation/widgets/enhanced_workout_card.dart:373-376`

```dart
// OLD (line 374-376):
ref
    .read(workoutsProvider.notifier)
    .deleteWorkoutSet(widget.workout.id, widget.index);

// NEW:
ref
    .read(workoutsProvider.notifier)
    .deleteWorkoutSet(widget.workout.id,
        workout: widget.workout);
```

- [ ] **Step 4: Update call site in `workouts_listview.dart`**

File: `lib/features/Workouts/presentation/widgets/workouts_listview.dart:248-250`

```dart
// OLD (line 248-250):
ref
    .read(workoutsProvider.notifier)
    .deleteWorkoutSet(widget.workouts[index].id, index);

// NEW:
ref
    .read(workoutsProvider.notifier)
    .deleteWorkoutSet(widget.workouts[index].id,
        workout: widget.workouts[index]);
```

- [ ] **Step 5: Verify the app compiles**

Run: `flutter analyze lib/features/Workouts/`
Expected: No errors related to `deleteWorkoutSet`

- [ ] **Step 6: Commit**

```bash
git add lib/features/Workouts/presentation/providers/workout_provider.dart lib/core/services/hive_boxes.dart lib/features/Workouts/presentation/widgets/enhanced_workout_card.dart lib/features/Workouts/presentation/widgets/workouts_listview.dart
git commit -m "fix: replace index-based Hive deletion with key-based lookup in deleteWorkoutSet"
```

---

### Task 2: Fix Untracked Background Weight Sync (applyWeightToAllSets)

**Why:** `applyWeightToAllSets()` (line 39) fires `_syncWeightUpdateInBackground()` as fire-and-forget when online. If the network call fails, the weight is saved to Hive but **never queued as a PendingOperation** — so it's permanently lost on the server side.

**Files:**
- Modify: `lib/features/Workouts/presentation/providers/workout_provider.dart:700-758`

- [ ] **Step 1: Add pending operation fallback in `_syncWeightUpdateInBackground` catch block**

The existing online and offline paths (lines 716-753) are correct. The bug is in the `catch` block (line 755) which only logs the error. Replace **only the catch block** (lines 755-757):

```dart
// OLD catch block:
} catch (e, stack) {
  TalkerService.error('Background sync failed', 'WORKOUT', e, stack);
}

// NEW catch block — queues pending operations so the update retries on next sync:
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
```

- [ ] **Step 2: Verify the online delete in Task 1's rewrite uses `await`**

Confirm the rewritten `deleteWorkoutSet` from Task 1 has `await _workoutRepo.deleteWorkoutSet(workoutID)` (not fire-and-forget).

- [ ] **Step 3: Verify the app compiles**

Run: `flutter analyze lib/features/Workouts/presentation/providers/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/features/Workouts/presentation/providers/workout_provider.dart
git commit -m "fix: queue pending operations when background weight sync fails online"
```

---

### Task 3: Make Sync Queue Resilient — Don't Clear Failed Operations

**Why:** `_syncWorkouts()` in `sync.dart` (line 257) calls `HiveManager.clearPendingOperations()` after the loop — **even if some operations failed**. This silently discards failed operations forever.

**Files:**
- Modify: `lib/core/services/sync.dart:186-258`

- [ ] **Step 1: Track failed operations and only clear successful ones**

Replace the `_syncWorkouts()` method:

```dart
Future<void> _syncWorkouts() async {
  final List<PendingOperation> pendingOps =
      HiveManager.pendingOpsBox.values.toList();

  if (pendingOps.isEmpty) return;

  TalkerService.info(
    'Found ${pendingOps.length} pending workout operations',
    'SYNC',
  );

  pendingOps.sort((a, b) => a.timestamp.compareTo(b.timestamp));

  final keysToDelete = <dynamic>[];

  for (int i = 0; i < pendingOps.length; i++) {
    final op = pendingOps[i];
    try {
      if (op.entityType == 'workout') {
        switch (op.operationType) {
          case SyncOperationType.create:
            if (op.workout != null) {
              TalkerService.info(
                'Creating workout: ${op.workout!.name}',
                'SYNC',
              );
              await workoutRepository.createWorkoutSet(op.workout!);
            }
            break;

          case SyncOperationType.update:
            final workout = op.workout!;
            await workoutRepository.updateWorkoutSet(workout);
            break;

          case SyncOperationType.delete:
            if (op.id != null) {
              await workoutRepository.deleteWorkoutSet(op.id!);
            }
            break;

          case SyncOperationType.reorder:
            await workoutRepository
                .reorderWorkoutsList(op.reorderWorkoutList!);
            break;
        }
      } else if (op.entityType == 'workout_weight') {
        await workoutRepository.updateLastWeight(
          op.workout!.id!,
          op.exerciseId!,
          op.weight!,
        );
      } else if (op.entityType == 'workout_sets') {
        if (op.workoutSetId != null &&
            op.exerciseId != null &&
            op.sets != null) {
          await workoutRepository.updateExerciseSets(
            workoutSetId: op.workoutSetId!,
            exerciseId: op.exerciseId!,
            sets: op.sets!,
          );
          TalkerService.info(
            'Synced exercise sets: workout=${op.workoutSetId}, exercise=${op.exerciseId}',
            'SYNC',
          );
        }
      }

      // Only mark for deletion if operation succeeded
      if (op.key != null) {
        keysToDelete.add(op.key);
      }
    } on Exception catch (e) {
      TalkerService.error(
          'Error syncing operation: ${op.entityType}/${op.operationType}',
          'SYNC',
          e);
      // Do NOT add to keysToDelete — operation stays in queue for retry
      continue;
    }
  }

  // Delete only successful operations
  for (final key in keysToDelete) {
    await HiveManager.pendingOpsBox.delete(key);
  }

  if (keysToDelete.length == pendingOps.length) {
    TalkerService.info('All ${pendingOps.length} operations synced', 'SYNC');
  } else {
    final failed = pendingOps.length - keysToDelete.length;
    TalkerService.warning(
      '$failed/${pendingOps.length} operations failed, will retry next sync',
      'SYNC',
    );
  }
}
```

- [ ] **Step 2: Verify the app compiles**

Run: `flutter analyze lib/core/services/sync.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/sync.dart
git commit -m "fix: only clear successful pending operations during sync, retain failed ones for retry"
```

---

### Task 4: Refresh Server IDs After Offline Workout Sync

**Why:** Workouts created offline get `id: null`. After sync, the server assigns an ID, but the local Hive copy still has `id: null`. Any subsequent update/delete on that workout fails. The fix: after syncing create operations, re-fetch all workouts to get server-assigned IDs. We also need to cache exercises for the refreshed workouts.

**Files:**
- Modify: `lib/core/services/sync.dart`

- [ ] **Step 1: Add a post-sync refresh in SyncService**

After `_syncWorkouts()` completes with at least one `create` operation, trigger a full workout list refresh. Replace the `syncPendingOperations()` method:

```dart
Future<void> syncPendingOperations() async {
  if (!ConnectivityChecker.isOnline!) return;
  try {
    state = state.copyWith(isLoading: true);

    // Track if we had create operations (need ID refresh after sync)
    final hadCreateOps = HiveManager.pendingOpsBox.values
        .any((op) => op.operationType == SyncOperationType.create);

    // Sync workouts
    await _syncWorkouts();

    // Sync products
    await _syncProducts();

    // If we synced any create operations, refresh workout list
    // to get server-assigned IDs into Hive
    if (hadCreateOps && ConnectivityChecker.isOnline == true) {
      try {
        final freshWorkouts =
            await workoutRepository.getWorkoutSets();
        await HiveManager.workoutsBox.clear();
        for (var workout in freshWorkouts) {
          await HiveManager.workoutsBox.add(workout);
        }
        TalkerService.info(
          'Refreshed workout list after sync to update server IDs',
          'SYNC',
        );
      } catch (e) {
        TalkerService.warning(
          'Failed to refresh workouts after sync: $e',
          'SYNC',
        );
      }
    }

    // Update pending counts
    state = state.copyWith(
      isLoading: false,
      pendingWorkouts: HiveManager.pendingOpsBox.length,
      pendingProducts: HiveManager.pendingProductsBox.length,
    );

    if (!state.hasPendingItems) {
      showToast(
        'synced with server'.capitalizeWord(),
        position: ToastPosition.bottom,
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        textPadding: const EdgeInsets.all(10),
        textStyle: const TextStyle(
          fontSize: 14,
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      );
    }

    TalkerService.info('Sync completed', 'SYNC');
  } catch (e) {
    state = state.copyWith(isLoading: false);
    TalkerService.error('Error during sync', 'SYNC', e);
  }
}
```

**Note:** The exercise cache refresh is intentionally not replicated here. The `exerciseCacheManagerProvider` auto-caches exercises when `getWorkoutSets()` is called from the provider in the UI. Since sync runs in the background, the next time the user opens the workout list, `getWorkoutSets()` will be called and exercises will be cached then.

- [ ] **Step 2: Verify the app compiles**

Run: `flutter analyze lib/core/services/sync.dart`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/core/services/sync.dart
git commit -m "fix: refresh workout list after sync to populate server-assigned IDs"
```

---

### Task 5: Add Pending Operation Deduplication Before Sync

**Why:** If a user creates a workout offline, updates it 5 times, then deletes it — all 7 operations get synced. The `delete` makes the `create` and all `update` operations pointless. Similarly, multiple `update` operations for the same workout can be collapsed to just the latest one.

**Files:**
- Modify: `lib/core/services/hive_boxes.dart` (add deduplication helper)
- Modify: `lib/core/services/sync.dart` (call deduplication before sync)

- [ ] **Step 1: Add deduplication logic to HiveManager**

Add to `lib/core/services/hive_boxes.dart`:

```dart
/// Deduplicates pending operations to minimize sync overhead.
///
/// Rules:
/// 1. If a workout has a `delete` op, remove all prior `create`/`update` ops
///    for that same workout.
/// 2. For multiple `update` ops on the same workout+entity, keep only the
///    latest (by timestamp).
/// 3. For `reorder`, keep only the latest.
static Future<void> deduplicatePendingOps() async {
  final ops = pendingOpsBox.values.toList();
  if (ops.length <= 1) return;

  final keysToRemove = <dynamic>{};

  // Collect IDs of workouts that will be deleted
  final deleteIds = <int>{};
  for (final op in ops) {
    if (op.entityType == 'workout' &&
        op.operationType == SyncOperationType.delete &&
        op.id != null) {
      deleteIds.add(op.id!);
    }
  }

  // Rule 1: Remove create/update ops for workouts that will be deleted
  for (final op in ops) {
    if (op.operationType == SyncOperationType.delete) continue;
    if (op.entityType == 'workout' &&
        op.workout?.id != null &&
        deleteIds.contains(op.workout!.id)) {
      keysToRemove.add(op.key);
    }
  }

  // Rule 2: For same entity+workout+exercise, keep only latest update
  final updateGroups = <String, List<PendingOperation>>{};
  for (final op in ops) {
    if (keysToRemove.contains(op.key)) continue;
    if (op.operationType != SyncOperationType.update) continue;

    final groupKey =
        '${op.entityType}_${op.workout?.id ?? "null"}_${op.exerciseId ?? "null"}';
    updateGroups.putIfAbsent(groupKey, () => []).add(op);
  }

  for (final group in updateGroups.values) {
    if (group.length <= 1) continue;
    group.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    // Remove all but the latest
    for (int i = 0; i < group.length - 1; i++) {
      keysToRemove.add(group[i].key);
    }
  }

  // Rule 3: Keep only latest reorder
  final reorderOps = ops
      .where((op) =>
          op.operationType == SyncOperationType.reorder &&
          !keysToRemove.contains(op.key))
      .toList();
  if (reorderOps.length > 1) {
    reorderOps.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    for (int i = 0; i < reorderOps.length - 1; i++) {
      keysToRemove.add(reorderOps[i].key);
    }
  }

  // Apply removals
  if (keysToRemove.isNotEmpty) {
    for (final key in keysToRemove) {
      await pendingOpsBox.delete(key);
    }
    TalkerService.info(
      'Deduplicated pending ops: removed ${keysToRemove.length}, '
          '${pendingOpsBox.length} remaining',
      'HIVE',
    );
  }
}
```

- [ ] **Step 2: Call deduplication before sync in `_syncWorkouts()`**

At the top of `_syncWorkouts()` in `sync.dart`, add this line right before `final List<PendingOperation> pendingOps = ...`:

```dart
// Deduplicate before syncing to reduce redundant server calls
await HiveManager.deduplicatePendingOps();
```

- [ ] **Step 3: Verify the app compiles**

Run: `flutter analyze lib/core/services/`
Expected: No errors

- [ ] **Step 4: Commit**

```bash
git add lib/core/services/hive_boxes.dart lib/core/services/sync.dart
git commit -m "feat: deduplicate pending operations before sync to reduce redundant server calls"
```

---

### Task 6: Fix `updateExerciseSets` and `updateWorkoutSet` for Offline-Created Workouts

**Why:** `updateExerciseSets()` (line 420) rejects `workoutSetId == null` but doesn't queue a local-only update. Offline-created workouts have `id: null`, so sets can never be edited until sync. Similarly, `updateWorkoutSet()` (line 664) searches Hive by `workout.id` — which is `null` for offline workouts.

**Files:**
- Modify: `lib/features/Workouts/presentation/providers/workout_provider.dart:413-478, 643-697`
- Modify: `lib/features/Exercises/presentation/screens/exercise_details_screen.dart:1357-1361` (call site)

- [ ] **Step 1: Fix `updateExerciseSets` to handle offline-created workouts**

Replace the entire method (lines 413-478). Note the new optional `workout` parameter:

```dart
Future<void> updateExerciseSets({
  required int? workoutSetId,
  required int exerciseId,
  required List<Map<String, dynamic>> sets,
  WorkoutSetModel? workout,
}) async {
  try {
    if (exerciseId <= 0) {
      state = ProviderStates(errorMessage: 'Invalid exercise ID');
      TalkerService.warning(
          'Invalid exercise ID for sets update: $exerciseId', 'WORKOUT');
      return;
    }

    final isOfflineWorkout = workoutSetId == null || workoutSetId <= 0;

    if (!isOfflineWorkout && _isOnline) {
      // Online with valid ID: Update on server
      state = ProviderStates(isLoading: true);
      await _workoutRepo.updateExerciseSets(
        workoutSetId: workoutSetId,
        exerciseId: exerciseId,
        sets: sets,
      );
      TalkerService.info(
          'Sets updated online: workout=$workoutSetId, exercise=$exerciseId',
          'WORKOUT');
    } else if (!isOfflineWorkout && !_isOnline) {
      // Offline with valid ID: Queue for later sync
      final workoutObj = workout ??
          workoutList.firstWhere(
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
      TalkerService.info(
          'Sets update queued for sync: workout=$workoutSetId, exercise=$exerciseId',
          'WORKOUT');
    }
    // else: offline-created workout — no server sync needed, just local update

    // Update local Hive data regardless of online/offline
    if (!isOfflineWorkout) {
      await _updateExerciseSetsLocal(workoutSetId!, exerciseId, sets);
    } else if (workout != null) {
      await _updateExerciseSetsForOfflineWorkout(
          workout, exerciseId, sets);
    }

    state = ProviderStates(isSuccess: true);
  } catch (e, stackTrace) {
    TalkerService.error(
        'Failed to update exercise sets', 'WORKOUT', e, stackTrace);
    state = ProviderStates(
        errorMessage: 'Failed to update sets: ${e.toString()}');
  }
}
```

- [ ] **Step 2: Add `_updateExerciseSetsForOfflineWorkout` helper**

Add this new method to `WorkoutsNotifier` (after `_updateExerciseSetsLocal`):

```dart
/// Updates exercise sets locally for offline-created workouts (no server ID).
/// Uses WorkoutSetModel's value equality (== override) to find the workout in Hive.
Future<void> _updateExerciseSetsForOfflineWorkout(
  WorkoutSetModel workout,
  int exerciseId,
  List<Map<String, dynamic>> sets,
) async {
  try {
    final hiveIndex = HiveManager.workoutsBox.values
        .toList()
        .indexWhere((element) => element == workout);

    if (hiveIndex < 0) {
      throw Exception('Offline workout not found in local storage');
    }

    final storedWorkout = HiveManager.workoutsBox.getAt(hiveIndex);
    if (storedWorkout == null) {
      throw Exception('Workout data is null');
    }

    final exerciseIndex = storedWorkout.workoutItems?.indexWhere(
          (element) => element.exercise.id == exerciseId,
        ) ??
        -1;

    if (exerciseIndex < 0) {
      throw Exception('Exercise not found in workout');
    }

    final updatedSets = sets.asMap().entries.map((entry) {
      final setData = entry.value;
      return ExerciseSetRecordModel(
        id: 0,
        setNumber: entry.key + 1,
        reps: (setData['reps'] as num?)?.toInt() ?? 0,
        weight: (setData['weight'] as num?) ?? 0.0,
      );
    }).toList();

    final oldItem = storedWorkout.workoutItems![exerciseIndex];
    storedWorkout.workoutItems![exerciseIndex] = oldItem.copyWith(
      sets: updatedSets,
    );

    await HiveManager.workoutsBox.putAt(hiveIndex, storedWorkout);
    workoutList = HiveManager.workoutsBox.values.toList();

    TalkerService.info(
        'Local sets updated for offline workout: exercise=$exerciseId',
        'WORKOUT');
  } catch (e, stackTrace) {
    TalkerService.error(
        'Failed to update sets for offline workout',
        'WORKOUT',
        e,
        stackTrace);
    rethrow;
  }
}
```

- [ ] **Step 3: Update `updateExerciseSets` call site in exercise_details_screen.dart**

File: `lib/features/Exercises/presentation/screens/exercise_details_screen.dart:1357-1361`

The current call does not pass the `workout` parameter. Since this screen has a `widget.workoutSetId` but the workout object may not be directly available, the new optional `workout` parameter can be omitted here — the method will use `workoutList.firstWhere()` as fallback:

```dart
// Current code (no change needed — workout parameter is optional):
await ref.read(workoutsProvider.notifier).updateExerciseSets(
      workoutSetId: widget.workoutSetId,
      exerciseId: widget.workoutItem.exercise.id,
      sets: setsData,
    );
```

**However**, if this screen can be reached for offline-created workouts (where `widget.workoutSetId` is null), then the caller that navigates here should also pass the workout object. Check if there's a `widget.workout` or similar field available. If not, this is acceptable — offline-created workouts without an ID simply won't be able to update sets from this screen until synced.

- [ ] **Step 4: Fix `updateWorkoutSet` for offline-created workouts**

In `updateWorkoutSet()`, replace the offline branch (lines 660-686). The current code searches by `workout.id` which is `null` for offline workouts. Add value-equality fallback (uses the `==` override from Task 0):

```dart
} else {
  // Offline: Update local Hive data
  int index = -1;

  if (workout.id != null && workout.id! > 0) {
    // Has server ID — find by ID
    index = HiveManager.workoutsBox.values
        .toList()
        .indexWhere((element) => element.id == workout.id);
  }

  if (index < 0) {
    // Fallback: find by value equality (name + createdAt)
    index = HiveManager.workoutsBox.values
        .toList()
        .indexWhere((element) => element == workout);
  }

  if (index >= 0) {
    await HiveManager.workoutsBox.putAt(index, workout);

    // Only queue sync if workout has a server ID
    if (workout.id != null && workout.id! > 0) {
      await HiveManager.addPendingOperation(
        PendingOperation(
          entityType: 'workout',
          operationType: SyncOperationType.update,
          workout: workout,
          timestamp: DateTime.now(),
        ),
      );
    }

    workoutList = HiveManager.workoutsBox.values.toList();
    TalkerService.info(
        'Workout update saved locally: ${workout.name}', 'WORKOUT');
  } else {
    throw Exception('Workout not found in local storage');
  }
}
```

- [ ] **Step 5: Verify the app compiles**

Run: `flutter analyze lib/features/Workouts/ lib/features/Exercises/`
Expected: No errors

- [ ] **Step 6: Commit**

```bash
git add lib/features/Workouts/presentation/providers/workout_provider.dart lib/features/Exercises/presentation/screens/exercise_details_screen.dart
git commit -m "fix: support editing exercises and sets on offline-created workouts"
```

---

### Task 7: Make `WorkoutItemModel.lastWeight` Immutable

**Why:** `lastWeight` at `workoutset_model.dart:17` is a mutable `num` field on a Hive-persisted model. Code like `workoutItem.lastWeight = newWeight` (line 77 in workout_provider) mutates Hive's in-memory cache directly, risking stale/corrupt state if read concurrently. All other fields on the model are `final`.

**Files:**
- Modify: `lib/features/Workouts/data/models/workoutset_model.dart:17`
- Modify: `lib/features/Workouts/presentation/providers/workout_provider.dart` (3 mutation sites)

- [ ] **Step 1: Verify all mutation sites**

Run: `grep -rn "\.lastWeight\s*=" lib/` to confirm there are exactly 3 mutation sites in workout_provider.dart (lines 77, 586, 630) and 0 outside it. The local variable `lastWeight = 0.0` in `workoutset_model.dart:48` is a local variable in `fromMap()`, not a field mutation — it's fine.

- [ ] **Step 2: Make `lastWeight` final**

In `workoutset_model.dart`, change line 17:

```dart
// OLD:
  num lastWeight;

// NEW:
  final num lastWeight;
```

- [ ] **Step 3: Delete the direct mutation at line 77 in `applyWeightToAllSets`**

Delete this line entirely:

```dart
// DELETE this line (line 77):
workoutItem.lastWeight = newWeight;
```

Then update lines 84-85 to include `lastWeight` in the `copyWith`:

```dart
// OLD (lines 84-85):
resolvedWorkout.workoutItems![itemIndex] =
    workoutItem.copyWith(sets: updatedSets);

// NEW:
resolvedWorkout.workoutItems![itemIndex] =
    workoutItem.copyWith(lastWeight: newWeight, sets: updatedSets);
```

- [ ] **Step 4: Fix mutation at line 586 in `updateLastWeightForOfflineWorkout`**

```dart
// OLD (line 586):
storedWorkout.workoutItems![exerciseIndex].lastWeight = weight;

// NEW:
storedWorkout.workoutItems![exerciseIndex] =
    storedWorkout.workoutItems![exerciseIndex].copyWith(lastWeight: weight);
```

- [ ] **Step 5: Fix mutation at line 630 in `updateLastWeightLocal`**

```dart
// OLD (line 630):
workout.workoutItems![exerciseIndex].lastWeight = weight;

// NEW:
workout.workoutItems![exerciseIndex] =
    workout.workoutItems![exerciseIndex].copyWith(lastWeight: weight);
```

- [ ] **Step 6: Run code generation** (Hive adapters need regeneration after making field final)

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Build completes successfully

- [ ] **Step 7: Verify the app compiles**

Run: `flutter analyze lib/`
Expected: No errors

- [ ] **Step 8: Commit**

```bash
git add lib/features/Workouts/data/models/workoutset_model.dart lib/features/Workouts/data/models/workoutset_model.g.dart lib/features/Workouts/presentation/providers/workout_provider.dart
git commit -m "refactor: make WorkoutItemModel.lastWeight immutable, use copyWith for all mutations"
```

---

### Task 8: Remove Redundant Hive Add in Online Create Path

**Why:** In `createWorkoutSet()` (line 171-180), the online path calls the server first, then adds to Hive at line 174, then calls `getWorkoutSets()` which clears and repopulates Hive. The explicit `add()` at line 174 creates a brief duplicate before `getWorkoutSets()` clears it. Remove the redundant add.

**Note:** If `getWorkoutSets()` fails after server create succeeds, the workout won't appear locally until next refresh. This is acceptable — the fallback path in `getWorkoutSets()` loads from existing Hive, and the workout will appear on the next successful refresh.

**Files:**
- Modify: `lib/features/Workouts/presentation/providers/workout_provider.dart:149-212`

- [ ] **Step 1: Remove redundant Hive add in online create path**

Replace lines 171-182:

```dart
// OLD:
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
}

// NEW:
if (_isOnline) {
  // Online: Create on server, then refresh list (which updates Hive)
  await _workoutRepo.createWorkoutSet(newWorkout);
  await SharedPref.setInt(
      StorageKeys.numberOfWorkouts, numberOfWorkouts + 1);
  await getWorkoutSets();
  TalkerService.info(
      'Workout created online: ${newWorkout.name}', 'WORKOUT');
}
```

- [ ] **Step 2: Verify the app compiles**

Run: `flutter analyze lib/features/Workouts/presentation/providers/`
Expected: No errors

- [ ] **Step 3: Commit**

```bash
git add lib/features/Workouts/presentation/providers/workout_provider.dart
git commit -m "fix: remove redundant Hive add in online createWorkoutSet to prevent duplicates"
```

---

### Task 9: Final Integration Verification

- [ ] **Step 1: Run full static analysis**

Run: `flutter analyze`
Expected: No errors (warnings are acceptable)

- [ ] **Step 2: Run code generation to ensure all Hive adapters are up-to-date**

Run: `dart run build_runner build --delete-conflicting-outputs`
Expected: Build completes successfully

- [ ] **Step 3: Run all existing tests**

Run: `flutter test`
Expected: All tests pass

- [ ] **Step 4: Manual smoke test checklist (offline CRUD)**

1. Turn off network -> Create a workout -> Verify it appears in list
2. Edit the offline workout name -> Verify name updates
3. Add sets to an exercise in the offline workout -> Verify sets appear
4. Delete the offline workout -> Verify it disappears
5. Turn on network -> Verify sync toast appears -> Verify workout list refreshes with server IDs
6. Create another workout offline -> Update it -> Turn on network -> Verify only the latest state syncs

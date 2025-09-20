import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:oktoast/oktoast.dart';

final syncServiceProvider = StateNotifierProvider<SyncService, bool>((ref) {
  final workoutRepository = ref.read(workoutRepo);
  return SyncService(workoutRepository);
});

class SyncService extends StateNotifier<bool> {
  final WorkoutRepo workoutRepo;

  SyncService(this.workoutRepo) : super(false) {
    // Initialize and check for pending operations on startup
    _initSync();
  }

  bool get isLoading => state;
  Future<void> syncPendingOperations() async {
    if (!ConnectivityChecker.isOnline!) return;
    try {
      // Get all pending operations
      state = true; // Set loading to true
      final List<PendingOperation> pendingOps =
          HiveManager.pendingOpsBox.values.toList();
      AppLogger.info('Found ${pendingOps.length} pending operations', 'SYNC');

      // Skip sync if no operations
      if (pendingOps.isEmpty) {
        state = false;
        return;
      }

      // Sort operations by timestamp to maintain order
      pendingOps.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      List<int?> successfullyProcessedIds = [];

      for (final op in pendingOps) {
        try {
          if (op.entityType == 'workout') {
            switch (op.operationType) {
              case SyncOperationType.create:
                if (op.workout != null) {
                  AppLogger.info(
                      'Creating workout: ${op.workout!.name}', 'SYNC');
                  await workoutRepo.createWorkoutSet(op.workout!);
                }
                break;

              case SyncOperationType.update:
                final workout = op.workout!;
                await workoutRepo.updateWorkoutSet(workout);
                break;

              case SyncOperationType.delete:
                if (op.id != null) {
                  await workoutRepo.deleteWorkoutSet(op.id!);
                }
                break;

              case SyncOperationType.reorder:
                await workoutRepo.reorderWorkoutsList(op.reorderWorkoutList!);
                break;
            }
          } else if (op.entityType == 'workout_weight') {
            await workoutRepo.updateLastWeight(
              op.workout!.id!,
              op.exerciseId!,
              op.weight!,
            );
          }
          successfullyProcessedIds.add(op.id);
        } on Exception catch (e) {
          AppLogger.error('Error processing operation ${op.id}', 'SYNC', e);
          // Continue with next operation instead of failing entire sync
          continue;
        }
      }
      // Clear processed operations
      await HiveManager.clearPendingOperations();
      showToast('synced with server'.capitalizeWord(),
          position: ToastPosition.bottom,
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
          textPadding: const EdgeInsets.all(10),
          textStyle: const TextStyle(
              fontSize: 14, color: Colors.white, fontWeight: FontWeight.w500));
      state = false; // Set loading to false
      AppLogger.info('All pending operations synced with server', 'SYNC');
    } catch (e) {
      await HiveManager.clearPendingOperations();
      AppLogger.error('Error during sync', 'SYNC', e);
      state = false; // Set loading to false on error too
    }
  }

  // Initialize sync on app startup
  Future<void> _initSync() async {
    // Wait a moment for the app to fully initialize
    await Future.delayed(const Duration(seconds: 2));

    // Check if there are pending operations and if we're online
    if (HiveManager.pendingOpsBox.isNotEmpty &&
        ConnectivityChecker.isOnline == true) {
      AppLogger.info(
          'Found pending operations on app startup, attempting to sync',
          'SYNC');
      await syncPendingOperations();
    }
  }
}

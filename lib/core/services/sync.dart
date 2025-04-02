import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final syncingProvider = StateProvider<bool>((ref) => false);

class SyncService {
  final WorkoutRepo workoutRepo;

  SyncService(this.workoutRepo);

  Future<void> syncPendingOperations() async {
    if (!ConnectivityChecker.isOnline!) return;
    try {
      // Get all pending operations
      final List<PendingOperation> pendingOps =
          HiveManager.pendingOpsBox.values.toList();
      debugPrint('Found ${pendingOps.length} pending operations');
      // Sort operations by timestamp to maintain order
      pendingOps.sort((a, b) => a.timestamp.compareTo(b.timestamp));

      for (final op in pendingOps) {
        if (op.entityType == 'workout') {
          switch (op.operationType) {
            case SyncOperationType.create:
              final workout = op.workout!;
              debugPrint('Creating workout: ${workout.name}');
              await workoutRepo.createWorkoutSet(workout);
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
          }
        } else if (op.entityType == 'workout_weight') {
          await workoutRepo.updateLastWeight(
            op.workout!.id!,
            op.exerciseId!,
            op.weight!,
          );
        }
      }

      // // Refresh from server to ensure consistency
      // if (pendingOps.isNotEmpty) {
      //   debugPrint('Refreshing workouts from server...');
      //   await workoutRepo.getWorkoutSets();
      // }

      // Clear processed operations
      await HiveManager.clearPendingOperations();

      debugPrint('All pending operations synced with server');
    } catch (e) {
      debugPrint('Error during sync: $e');
    }
  }
}

final syncServiceProvider = Provider((ref) {
  final workout_repo = ref.read(workoutRepo);
  return SyncService(workout_repo);
});

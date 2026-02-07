import 'dart:math' as math;

import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:oktoast/oktoast.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

final syncServiceProvider =
    NotifierProvider<SyncService, SyncState>(SyncService.new);

class SyncService extends Notifier<SyncState> {
  static const int _maxRetries = 5;
  static const Duration _baseDelay = Duration(seconds: 2);
  static const Duration _maxDelay = Duration(minutes: 5);

  late WorkoutRepo workoutRepository;
  late ProductWriteRepository foodSearchRepository;

  bool get isLoading => state.isLoading;

  @override
  SyncState build() {
    workoutRepository = ref.read(workoutRepo);
    foodSearchRepository = ref.read(productWriteRepositoryProvider);
    _initSync();
    return SyncState(
      pendingWorkouts: HiveManager.pendingOpsBox.length,
      pendingProducts: HiveManager.pendingProductsBox.length,
    );
  }

  /// Refreshes the pending counts without syncing.
  void refreshPendingCounts() {
    state = state.copyWith(
      pendingWorkouts: HiveManager.pendingOpsBox.length,
      pendingProducts: HiveManager.pendingProductsBox.length,
    );
  }

  Future<void> syncPendingOperations() async {
    if (!ConnectivityChecker.isOnline!) return;
    try {
      state = state.copyWith(isLoading: true);

      // Sync workouts
      await _syncWorkouts();

      // Sync products
      await _syncProducts();

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

  /// Calculates exponential backoff delay.
  Duration _calculateBackoff(int retryCount) {
    final delay = _baseDelay * math.pow(2, retryCount).toInt();
    return delay > _maxDelay ? _maxDelay : delay;
  }

  // Initialize sync on app startup
  Future<void> _initSync() async {
    await Future.delayed(const Duration(seconds: 2));

    final hasPendingOps = HiveManager.pendingOpsBox.isNotEmpty;
    final hasPendingProducts = HiveManager.pendingProductsBox.isNotEmpty;

    if ((hasPendingOps || hasPendingProducts) &&
        ConnectivityChecker.isOnline == true) {
      TalkerService.info(
        'Found pending operations on app startup, attempting to sync',
        'SYNC',
      );
      await syncPendingOperations();
    }
  }

  /// Syncs pending product uploads with exponential backoff.
  Future<void> _syncProducts() async {
    final pendingUploads = HiveManager.getPendingProductUploads();

    if (pendingUploads.isEmpty) return;

    TalkerService.info(
      'Found ${pendingUploads.length} pending product uploads',
      'SYNC',
    );

    final uploadsToRemove = <PendingProductUpload>[];

    for (final upload in pendingUploads) {
      // Skip if max retries exceeded
      if (upload.isMaxRetriesExceeded) {
        TalkerService.warning(
          'Max retries exceeded for product: ${upload.product.barcode}, removing',
          'SYNC',
        );
        uploadsToRemove.add(upload);
        continue;
      }

      try {
        // Use the domain entity conversion
        final entity = upload.toEntity();

        // Create a temporary user for sync (would normally come from auth)
        final user = User(userId: 'sync-user', password: '');

        // Attempt submission using the new repository method
        final success = await foodSearchRepository.submitProduct(
          product: entity,
          user: user,
          imagePath: null, // Image path not stored in new model structure
          isUpdate: false, // Determine update status from product ID
        );

        if (success) {
          TalkerService.info(
            'Successfully synced product: ${upload.product.barcode}',
            'SYNC',
          );
          uploadsToRemove.add(upload);
        } else {
          // Increment retry and apply backoff
          upload.incrementRetryCount();
          await upload.save();

          final backoff = _calculateBackoff(upload.retryCount);
          TalkerService.warning(
            'Product sync failed, retry ${upload.retryCount}/$_maxRetries, '
                'next attempt in ${backoff.inSeconds}s',
            'SYNC',
          );
        }
      } catch (e) {
        TalkerService.error(
          'Error syncing product: ${upload.product.barcode}',
          'SYNC',
          e,
        );
        upload.incrementRetryCount();
        await upload.save();
      }
    }

    // Remove successful uploads
    for (final upload in uploadsToRemove) {
      await HiveManager.removePendingProductUpload(upload);
    }
  }

  /// Syncs pending workout operations.
  Future<void> _syncWorkouts() async {
    final List<PendingOperation> pendingOps =
        HiveManager.pendingOpsBox.values.toList();

    if (pendingOps.isEmpty) return;

    TalkerService.info(
      'Found ${pendingOps.length} pending workout operations',
      'SYNC',
    );

    pendingOps.sort((a, b) => a.timestamp.compareTo(b.timestamp));

    for (final op in pendingOps) {
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
          // Sync exercise sets update
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
      } on Exception catch (e) {
        TalkerService.error('Error processing operation ${op.id}', 'SYNC', e);
        continue;
      }
    }

    await HiveManager.clearPendingOperations();
  }
}

/// State for sync service.
class SyncState {
  final bool isLoading;
  final int pendingWorkouts;
  final int pendingProducts;

  const SyncState({
    this.isLoading = false,
    this.pendingWorkouts = 0,
    this.pendingProducts = 0,
  });

  bool get hasPendingItems => pendingWorkouts > 0 || pendingProducts > 0;
  int get totalPending => pendingWorkouts + pendingProducts;

  SyncState copyWith({
    bool? isLoading,
    int? pendingWorkouts,
    int? pendingProducts,
  }) {
    return SyncState(
      isLoading: isLoading ?? this.isLoading,
      pendingWorkouts: pendingWorkouts ?? this.pendingWorkouts,
      pendingProducts: pendingProducts ?? this.pendingProducts,
    );
  }
}

import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_upload_status.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/Workouts/data/models/exercise_set_record_model.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:hive_ce/hive.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

class HiveManager {
  static late Box<ExerciseModel> exercisesBox;
  static late Box<MuscleModel> musclesBox;
  static late Box<WorkoutSetModel> workoutsBox;
  static late Box<WorkoutSetModel> predefinedWorkoutsBox;
  static late Box<PendingOperation> pendingOpsBox;

  // Food Search boxes
  static late Box<FoodProductModel> foodProductsBox;
  static late Box<FavoriteFoodModel> favoriteFoodsBox;
  static late Box<SearchHistoryModel> searchHistoryBox;
  static late Box<PendingProductUpload> pendingProductsBox;

  // Update or add this method to ensure operations are properly stored
  static Future<void> addPendingOperation(PendingOperation operation) async {
    await pendingOpsBox.add(operation);
    TalkerService.debug(
        'Added pending operation: ${operation.operationType}, total count: ${pendingOpsBox.length}',
        'HIVE');
  }

  // Pending product upload methods
  static Future<void> addPendingProductUpload(
      PendingProductUpload upload) async {
    await pendingProductsBox.put(upload.id, upload);
    TalkerService.debug(
        'Added pending product upload: ${upload.product.barcode}, '
            'total count: ${pendingProductsBox.length}',
        'HIVE');
  }

  /// Gets all pending uploads.
  static List<PendingProductUpload> getPendingProductUploads() {
    TalkerService.debug(
        'Getting pending product uploads, count: ${pendingProductsBox.length}',
        'HIVE');
    return pendingProductsBox.values.toList();
  }

  /// Gets all pending uploads with given status.
  static List<PendingProductUpload> getPendingUploadsByStatus(
    PendingUploadStatus status,
  ) {
    return pendingProductsBox.values
        .where((upload) => upload.status == status)
        .toList();
  }

  /// Gets uploads eligible for retry (failed, not at max retries).
  static List<PendingProductUpload> getPendingUploadsEligibleForRetry() {
    return pendingProductsBox.values
        .where((upload) => upload.canRetry)
        .toList();
  }

  /// Removes a pending upload by ID.
  static Future<void> removePendingProductUploadById(String uploadId) async {
    await pendingProductsBox.delete(uploadId);
    TalkerService.debug('Removed pending product upload: $uploadId', 'HIVE');
  }

  /// Updates a pending upload's retry count and status.
  static Future<void> updatePendingUploadStatus(
    String uploadId,
    PendingUploadStatus status, {
    String? failureReason,
  }) async {
    final upload = pendingProductsBox.get(uploadId);
    if (upload != null) {
      if (status == PendingUploadStatus.uploading) {
        upload.markUploading();
      } else if (status == PendingUploadStatus.failed) {
        upload.markFailed(failureReason);
      } else if (status == PendingUploadStatus.pending) {
        upload.markSuccessful();
      }
      await upload.save();
      TalkerService.debug(
          'Updated pending upload $uploadId status to $status', 'HIVE');
    }
  }

  // Clear pending operations
  static Future<void> clearPendingOperations() async {
    await pendingOpsBox.clear();
  }

  /// Deletes a workout from Hive.
  /// For server workouts (id > 0), finds by server ID.
  /// For offline workouts (no server ID), deletes via the HiveObject's own
  /// box key — avoids equality-based matching which breaks when createdAt
  /// is null across multiple workouts.
  /// Returns true if a workout was found and deleted.
  static Future<bool> deleteWorkoutFromBox({
    int? workoutId,
    WorkoutSetModel? workout,
  }) async {
    if (workoutId != null && workoutId > 0) {
      for (final key in workoutsBox.keys) {
        final stored = workoutsBox.get(key);
        if (stored != null && stored.id == workoutId) {
          await workoutsBox.delete(key);
          return true;
        }
      }
      return false;
    }

    if (workout != null && workout.isInBox) {
      await workout.delete();
      return true;
    }

    return false;
  }

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

  static Future<void> clearPendingProductUploads() async {
    await pendingProductsBox.clear();
    TalkerService.debug('Cleared all pending product uploads', 'HIVE');
  }

  static List<PendingOperation> getPendingOperations() {
    TalkerService.debug(
        'Getting pending operations, count: ${pendingOpsBox.length}', 'HIVE');
    return pendingOpsBox.values.toList();
  }

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ExerciseModelAdapter());
    Hive.registerAdapter(MuscleModelAdapter());
    Hive.registerAdapter(WorkoutSetModelAdapter());
    Hive.registerAdapter(WorkoutItemModelAdapter());
    Hive.registerAdapter(ExerciseSetRecordModelAdapter());
    Hive.registerAdapter(PendingOperationAdapter());
    Hive.registerAdapter(SyncOperationTypeAdapter());

    // Register Food Search adapters
    Hive.registerAdapter(FoodProductModelAdapter());
    Hive.registerAdapter(NutritionValuesModelAdapter());
    Hive.registerAdapter(SearchHistoryModelAdapter());
    Hive.registerAdapter(SearchTypeAdapter());
    Hive.registerAdapter(FavoriteFoodModelAdapter());
    Hive.registerAdapter(PendingProductUploadAdapter());
    Hive.registerAdapter(PendingUploadStatusAdapter());

    musclesBox = await Hive.openBox<MuscleModel>('muscles');
    exercisesBox = await Hive.openBox<ExerciseModel>('exercises');
    workoutsBox = await Hive.openBox<WorkoutSetModel>('workouts');
    predefinedWorkoutsBox =
        await Hive.openBox<WorkoutSetModel>('predefinedWorkouts');
    pendingOpsBox = await Hive.openBox<PendingOperation>("pendingOperations");

    // Open Food Search boxes
    foodProductsBox = await Hive.openBox<FoodProductModel>('foodProducts');
    favoriteFoodsBox = await Hive.openBox<FavoriteFoodModel>('favoriteFoods');
    searchHistoryBox = await Hive.openBox<SearchHistoryModel>('searchHistory');
    pendingProductsBox =
        await Hive.openBox<PendingProductUpload>('pendingProducts');
  }

  static Future<void> removePendingProductUpload(
      PendingProductUpload upload) async {
    await upload.delete();
    TalkerService.debug(
        'Removed pending product upload: ${upload.product.barcode}', 'HIVE');
  }

  static Future<void> saveToHive(Box box, List data) async {
    try {
      await box.clear();
      for (int i = 0; i < data.length; i++) {
        await box.put(i, data[i]);
      }
    } catch (e) {
      TalkerService.error('Failed to save data to Hive', 'HIVE', e);
    }
  }
}

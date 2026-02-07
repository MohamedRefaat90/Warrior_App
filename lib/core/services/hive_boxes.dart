import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/Workouts/data/models/exercise_set_record_model.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:hive_flutter/hive_flutter.dart';

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

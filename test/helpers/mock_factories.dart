/// Mock factories for FoodSearch feature tests
///
/// This library provides factory functions for creating mock objects
/// and fakes used in FoodSearch unit and widget tests.
library;

import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';

/// Factory for creating mock FoodProductModel instances
class MockFoodProductModelFactory {
  /// Creates a valid FoodProductModel with default values
  static FoodProductModel create({
    String? barcode,
    String? productName,
    String? brands,
    String? quantity,
    NutritionFacts? nutrition,
    String? imagePath,
    DateTime? cachedAt,
  }) {
    return FoodProductModel(
      barcode: barcode ?? '5449000000996',
      productName: productName ?? 'Mock Product',
      brands: brands ?? 'Mock Brand',
      quantity: quantity ?? '100g',
      nutrition: nutrition ??
          NutritionFacts(
            caloriesPerHundred: 100,
            protein: 5,
            carbohydrates: 20,
            fat: 3,
            fiber: 2,
          ),
      imagePath: imagePath,
      cachedAt: cachedAt ?? DateTime.now(),
    );
  }

  /// Creates multiple FoodProductModel instances
  static List<FoodProductModel> createList({int count = 5}) {
    return List.generate(
      count,
      (index) => create(
        barcode: '${5449000000990 + index}',
        productName: 'Mock Product $index',
      ),
    );
  }

  /// Creates a cached FoodProductModel (with cachedAt set to past)
  static FoodProductModel createCached({
    Duration? cacheAge,
    String? barcode,
  }) {
    final age = cacheAge ?? const Duration(hours: 2);
    return create(
      barcode: barcode ?? '5449000000996',
      cachedAt: DateTime.now().subtract(age),
    );
  }

  /// Creates a stale FoodProductModel (cache older than 7 days)
  static FoodProductModel createStale({String? barcode}) {
    return createCached(
      barcode: barcode ?? '5449000000996',
      cacheAge: const Duration(days: 8),
    );
  }
}

/// Factory for creating mock PendingProductUpload instances
class MockPendingProductUploadFactory {
  /// Creates a pending (queued) PendingProductUpload
  static PendingProductUpload createPending({
    String? id,
    String? barcode,
    String? productName,
  }) {
    final product = MockFoodProductModelFactory.create(
      barcode: barcode ?? '5449000000996',
      productName: productName ?? 'Pending Product',
    );

    return PendingProductUpload(
      id: id ?? 'pending_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      queuedAt: DateTime.now(),
      retryCount: 0,
      status: PendingUploadStatus.pending,
    );
  }

  /// Creates a failed PendingProductUpload with retry count
  static PendingProductUpload createFailed({
    String? id,
    int? retryCount,
    String? failureReason,
  }) {
    final product = MockFoodProductModelFactory.create();

    return PendingProductUpload(
      id: id ?? 'failed_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      queuedAt: DateTime.now().subtract(const Duration(minutes: 30)),
      retryCount: retryCount ?? 1,
      status: PendingUploadStatus.failed,
      lastAttemptAt: DateTime.now().subtract(const Duration(minutes: 5)),
      failureReason: failureReason ?? 'Network error',
    );
  }

  /// Creates an uploading PendingProductUpload
  static PendingProductUpload createUploading({String? id}) {
    final product = MockFoodProductModelFactory.create();

    return PendingProductUpload(
      id: id ?? 'uploading_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      queuedAt: DateTime.now().subtract(const Duration(minutes: 10)),
      retryCount: 0,
      status: PendingUploadStatus.uploading,
      lastAttemptAt: DateTime.now(),
    );
  }

  /// Creates a PendingProductUpload at max retries (3)
  static PendingProductUpload createMaxRetries({String? id}) {
    final product = MockFoodProductModelFactory.create();

    return PendingProductUpload(
      id: id ?? 'max_retries_${DateTime.now().millisecondsSinceEpoch}',
      product: product,
      queuedAt: DateTime.now().subtract(const Duration(hours: 1)), // Old queue
      retryCount: 3,
      status: PendingUploadStatus.failed,
      lastAttemptAt: DateTime.now().subtract(const Duration(minutes: 2)),
      failureReason: 'Max retries exceeded',
    );
  }

  /// Creates multiple pending uploads
  static List<PendingProductUpload> createList({int count = 5}) {
    return List.generate(
      count,
      (index) => createPending(
        barcode: '${5449000000990 + index}',
        productName: 'Pending Product $index',
      ),
    );
  }
}

/// Enum for pending upload status (mirrors domain enum)
enum PendingUploadStatus {
  pending,
  uploading,
  failed,
}

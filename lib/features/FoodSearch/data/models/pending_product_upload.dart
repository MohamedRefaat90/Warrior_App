import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:hive/hive.dart';

part 'pending_product_upload.g.dart';

/// Model for storing product uploads pending synchronization.
///
/// This is used for offline-first functionality, allowing products to be
/// submitted when offline and synced when connectivity is restored.
@HiveType(typeId: 20)
class PendingProductUpload extends HiveObject {
  /// The product barcode.
  @HiveField(0)
  final String barcode;

  /// Product data serialized as JSON map.
  ///
  /// Contains all product fields like name, brands, categories, etc.
  @HiveField(1)
  final Map<String, dynamic> productData;

  /// Nutrition facts associated with the product.
  @HiveField(2)
  final NutritionValuesModel? nutritionFacts;

  /// Local path to the product image (if any).
  @HiveField(3)
  final String? imagePath;

  /// Timestamp when the upload was queued.
  @HiveField(4)
  final DateTime timestamp;

  /// Number of retry attempts for this upload.
  @HiveField(5)
  int retryCount;

  /// The type of operation (create or update).
  @HiveField(6)
  final SyncOperationType operationType;

  PendingProductUpload({
    required this.barcode,
    required this.productData,
    this.nutritionFacts,
    this.imagePath,
    DateTime? timestamp,
    this.retryCount = 0,
    required this.operationType,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Increments the retry count.
  void incrementRetryCount() {
    retryCount++;
  }

  @override
  String toString() {
    return 'PendingProductUpload('
        'barcode: $barcode, '
        'operationType: $operationType, '
        'retryCount: $retryCount, '
        'timestamp: $timestamp)';
  }
}

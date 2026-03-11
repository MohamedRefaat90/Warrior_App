import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_upload_status.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:hive/hive.dart';

part 'pending_product_upload.g.dart';

/// Model for storing product uploads pending synchronization.
///
/// This is used for offline-first functionality, allowing products to be
/// submitted when offline and synced when connectivity is restored.
///
/// Enhanced with retry tracking, status management, and failure diagnostics
/// to support robust offline sync workflows.
@HiveType(typeId: 20)
class PendingProductUpload extends HiveObject {
  /// Unique identifier for this pending upload.
  @HiveField(0)
  final String id;

  /// The product being uploaded.
  @HiveField(1)
  final FoodProductModel product;

  /// Timestamp when the upload was queued.
  @HiveField(2)
  final DateTime queuedAt;

  /// Number of retry attempts for this upload.
  @HiveField(3)
  int retryCount;

  /// Current status of the upload (pending, uploading, failed).
  @HiveField(4)
  final PendingUploadStatus status;

  /// Timestamp of the last upload attempt (if any).
  @HiveField(5)
  DateTime? lastAttemptAt;

  /// Reason for last failure (if status is failed).
  @HiveField(6)
  String? failureReason;

  PendingProductUpload({
    required this.id,
    required this.product,
    required this.queuedAt,
    this.retryCount = 0,
    this.status = PendingUploadStatus.pending,
    this.lastAttemptAt,
    this.failureReason,
  });

  /// Whether this upload is eligible for retry.
  bool get canRetry =>
      !isMaxRetriesExceeded && status == PendingUploadStatus.failed;

  /// Whether this upload has exceeded max retries (3).
  bool get isMaxRetriesExceeded => retryCount >= 3;

  /// Increments the retry count.
  void incrementRetryCount() {
    retryCount++;
  }

  /// Marks this upload as failed with optional reason.
  void markFailed(String? reason) {
    lastAttemptAt = DateTime.now();
    failureReason = reason;
  }

  /// Marks this upload as successfully completed.
  void markSuccessful() {
    lastAttemptAt = DateTime.now();
  }

  /// Marks this upload as currently uploading.
  void markUploading() {
    lastAttemptAt = DateTime.now();
  }

  /// Converts this pending upload to a [ProductEntity].
  ProductEntity toEntity() {
    return ProductEntity(
      barcode: product.barcode,
      productName: product.productName,
      brands: product.brands,
      countries: product.countries,
      quantity: product.quantity,
      servingSize: product.servingSize,
      ingredients: product.ingredients,
      nutrition: product.nutritionValues?.toEntity(),
      lastUpdated: queuedAt,
    );
  }

  @override
  String toString() {
    return 'PendingProductUpload('
        'id: $id, '
        'barcode: ${product.barcode}, '
        'status: $status, '
        'retryCount: $retryCount, '
        'queuedAt: $queuedAt)';
  }
}

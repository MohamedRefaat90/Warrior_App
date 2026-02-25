import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

abstract class ProductWriteRepository {
  /// Delete a pending product upload from the queue
  Future<void> deletePendingUpload(String uploadId);

  /// Get count of products waiting to be uploaded (offline queue)
  int getPendingProductCount();

  /// Get the list of pending product uploads
  List<PendingProductUpload> getPendingProductUploads();

  /// Retry uploading a pending product
  Future<PendingProductUpload> retryPendingUpload(String uploadId);

  /// Submit product with optional nutrition and image (handles offline queueing)
  Future<bool> submitProduct({
    required ProductEntity product,
    required User user,
    String? imagePath,
  });
}

import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

abstract class ProductWriteRepository {
  /// Add a new product to Open Food Facts
  Future<bool> addNewProduct(ProductEntity product, User user);

  /// Delete a pending product upload from the queue
  Future<void> deletePendingUpload(String uploadId);

  /// Get count of products waiting to be uploaded (offline queue)
  int getPendingProductCount();

  /// Get the list of pending product uploads
  List<PendingProductUpload> getPendingProductUploads();

  /// Retry uploading a pending product
  Future<PendingProductUpload> retryPendingUpload(String uploadId);

  /// Complex method to submit product with nutrition (handles offline queueing)
  Future<bool> submitProduct({
    required ProductEntity product,
    required User user,
    String? imagePath,
    bool isUpdate = false,
  });

  /// Update an existing product on Open Food Facts
  Future<bool> updateProduct(ProductEntity product, User user);

  /// Upload a product image
  Future<bool> uploadProductImage({
    required String barcode,
    required String imagePath,
    required ImageField imageField,
    required User user,
  });
}

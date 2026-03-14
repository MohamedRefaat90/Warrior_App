import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductWriteRepositoryImpl implements ProductWriteRepository {
  final FoodRemoteDataSource _remoteDataSource;

  ProductWriteRepositoryImpl({
    required FoodRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> deletePendingUpload(String uploadId) async {
    try {
      await HiveManager.removePendingProductUploadById(uploadId);
    } catch (e, stackTrace) {
      TalkerService.error(
        'Error in deletePendingUpload',
        'FOOD_WRITE_REPO',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  int getPendingProductCount() {
    return HiveManager.getPendingProductUploads().length;
  }

  @override
  List<PendingProductUpload> getPendingProductUploads() {
    return HiveManager.getPendingProductUploads();
  }

  @override
  Future<PendingProductUpload> retryPendingUpload(String uploadId) async {
    try {
      final uploads = HiveManager.getPendingProductUploads();
      final upload = uploads.firstWhere(
        (u) => u.id == uploadId,
        orElse: () => throw Exception('Pending upload not found: $uploadId'),
      );

      if (!upload.canRetry) {
        throw Exception(
          'Upload has exceeded maximum retries (3 attempts)',
        );
      }

      // Increment retry count and mark as uploading
      upload.incrementRetryCount();
      upload.markUploading();
      await upload.save();

      TalkerService.info(
        'Retrying pending upload: $uploadId (Attempt ${upload.retryCount}/3)',
        'FOOD_WRITE_REPO',
      );

      // Attempt to upload if online
      if (ConnectivityChecker.isOnline == true) {
        try {
          final String? user_id =
              await SecureStorageHandler.read(key: StorageKeys.offUserId);
          final String? password =
              await SecureStorageHandler.read(key: StorageKeys.offPassword);

          // Convert pending product to OFF format
          final offProduct = _entityToOFFProduct(upload.product.toEntity());

          final success = await _remoteDataSource.saveProduct(
            offProduct,
            User(userId: user_id ?? "", password: password ?? ""),
          );

          if (success) {
            upload.markSuccessful();
            await upload.save();
            TalkerService.info(
              'Pending upload successful: $uploadId',
              'FOOD_WRITE_REPO',
            );
          } else {
            upload.markFailed('Server rejected the product');
            await upload.save();
          }
        } catch (e) {
          upload.markFailed('Network error: ${e.toString()}');
          await upload.save();
          TalkerService.warning(
            'Retry attempt failed: $e',
            'FOOD_WRITE_REPO',
          );
        }
      } else {
        // Keep as uploading status to retry when back online
        TalkerService.info(
          'Device offline: Pending upload queued for retry',
          'FOOD_WRITE_REPO',
        );
      }

      return upload;
    } catch (e, stackTrace) {
      TalkerService.error(
        'Error in retryPendingUpload',
        'FOOD_WRITE_REPO',
        e,
        stackTrace,
      );
      rethrow;
    }
  }

  @override
  Future<bool> submitProduct({
    required ProductEntity product,
    required User user,
    String? imagePath,
  }) async {
    try {
      // Convert entity directly to OFF Product with nutrition included
      final offProduct = _entityToOFFProduct(product);

      if (ConnectivityChecker.isOnline == true) {
        final success = await _remoteDataSource.saveProduct(offProduct, user);

        if (success) {
          TalkerService.info(
            'Product saved successfully: ${product.barcode}',
            'FOOD_WRITE_REPO',
          );

          // Upload image if provided
          if (imagePath != null) {
            try {
              await _remoteDataSource.uploadProductImage(
                barcode: product.barcode,
                imagePath: imagePath,
                imageField: ImageField.FRONT,
                user: user,
              );
            } catch (imageError) {
              TalkerService.warning(
                'Product saved but image upload failed: $imageError',
                'FOOD_WRITE_REPO',
              );
            }
          }
          return true;
        }

        TalkerService.warning(
          'Direct submission failed, queuing for retry',
          'FOOD_WRITE_REPO',
        );
        await _enqueuePendingProduct(product, imagePath);
        return true;
      } else {
        TalkerService.info(
          'Offline: Queuing product for sync: ${product.barcode}',
          'FOOD_WRITE_REPO',
        );
        await _enqueuePendingProduct(product, imagePath);
        return true;
      }
    } catch (e, stackTrace) {
      TalkerService.error(
        'Error in submitProduct',
        'FOOD_WRITE_REPO',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Convert ProductEntity directly to OFF Product with nutrition
  Product _entityToOFFProduct(ProductEntity entity) {
    final nutriments = entity.nutrition != null
        ? NutritionValuesModel.fromEntity(entity.nutrition!).toOFFNutriments()
        : null;

    return Product(
      barcode: entity.barcode,
      productName: entity.productName,
      brands: entity.brands,
      quantity: entity.quantity,
      countries: entity.countries,
      servingSize: entity.servingSize,
      ingredientsText: entity.ingredients,
      noNutritionData: nutriments == null,
      nutriments: nutriments != null ? Nutriments.fromJson(nutriments) : null,
    );
  }

  /// Queue product for offline upload
  Future<void> _enqueuePendingProduct(
    ProductEntity product,
    String? imagePath,
  ) async {
    final foodProductModel = FoodProductModel.fromEntity(product);

    final pendingUpload = PendingProductUpload(
      id: product.barcode,
      product: foodProductModel,
      queuedAt: DateTime.now(),
    );

    await HiveManager.addPendingProductUpload(pendingUpload);
  }
}

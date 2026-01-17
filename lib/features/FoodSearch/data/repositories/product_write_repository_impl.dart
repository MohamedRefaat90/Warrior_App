import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductWriteRepositoryImpl implements ProductWriteRepository {
  final FoodRemoteDataSource _remoteDataSource;

  ProductWriteRepositoryImpl({
    required FoodRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<bool> addNewProduct(ProductEntity product, User user) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        throw Exception('No internet connection');
      }
      return await _remoteDataSource.addNewProduct(
        FoodProductModel.fromEntity(product).toOpenFoodFactsProduct(),
        user,
      );
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in addNewProduct', 'FOOD_WRITE_REPO', e, stackTrace);
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
  Future<bool> submitProduct({
    required ProductEntity product,
    required User user,
    String? imagePath,
    bool isUpdate = false,
  }) async {
    try {
      final offProduct =
          FoodProductModel.fromEntity(product).toOpenFoodFactsProduct();
      final nutritionModel = product.nutrition != null
          ? NutritionValuesModel.fromEntity(product.nutrition!)
          : null;

      final productWithNutrition =
          _applyNutritionToProduct(offProduct, nutritionModel);

      if (ConnectivityChecker.isOnline == true) {
        final success = isUpdate
            ? await _remoteDataSource.updateProduct(productWithNutrition, user)
            : await _remoteDataSource.addNewProduct(productWithNutrition, user);

        if (success) {
          TalkerService.info(
            'Product ${isUpdate ? "updated" : "created"} successfully: ${product.barcode}',
            'FOOD_WRITE_REPO',
          );

          if (imagePath != null) {
            try {
              await uploadProductImage(
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
        await _enqueuePendingProduct(
          product: offProduct,
          nutrition: nutritionModel,
          imagePath: imagePath,
          isUpdate: isUpdate,
        );
        return true;
      } else {
        TalkerService.info(
          'Offline: Queuing product for sync: ${product.barcode}',
          'FOOD_WRITE_REPO',
        );
        await _enqueuePendingProduct(
          product: offProduct,
          nutrition: nutritionModel,
          imagePath: imagePath,
          isUpdate: isUpdate,
        );
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

  @override
  Future<bool> updateProduct(ProductEntity product, User user) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        throw Exception('No internet connection');
      }
      return await _remoteDataSource.updateProduct(
        FoodProductModel.fromEntity(product).toOpenFoodFactsProduct(),
        user,
      );
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in updateProduct', 'FOOD_WRITE_REPO', e, stackTrace);
      rethrow;
    }
  }

  @override
  Future<bool> uploadProductImage({
    required String barcode,
    required String imagePath,
    required ImageField imageField,
    required User user,
  }) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        throw Exception('No internet connection');
      }
      return await _remoteDataSource.uploadProductImage(
        barcode: barcode,
        imagePath: imagePath,
        imageField: imageField,
        user: user,
      );
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in uploadProductImage', 'FOOD_WRITE_REPO', e, stackTrace);
      rethrow;
    }
  }

  Product _applyNutritionToProduct(
    Product product,
    NutritionValuesModel? nutrition,
  ) {
    if (nutrition == null) return product;

    final nutriments = nutrition.toOFFNutriments();
    return Product(
      barcode: product.barcode,
      productName: product.productName,
      brands: product.brands,
      countries: product.countries,
      quantity: product.quantity,
      servingSize: product.servingSize,
      ingredientsText: product.ingredientsText,
      noNutritionData: false,
      nutriments: Nutriments.fromJson(nutriments),
    );
  }

  Future<void> _enqueuePendingProduct({
    required Product product,
    NutritionValuesModel? nutrition,
    String? imagePath,
    required bool isUpdate,
  }) async {
    if (product.barcode == null) {
      throw Exception('Product barcode is required for offline queue');
    }

    final productData = <String, dynamic>{
      'barcode': product.barcode,
      'productName': product.productName,
      'brands': product.brands,
      'countries': product.countries,
      'quantity': product.quantity,
      'servingSize': product.servingSize,
      'ingredientsText': product.ingredientsText,
    };

    final pendingUpload = PendingProductUpload(
      barcode: product.barcode!,
      productData: productData,
      nutritionFacts: nutrition,
      imagePath: imagePath,
      operationType:
          isUpdate ? SyncOperationType.update : SyncOperationType.create,
    );

    await HiveManager.addPendingProductUpload(pendingUpload);
  }
}

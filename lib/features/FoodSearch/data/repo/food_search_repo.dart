import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_local_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/Workouts/data/models/pending_operations_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

final foodSearchRepoProvider = Provider<FoodSearchRepo>((ref) {
  return FoodSearchRepo();
});

/// Repository for food search feature
/// Implements caching strategy: try cache first, then remote
class FoodSearchRepo {
  final FoodRemoteDataSource _remoteDataSource = FoodRemoteDataSource();
  final FoodLocalDataSource _localDataSource = FoodLocalDataSource();

  /// Add new product to Open Food Facts
  Future<bool> addNewProduct(Product product, User user) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        throw Exception('No internet connection');
      }

      return await _remoteDataSource.addNewProduct(product, user);
    } catch (e, stackTrace) {
      TalkerService.error('Error in addNewProduct', 'FOOD_REPO', e, stackTrace);
      rethrow;
    }
  }

  // Favorites methods
  Future<void> addToFavorites(FoodProductModel product) async {
    return _localDataSource.addToFavorites(product);
  }

  Future<void> clearHistory() async {
    return _localDataSource.clearHistory();
  }

  /// Compare multiple products
  Future<List<FoodProductModel>> compareProducts(List<String> barcodes) async {
    try {
      final products = <FoodProductModel>[];

      for (final barcode in barcodes) {
        final product = await searchProductByBarcode(barcode);
        if (product != null) {
          products.add(product);
        }
      }

      return products;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in compareProducts', 'FOOD_REPO', e, stackTrace);
      rethrow;
    }
  }

  /// Filter products by criteria
  List<FoodProductModel> filterProducts({
    String? nutriScore,
    bool? vegan,
    bool? vegetarian,
    bool? palmOilFree,
    List<String>? allergens,
    int? novaGroup,
  }) {
    try {
      var products = _localDataSource.getCachedProducts();

      if (nutriScore != null) {
        products = products
            .where(
                (p) => p.nutriScore?.toUpperCase() == nutriScore.toUpperCase())
            .toList();
      }

      if (vegan == true) {
        products = products.where((p) => p.isVegan == true).toList();
      }

      if (vegetarian == true) {
        products = products.where((p) => p.isVegetarian == true).toList();
      }

      if (palmOilFree == true) {
        products = products.where((p) => p.palmOilFree == true).toList();
      }

      if (novaGroup != null) {
        products = products.where((p) => p.novaGroup == novaGroup).toList();
      }

      if (allergens != null && allergens.isNotEmpty) {
        products = products.where((p) {
          if (p.allergens == null) return true;
          return !p.allergens!.any((allergen) => allergens
              .any((a) => allergen.toLowerCase().contains(a.toLowerCase())));
        }).toList();
      }

      return products;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in filterProducts', 'FOOD_REPO', e, stackTrace);
      return [];
    }
  }

  List<FavoriteFoodModel> getFavorites() {
    return _localDataSource.getFavorites();
  }

  // History methods
  List<SearchHistoryModel> getHistory({int limit = 20}) {
    return _localDataSource.getHistory(limit: limit);
  }

  /// Gets the count of pending product uploads.
  int getPendingProductCount() {
    return HiveManager.getPendingProductUploads().length;
  }

  /// Gets all pending product uploads.
  List<PendingProductUpload> getPendingProductUploads() {
    return HiveManager.getPendingProductUploads();
  }

  /// Get product from cache by barcode
  FoodProductModel? getProductFromCache(String barcode) {
    return _localDataSource.getCachedProduct(barcode);
  }

  /// Get product suggestions for autocomplete
  Future<List<String>> getProductSuggestions(String query) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        return [];
      }

      return await _remoteDataSource.getProductSuggestions(query);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in getProductSuggestions', 'FOOD_REPO', e, stackTrace);
      return [];
    }
  }

  // Recently scanned
  List<FoodProductModel> getRecentlyScanned({int limit = 10}) {
    return _localDataSource.getRecentlyScanned(limit: limit);
  }

  bool isFavorite(String barcode) {
    return _localDataSource.isFavorite(barcode);
  }

  Future<void> removeFromFavorites(String barcode) async {
    return _localDataSource.removeFromFavorites(barcode);
  }

  /// Search by brand
  Future<List<FoodProductModel>> searchByBrand(
    String brand, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        TalkerService.warning('Offline: searching in cache', 'FOOD_REPO');
        return _searchInCache(brand);
      }

      final products = await _remoteDataSource.searchByBrand(
        brand,
        page: page,
        pageSize: pageSize,
      );

      // Cache all products
      for (final product in products) {
        await _localDataSource.cacheProduct(product);
      }

      return products;
    } catch (e, stackTrace) {
      TalkerService.error('Error in searchByBrand', 'FOOD_REPO', e, stackTrace);
      return _searchInCache(brand);
    }
  }

  /// Search by category
  Future<List<FoodProductModel>> searchByCategory(
    String category, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        TalkerService.warning('Offline: searching in cache', 'FOOD_REPO');
        return _searchInCache(category);
      }

      final products = await _remoteDataSource.searchByCategory(
        category,
        page: page,
        pageSize: pageSize,
      );

      // Cache all products
      for (final product in products) {
        await _localDataSource.cacheProduct(product);
      }

      return products;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchByCategory', 'FOOD_REPO', e, stackTrace);
      return _searchInCache(category);
    }
  }

  /// Search product by barcode with caching
  Future<FoodProductModel?> searchProductByBarcode(String barcode) async {
    try {
      // Try cache first
      final cachedProduct = _localDataSource.getCachedProduct(barcode);

      // If cached and fresh, return it
      if (cachedProduct != null && cachedProduct.isCacheFresh) {
        TalkerService.info('Using cached product: $barcode', 'FOOD_REPO');
        return cachedProduct;
      }

      // Check if online
      if (ConnectivityChecker.isOnline != true) {
        TalkerService.warning('Offline: using cached product', 'FOOD_REPO');
        return cachedProduct; // Return cached even if stale
      }

      // Fetch from remote
      final product = await _remoteDataSource.searchProductByBarcode(barcode);

      if (product != null) {
        // Cache the product
        await _localDataSource.cacheProduct(product);

        // Add to history
        await _localDataSource.addToHistory(SearchHistoryModel(
          searchQuery: barcode,
          timestamp: DateTime.now(),
          resultCount: 1,
          searchType: SearchType.barcode,
        ));

        return product;
      }

      return null;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchProductByBarcode', 'FOOD_REPO', e, stackTrace);

      // Return cached product on error if available
      final cachedProduct = _localDataSource.getCachedProduct(barcode);
      if (cachedProduct != null) {
        TalkerService.info(
            'Returning cached product due to error', 'FOOD_REPO');
        return cachedProduct;
      }

      rethrow;
    }
  }

  /// Search products by name
  Future<List<FoodProductModel>> searchProductsByName(
    String query, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      // Check if online
      if (ConnectivityChecker.isOnline != true) {
        TalkerService.warning('Offline: searching in cache', 'FOOD_REPO');
        return _searchInCache(query);
      }

      final products = await _remoteDataSource.searchProductsByName(
        query,
        page: page,
        pageSize: pageSize,
      );

      // Cache all products
      for (final product in products) {
        await _localDataSource.cacheProduct(product);
      }

      // Add to history
      if (products.isNotEmpty) {
        await _localDataSource.addToHistory(SearchHistoryModel(
          searchQuery: query,
          timestamp: DateTime.now(),
          resultCount: products.length,
          searchType: SearchType.text,
        ));
      }

      return products;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchProductsByName', 'FOOD_REPO', e, stackTrace);

      // Try cache on error
      return _searchInCache(query);
    }
  }

  /// Submit product with nutrition facts.
  ///
  /// Handles both online and offline scenarios:
  /// - Online: Submits directly to Open Food Facts API
  /// - Offline: Queues for later sync
  ///
  /// Returns true if submission was successful or queued.
  Future<bool> submitProductWithNutrition({
    required Product product,
    required User user,
    NutritionValuesModel? nutrition,
    String? imagePath,
    bool isUpdate = false,
  }) async {
    try {
      // Apply nutrition facts to product if provided
      final productWithNutrition = _applyNutritionToProduct(product, nutrition);

      // Check connectivity
      if (ConnectivityChecker.isOnline == true) {
        // Online: Submit directly
        final success = isUpdate
            ? await _remoteDataSource.updateProduct(productWithNutrition, user)
            : await _remoteDataSource.addNewProduct(productWithNutrition, user);

        if (success) {
          TalkerService.info(
            'Product ${isUpdate ? "updated" : "created"} successfully: '
                '${product.barcode}',
            'FOOD_REPO',
          );

          // Upload image if provided
          if (imagePath != null && product.barcode != null) {
            try {
              await uploadProductImage(
                barcode: product.barcode!,
                imagePath: imagePath,
                imageField: ImageField.FRONT,
                user: user,
              );
            } catch (imageError) {
              TalkerService.warning(
                'Product saved but image upload failed: $imageError',
                'FOOD_REPO',
              );
            }
          }

          return true;
        }

        // If submission failed, queue for retry
        TalkerService.warning(
          'Direct submission failed, queuing for retry',
          'FOOD_REPO',
        );
        await _enqueuePendingProduct(
          product: product,
          nutrition: nutrition,
          imagePath: imagePath,
          isUpdate: isUpdate,
        );
        return true;
      } else {
        // Offline: Queue for later sync
        TalkerService.info(
          'Offline: Queuing product for sync: ${product.barcode}',
          'FOOD_REPO',
        );
        await _enqueuePendingProduct(
          product: product,
          nutrition: nutrition,
          imagePath: imagePath,
          isUpdate: isUpdate,
        );
        return true;
      }
    } catch (e, stackTrace) {
      TalkerService.error(
        'Error in submitProductWithNutrition',
        'FOOD_REPO',
        e,
        stackTrace,
      );

      // Try to queue on error for later retry
      try {
        await _enqueuePendingProduct(
          product: product,
          nutrition: nutrition,
          imagePath: imagePath,
          isUpdate: isUpdate,
        );
        TalkerService.info(
          'Product queued for retry after error',
          'FOOD_REPO',
        );
        return true;
      } catch (queueError) {
        TalkerService.error(
          'Failed to queue product',
          'FOOD_REPO',
          queueError,
        );
        return false;
      }
    }
  }

  /// Update existing product
  Future<bool> updateProduct(Product product, User user) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        throw Exception('No internet connection');
      }

      return await _remoteDataSource.updateProduct(product, user);
    } catch (e, stackTrace) {
      TalkerService.error('Error in updateProduct', 'FOOD_REPO', e, stackTrace);
      rethrow;
    }
  }

  /// Upload product image
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
          'Error in uploadProductImage', 'FOOD_REPO', e, stackTrace);
      rethrow;
    }
  }

  /// Applies nutrition values to a Product object.
  Product _applyNutritionToProduct(
    Product product,
    NutritionValuesModel? nutrition,
  ) {
    if (nutrition == null) return product;

    // Create nutriments map from nutrition model
    final nutriments = nutrition.toOFFNutriments();

    // Note: The openfoodfacts package uses Nutriments class
    // We need to create the product with nutriments
    return Product(
      barcode: product.barcode,
      productName: product.productName,
      productNameInLanguages: product.productNameInLanguages,
      brands: product.brands,
      brandsTags: product.brandsTags,
      countries: product.countries,
      countriesTags: product.countriesTags,
      lang: product.lang,
      quantity: product.quantity,
      servingSize: product.servingSize,
      categories: product.categories,
      categoriesTags: product.categoriesTags,
      labels: product.labels,
      labelsTags: product.labelsTags,
      packaging: product.packaging,
      packagingTags: product.packagingTags,
      stores: product.stores,
      storesTags: product.storesTags,
      ingredientsText: product.ingredientsText,
      ingredientsTextInLanguages: product.ingredientsTextInLanguages,
      noNutritionData: false,
      nutriments: Nutriments.fromJson(nutriments),
    );
  }

  /// Enqueues a product for offline sync.
  Future<void> _enqueuePendingProduct({
    required Product product,
    NutritionValuesModel? nutrition,
    String? imagePath,
    required bool isUpdate,
  }) async {
    if (product.barcode == null) {
      throw Exception('Product barcode is required for offline queue');
    }

    // Serialize product data for storage
    final productData = <String, dynamic>{
      'barcode': product.barcode,
      'productName': product.productName,
      'brands': product.brands,
      'countries': product.countries,
      'quantity': product.quantity,
      'servingSize': product.servingSize,
      'categories': product.categories,
      'labels': product.labels,
      'packaging': product.packaging,
      'stores': product.stores,
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

  /// Search in local cache
  List<FoodProductModel> _searchInCache(String query) {
    final allProducts = _localDataSource.getCachedProducts();
    final lowerQuery = query.toLowerCase();

    return allProducts.where((product) {
      final name = product.productName?.toLowerCase() ?? '';
      final brands = product.brands?.toLowerCase() ?? '';
      final barcode = product.barcode.toLowerCase();

      return name.contains(lowerQuery) ||
          brands.contains(lowerQuery) ||
          barcode.contains(lowerQuery);
    }).toList();
  }
}

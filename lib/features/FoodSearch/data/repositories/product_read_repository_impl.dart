import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_local_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

class ProductReadRepositoryImpl implements ProductReadRepository {
  final FoodRemoteDataSource _remoteDataSource;
  final FoodLocalDataSource _localDataSource;

  ProductReadRepositoryImpl({
    required FoodRemoteDataSource remoteDataSource,
    required FoodLocalDataSource localDataSource,
  })  : _remoteDataSource = remoteDataSource,
        _localDataSource = localDataSource;

  @override
  Future<List<ProductEntity>> compareProducts(List<String> barcodes) async {
    final products = <ProductEntity>[];
    for (final barcode in barcodes) {
      final product = await searchProductByBarcode(barcode);
      if (product != null) {
        products.add(product);
      }
    }
    return products;
  }

  @override
  List<ProductEntity> filterProducts({
    String? nutriScore,
    bool? vegan,
    bool? vegetarian,
    bool? palmOilFree,
    List<String>? allergens,
    int? novaGroup,
  }) {
    var products = _localDataSource.getCachedProducts();

    if (nutriScore != null) {
      products = products
          .where((p) => p.nutriScore?.toUpperCase() == nutriScore.toUpperCase())
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

    return products.map((p) => p.toEntity()).toList();
  }

  @override
  ProductEntity? getProductFromCache(String barcode) {
    return _localDataSource.getCachedProduct(barcode)?.toEntity();
  }

  @override
  Future<List<String>> getProductSuggestions(String query) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        return [];
      }
      return await _remoteDataSource.getProductSuggestions(query);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in getProductSuggestions', 'FOOD_READ_REPO', e, stackTrace);
      return [];
    }
  }

  @override
  List<ProductEntity> getRecentlyScanned({int limit = 10}) {
    return _localDataSource
        .getRecentlyScanned(limit: limit)
        .map((p) => p.toEntity())
        .toList();
  }

  @override
  Future<List<ProductEntity>> searchByBrand(
    String brand, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        return _searchInCache(brand);
      }

      final products = await _remoteDataSource.searchByBrand(
        brand,
        page: page,
        pageSize: pageSize,
      );

      await Future.wait(
        products.map((product) => _localDataSource.cacheProduct(product)),
      );

      return products.map((p) => p.toEntity()).toList();
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchByBrand', 'FOOD_READ_REPO', e, stackTrace);
      return _searchInCache(brand);
    }
  }

  @override
  Future<List<ProductEntity>> searchByCategory(
    String category, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        return _searchInCache(category);
      }

      final products = await _remoteDataSource.searchByCategory(
        category,
        page: page,
        pageSize: pageSize,
      );

      await Future.wait(
        products.map((product) => _localDataSource.cacheProduct(product)),
      );

      return products.map((p) => p.toEntity()).toList();
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchByCategory', 'FOOD_READ_REPO', e, stackTrace);
      return _searchInCache(category);
    }
  }

  @override
  Future<ProductEntity?> searchProductByBarcode(String barcode) async {
    try {
      // Try cache first
      final cachedProduct = _localDataSource.getCachedProduct(barcode);

      if (cachedProduct != null && cachedProduct.isCacheFresh) {
        TalkerService.info('Using cached product: $barcode', 'FOOD_READ_REPO');
        return cachedProduct.toEntity();
      }

      // Check if online
      if (ConnectivityChecker.isOnline != true) {
        TalkerService.warning(
            'Offline: using cached product', 'FOOD_READ_REPO');
        return cachedProduct?.toEntity();
      }

      // Fetch from remote
      final productModel =
          await _remoteDataSource.searchProductByBarcode(barcode);

      if (productModel != null) {
        // Cache the product
        await _localDataSource.cacheProduct(productModel);

        // Add to history
        await _localDataSource.addToHistory(SearchHistoryModel(
          searchQuery: barcode,
          timestamp: DateTime.now(),
          resultCount: 1,
          searchType: SearchType.barcode,
        ));

        return productModel.toEntity();
      }

      return null;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchProductByBarcode', 'FOOD_READ_REPO', e, stackTrace);

      final cachedProduct = _localDataSource.getCachedProduct(barcode);
      return cachedProduct?.toEntity();
    }
  }

  @override
  Future<List<ProductEntity>> searchProductsByName(
    String query, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      if (ConnectivityChecker.isOnline != true) {
        return _searchInCache(query);
      }

      final products = await _remoteDataSource.searchProductsByName(
        query,
        page: page,
        pageSize: pageSize,
      );

      // Cache all products in parallel
      await Future.wait(
        products.map((product) => _localDataSource.cacheProduct(product)),
      );

      // Add to history
      if (products.isNotEmpty) {
        await _localDataSource.addToHistory(SearchHistoryModel(
          searchQuery: query,
          timestamp: DateTime.now(),
          resultCount: products.length,
          searchType: SearchType.text,
        ));
      }

      return products.map((p) => p.toEntity()).toList();
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error in searchProductsByName', 'FOOD_READ_REPO', e, stackTrace);
      return _searchInCache(query);
    }
  }

  List<ProductEntity> _searchInCache(String query) {
    final products = _localDataSource.getCachedProducts();
    return products
        .where((p) =>
            (p.productName?.toLowerCase().contains(query.toLowerCase()) ??
                false) ||
            (p.brands?.toLowerCase().contains(query.toLowerCase()) ?? false) ||
            p.barcode.contains(query))
        .map((p) => p.toEntity())
        .toList();
  }
}

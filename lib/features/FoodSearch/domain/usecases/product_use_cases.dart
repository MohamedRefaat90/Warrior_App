import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

class ProductUseCases {
  final ProductReadRepository _readRepository;
  final ProductWriteRepository _writeRepository;
  final UserInteractionRepository _interactionRepository;

  ProductUseCases({
    required ProductReadRepository readRepository,
    required ProductWriteRepository writeRepository,
    required UserInteractionRepository interactionRepository,
  })  : _readRepository = readRepository,
        _writeRepository = writeRepository,
        _interactionRepository = interactionRepository;

  /// Add to favorites
  Future<void> addToFavorites(ProductEntity product) {
    return _interactionRepository.addToFavorites(product);
  }

  /// Filter products
  List<ProductEntity> filterProducts({
    String? nutriScore,
    bool? vegan,
    bool? vegetarian,
    bool? palmOilFree,
    List<String>? allergens,
    int? novaGroup,
  }) {
    return _readRepository.filterProducts(
      nutriScore: nutriScore,
      vegan: vegan,
      vegetarian: vegetarian,
      palmOilFree: palmOilFree,
      allergens: allergens,
      novaGroup: novaGroup,
    );
  }

  /// Get favorites
  List<ProductEntity> getFavorites() {
    return _interactionRepository.getFavorites();
  }

  /// Get search history
  List<SearchHistoryEntity> getHistory() {
    return _interactionRepository.getHistory();
  }

  /// Get recently scanned products
  List<ProductEntity> getRecentlyScanned({int limit = 10}) {
    return _readRepository.getRecentlyScanned(limit: limit);
  }

  /// Get suggestions for autocomplete
  Future<List<String>> getSuggestions(String query) {
    return _readRepository.getProductSuggestions(query);
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String barcode) {
    return _interactionRepository.removeFromFavorites(barcode);
  }

  /// Search for a product by barcode
  Future<ProductEntity?> searchByBarcode(String barcode) async {
    try {
      // 1. Check offline cache
      final cachedProduct = _readRepository.getProductFromCache(barcode);
      if (cachedProduct != null) {
        return cachedProduct;
      }

      // 2. Fetch from remote
      final product = await _readRepository.searchProductByBarcode(barcode);
      return product;
    } catch (e, stack) {
      TalkerService.error('Error searching by barcode', 'USECASE', e, stack);
      rethrow;
    }
  }

  /// Search products by brand
  Future<List<ProductEntity>> searchByBrand(String brand,
      {int page = 1, int size = 25}) {
    return _readRepository.searchByBrand(brand, page: page, pageSize: size);
  }

  /// Search products by category
  Future<List<ProductEntity>> searchByCategory(String category,
      {int page = 1, int size = 25}) {
    return _readRepository.searchByCategory(category,
        page: page, pageSize: size);
  }

  /// Search products by name
  Future<List<ProductEntity>> searchByName(String query,
      {int page = 1, int size = 25}) {
    return _readRepository.searchProductsByName(query,
        page: page, pageSize: size);
  }

  /// Submit a product (create or update)
  Future<bool> submitProduct(
      ProductEntity product, User user, String? imagePath) {
    return _writeRepository.submitProduct(
        product: product, user: user, imagePath: imagePath);
  }

  /// Toggle favorite status
  Future<void> toggleFavorite(ProductEntity product) async {
    if (_interactionRepository.isFavorite(product.barcode)) {
      await _interactionRepository.removeFromFavorites(product.barcode);
    } else {
      await _interactionRepository.addToFavorites(product);
    }
  }
}

import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';

abstract class ProductReadRepository {
  /// Compare multiple products by their barcodes
  Future<List<ProductEntity>> compareProducts(List<String> barcodes);

  /// Get all cached products (for filtering in use cases)
  List<ProductEntity> getAllCachedProducts();

  /// Get product from local cache by barcode
  ProductEntity? getProductFromCache(String barcode);

  /// Get product suggestions for autocomplete
  Future<List<String>> getProductSuggestions(String query);

  /// Get recently scanned products
  List<ProductEntity> getRecentlyScanned({int limit = 10});

  /// Search products by brand
  Future<List<ProductEntity>> searchByBrand(
    String brand, {
    int page = 1,
    int pageSize = 25,
  });

  /// Search products by category
  Future<List<ProductEntity>> searchByCategory(
    String category, {
    int page = 1,
    int pageSize = 25,
  });

  /// Search product by barcode
  Future<ProductEntity?> searchProductByBarcode(String barcode);

  /// Search products by name
  Future<List<ProductEntity>> searchProductsByName(
    String query, {
    int page = 1,
    int pageSize = 25,
  });
}

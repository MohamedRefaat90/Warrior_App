import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Remote data source for Open Food Facts API
/// Handles all API calls to Open Food Facts
class FoodRemoteDataSource {
  /// Fields needed for list view display (reduces payload significantly)
  static const List<ProductField> _listViewFields = [
    ProductField.BARCODE,
    ProductField.NAME,
    ProductField.BRANDS,
    ProductField.QUANTITY,
    ProductField.IMAGE_FRONT_URL,
    ProductField.IMAGE_FRONT_SMALL_URL,
    ProductField.NUTRISCORE,
    ProductField.NOVA_GROUP,
    ProductField.ECOSCORE_GRADE,
    ProductField.NUTRIMENTS,
    ProductField.INGREDIENTS_ANALYSIS_TAGS,
  ];

  /// Add new product to Open Food Facts database
  Future<bool> addNewProduct(Product product, User user) async {
    try {
      TalkerService.info('Adding new product: ${product.barcode}', 'FOOD_API');

      final Status result = await OpenFoodAPIClient.saveProduct(user, product);

      if (result.status == 1) {
        TalkerService.info('Product added successfully', 'FOOD_API');
        return true;
      }

      TalkerService.warning(
          'Failed to add product: ${result.error}', 'FOOD_API');
      return false;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding new product', 'FOOD_API', e, stackTrace);
      rethrow;
    }
  }

  /// Get product suggestions for autocomplete
  Future<List<String>> getProductSuggestions(String query) async {
    try {
      if (query.length < 2) return [];

      TalkerService.info('Getting product suggestions for: $query', 'FOOD_API');

      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
          PageSize(size: 50), // Get more results for better filtering
        ],
        version: ProductQueryVersion.v3,
        languages: [
          OpenFoodFactsLanguage.ENGLISH,
          OpenFoodFactsLanguage.ARABIC
        ],
        fields: [ProductField.NAME],
      );

      final SearchResult result =
          await OpenFoodAPIClient.searchProducts(null, configuration);

      if (result.products != null && result.products!.isNotEmpty) {
        final queryLower = query.toLowerCase();

        // Filter and sort suggestions
        final suggestions = result.products!
            .where((product) => product.productName != null)
            .map((product) => product.productName!)
            .toSet() // Remove duplicates
            .where((name) {
          final nameLower = name.toLowerCase();
          // Prioritize products that start with the query or contain it as a word
          return nameLower.startsWith(queryLower) ||
              nameLower.contains(' $queryLower');
        }).toList();

        // Sort: products starting with query first, then others
        suggestions.sort((a, b) {
          final aLower = a.toLowerCase();
          final bLower = b.toLowerCase();
          final aStarts = aLower.startsWith(queryLower);
          final bStarts = bLower.startsWith(queryLower);

          if (aStarts && !bStarts) return -1;
          if (!aStarts && bStarts) return 1;
          return a.compareTo(b);
        });

        // Return top 10 most relevant suggestions
        return suggestions.take(10).toList();
      }

      return [];
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting product suggestions', 'FOOD_API', e, stackTrace);
      return [];
    }
  }

  /// Search products by brand
  Future<List<FoodProductModel>> searchByBrand(
    String brand, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      TalkerService.info('Searching products by brand: $brand', 'FOOD_API');

      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
        parametersList: [
          TagFilter.fromType(
            tagFilterType: TagFilterType.BRANDS,
            tagName: brand,
            contains: true,
          ),
          PageNumber(page: page),
          PageSize(size: pageSize),
        ],
        version: ProductQueryVersion.v3,
        languages: [
          OpenFoodFactsLanguage.ENGLISH,
          OpenFoodFactsLanguage.ARABIC
        ],
        fields: _listViewFields,
      );

      final SearchResult result =
          await OpenFoodAPIClient.searchProducts(null, configuration);

      if (result.products != null && result.products!.isNotEmpty) {
        return result.products!
            .where((product) =>
                product.brands?.toLowerCase().contains(brand.toLowerCase()) ??
                false)
            .where((product) => product.nutriments != null)
            .map(
                (product) => FoodProductModel.fromOpenFoodFactsProduct(product))
            .toList();
      }

      return [];
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error searching products by brand', 'FOOD_API', e, stackTrace);
      rethrow;
    }
  }

  /// Search products by category
  Future<List<FoodProductModel>> searchByCategory(
    String category, {
    int page = 1,
    int pageSize = 25,
  }) async {
    try {
      TalkerService.info(
          'Searching products by category: $category', 'FOOD_API');

      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
        parametersList: [
          TagFilter.fromType(
            tagFilterType: TagFilterType.CATEGORIES,
            tagName: category,
            contains: true,
          ),
          PageNumber(page: page),
          PageSize(size: pageSize),
        ],
        version: ProductQueryVersion.v3,
        languages: [
          OpenFoodFactsLanguage.ENGLISH,
          OpenFoodFactsLanguage.ARABIC
        ],
        fields: _listViewFields,
      );

      final SearchResult result =
          await OpenFoodAPIClient.searchProducts(null, configuration);

      if (result.products != null && result.products!.isNotEmpty) {
        return result.products!
            .where((product) => product.nutriments != null)
            .map(
                (product) => FoodProductModel.fromOpenFoodFactsProduct(product))
            .toList();
      }

      return [];
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error searching products by category', 'FOOD_API', e, stackTrace);
      rethrow;
    }
  }

  /// Search product by barcode
  Future<FoodProductModel?> searchProductByBarcode(String barcode) async {
    try {
      TalkerService.info('Searching product by barcode: $barcode', 'FOOD_API');

      final ProductQueryConfiguration configuration = ProductQueryConfiguration(
        barcode,
        version: ProductQueryVersion.v3,
        languages: [
          OpenFoodFactsLanguage.ENGLISH,
          OpenFoodFactsLanguage.ARABIC
        ],
        fields: [ProductField.ALL],
      );

      final ProductResultV3 result =
          await OpenFoodAPIClient.getProductV3(configuration);

      if (result.product != null) {
        TalkerService.info(
            'Product found: ${result.product!.productName}', 'FOOD_API');
        return FoodProductModel.fromOpenFoodFactsProduct(result.product!);
      }

      TalkerService.warning(
          'Product not found for barcode: $barcode', 'FOOD_API');
      return null;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error searching product by barcode', 'FOOD_API', e, stackTrace);
      rethrow;
    }
  }

  /// Search products by name with optional filters
  Future<List<FoodProductModel>> searchProductsByName(
    String query, {
    int page = 1,
    int pageSize = 25,
    List<String>? categories,
    List<String>? brands,
    String? nutriScore,
  }) async {
    try {
      TalkerService.info('Searching products by name: $query', 'FOOD_API');

      final ProductSearchQueryConfiguration configuration =
          ProductSearchQueryConfiguration(
        parametersList: [
          SearchTerms(terms: [query]),
          PageNumber(page: page),
          PageSize(size: pageSize),
        ],
        version: ProductQueryVersion.v3,
        languages: [
          OpenFoodFactsLanguage.ENGLISH,
          OpenFoodFactsLanguage.ARABIC
        ],
        fields: _listViewFields,
      );

      final SearchResult result =
          await OpenFoodAPIClient.searchProducts(null, configuration);

      if (result.products != null && result.products!.isNotEmpty) {
        TalkerService.info(
            'Found ${result.products!.length} products', 'FOOD_API');
        return result.products!
            .where((product) => product.nutriments != null)
            .map(
                (product) => FoodProductModel.fromOpenFoodFactsProduct(product))
            .toList();
      }

      TalkerService.warning('No products found for query: $query', 'FOOD_API');
      return [];
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error searching products by name', 'FOOD_API', e, stackTrace);
      rethrow;
    }
  }

  /// Update existing product in Open Food Facts database
  Future<bool> updateProduct(Product product, User user) async {
    try {
      TalkerService.info('Updating product: ${product.barcode}', 'FOOD_API');

      final Status result = await OpenFoodAPIClient.saveProduct(user, product);

      if (result.status == 1) {
        TalkerService.info('Product updated successfully', 'FOOD_API');
        return true;
      }

      TalkerService.warning(
          'Failed to update product: ${result.error}', 'FOOD_API');
      return false;
    } catch (e, stackTrace) {
      TalkerService.error('Error updating product', 'FOOD_API', e, stackTrace);
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
      TalkerService.info('Uploading image for product: $barcode', 'FOOD_API');

      final SendImage image = SendImage(
        lang: OpenFoodFactsLanguage.ENGLISH,
        barcode: barcode,
        imageField: imageField,
        imageUri: Uri.file(imagePath),
      );

      final Status result =
          await OpenFoodAPIClient.addProductImage(user, image);

      if (result.status == 1) {
        TalkerService.info('Image uploaded successfully', 'FOOD_API');
        return true;
      }

      TalkerService.warning(
          'Failed to upload image: ${result.error}', 'FOOD_API');
      return false;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error uploading product image', 'FOOD_API', e, stackTrace);
      rethrow;
    }
  }
}

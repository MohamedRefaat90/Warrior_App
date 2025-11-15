import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';

/// Local data source for food search
/// Handles all local Hive database operations
class FoodLocalDataSource {
  /// Get cached product by barcode
  FoodProductModel? getCachedProduct(String barcode) {
    try {
      final products = HiveManager.foodProductsBox.values
          .where((product) => product.barcode == barcode);

      if (products.isNotEmpty) {
        TalkerService.info('Found cached product: $barcode', 'FOOD_CACHE');
        return products.first;
      }

      TalkerService.info('No cached product found for: $barcode',
          'FOOD_CACHE');
      return null;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting cached product', 'FOOD_CACHE', e, stackTrace);
      return null;
    }
  }

  /// Cache product locally
  Future<void> cacheProduct(FoodProductModel product) async {
    try {
      // Check if product already exists
      final existingProducts = HiveManager.foodProductsBox.values
          .where((p) => p.barcode == product.barcode);

      if (existingProducts.isNotEmpty) {
        // Update existing product
        final existingProduct = existingProducts.first;
        final index = HiveManager.foodProductsBox.values
            .toList()
            .indexOf(existingProduct);
        await HiveManager.foodProductsBox.putAt(index, product);
        TalkerService.info('Updated cached product: ${product.barcode}',
            'FOOD_CACHE');
      } else {
        // Add new product
        await HiveManager.foodProductsBox.add(product);
        TalkerService.info('Cached new product: ${product.barcode}',
            'FOOD_CACHE');
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error caching product', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Get all cached products
  List<FoodProductModel> getCachedProducts() {
    try {
      final products = HiveManager.foodProductsBox.values.toList();
      TalkerService.info('Retrieved ${products.length} cached products',
          'FOOD_CACHE');
      return products;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting cached products', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Add product to favorites
  Future<void> addToFavorites(FoodProductModel product) async {
    try {
      // Check if already in favorites
      final existingFavorites = HiveManager.favoriteFoodsBox.values
          .where((fav) => fav.foodProduct.barcode == product.barcode);

      if (existingFavorites.isEmpty) {
        final favorite = FavoriteFoodModel(
          foodProduct: product,
          addedDate: DateTime.now(),
        );
        await HiveManager.favoriteFoodsBox.add(favorite);
        TalkerService.info('Added to favorites: ${product.barcode}',
            'FOOD_CACHE');
      } else {
        TalkerService.info('Product already in favorites: ${product.barcode}',
            'FOOD_CACHE');
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding to favorites', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Get all favorites
  List<FavoriteFoodModel> getFavorites() {
    try {
      final favorites = HiveManager.favoriteFoodsBox.values.toList();
      TalkerService.info('Retrieved ${favorites.length} favorites',
          'FOOD_CACHE');
      return favorites;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting favorites', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Remove from favorites
  Future<void> removeFromFavorites(String barcode) async {
    try {
      final favorites = HiveManager.favoriteFoodsBox.values
          .where((fav) => fav.foodProduct.barcode == barcode);

      if (favorites.isNotEmpty) {
        final favorite = favorites.first;
        await favorite.delete();
        TalkerService.info('Removed from favorites: $barcode', 'FOOD_CACHE');
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error removing from favorites', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Check if product is in favorites
  bool isFavorite(String barcode) {
    try {
      final favorites = HiveManager.favoriteFoodsBox.values
          .where((fav) => fav.foodProduct.barcode == barcode);
      return favorites.isNotEmpty;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error checking if favorite', 'FOOD_CACHE', e, stackTrace);
      return false;
    }
  }

  /// Add to search history
  Future<void> addToHistory(SearchHistoryModel history) async {
    try {
      await HiveManager.searchHistoryBox.add(history);
      TalkerService.info('Added to search history: ${history.searchQuery}',
          'FOOD_CACHE');

      // Keep only last 50 searches
      if (HiveManager.searchHistoryBox.length > 50) {
        await HiveManager.searchHistoryBox.deleteAt(0);
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding to history', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Get search history
  List<SearchHistoryModel> getHistory({int limit = 20}) {
    try {
      final history = HiveManager.searchHistoryBox.values.toList();
      // Sort by timestamp descending
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      
      final limitedHistory = history.take(limit).toList();
      TalkerService.info('Retrieved ${limitedHistory.length} history items',
          'FOOD_CACHE');
      return limitedHistory;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting history', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Clear search history
  Future<void> clearHistory() async {
    try {
      await HiveManager.searchHistoryBox.clear();
      TalkerService.info('Cleared search history', 'FOOD_CACHE');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error clearing history', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Get recently scanned products
  List<FoodProductModel> getRecentlyScanned({int limit = 10}) {
    try {
      final products = HiveManager.foodProductsBox.values.toList();
      // Sort by lastUpdated descending
      products.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
      
      final recentProducts = products.take(limit).toList();
      TalkerService.info('Retrieved ${recentProducts.length} recent products',
          'FOOD_CACHE');
      return recentProducts;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting recently scanned', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Delete cached product
  Future<void> deleteCachedProduct(String barcode) async {
    try {
      final products = HiveManager.foodProductsBox.values
          .where((product) => product.barcode == barcode);

      if (products.isNotEmpty) {
        final product = products.first;
        await product.delete();
        TalkerService.info('Deleted cached product: $barcode', 'FOOD_CACHE');
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error deleting cached product', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all cached products
  Future<void> clearCache() async {
    try {
      await HiveManager.foodProductsBox.clear();
      TalkerService.info('Cleared all cached products', 'FOOD_CACHE');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error clearing cache', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }
}


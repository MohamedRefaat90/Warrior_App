import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';

/// Local data source for food search
/// Handles all local Hive database operations
class FoodLocalDataSource {
  /// Add product to favorites - O(1) using barcode as key
  Future<void> addToFavorites(FoodProductModel product) async {
    try {
      // Check if already in favorites using O(1) lookup
      if (HiveManager.favoriteFoodsBox.containsKey(product.barcode)) {
        TalkerService.info(
            'Product already in favorites: ${product.barcode}', 'FOOD_CACHE');
        return;
      }

      final favorite = FavoriteFoodModel(
        foodProduct: product,
        addedDate: DateTime.now(),
      );
      // Use put with barcode as key for O(1) lookup
      await HiveManager.favoriteFoodsBox.put(product.barcode, favorite);
      TalkerService.info(
          'Added to favorites: ${product.barcode}', 'FOOD_CACHE');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding to favorites', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Add to search history
  Future<void> addToHistory(SearchHistoryModel history) async {
    try {
      await HiveManager.searchHistoryBox.add(history);
      TalkerService.info(
          'Added to search history: ${history.searchQuery}', 'FOOD_CACHE');

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

  /// Cache product locally using barcode as key for O(1) access
  Future<void> cacheProduct(FoodProductModel product) async {
    try {
      // Use put with barcode as key for O(1) lookup and automatic update
      await HiveManager.foodProductsBox.put(product.barcode, product);
      TalkerService.info('Cached product: ${product.barcode}', 'FOOD_CACHE');
    } catch (e, stackTrace) {
      TalkerService.error('Error caching product', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Clear all cached products
  Future<void> clearCache() async {
    try {
      await HiveManager.foodProductsBox.clear();
      TalkerService.info('Cleared all cached products', 'FOOD_CACHE');
    } catch (e, stackTrace) {
      TalkerService.error('Error clearing cache', 'FOOD_CACHE', e, stackTrace);
      rethrow;
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

  /// Delete cached product - O(1) using barcode as key
  Future<void> deleteCachedProduct(String barcode) async {
    try {
      await HiveManager.foodProductsBox.delete(barcode);
      TalkerService.info('Deleted cached product: $barcode', 'FOOD_CACHE');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error deleting cached product', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }

  /// Get cached product by barcode - O(1) lookup using barcode as key
  FoodProductModel? getCachedProduct(String barcode) {
    try {
      // Use direct key lookup for O(1) access
      final product = HiveManager.foodProductsBox.get(barcode);

      if (product != null) {
        TalkerService.info('Found cached product: $barcode', 'FOOD_CACHE');
        return product;
      }

      TalkerService.info('No cached product found for: $barcode', 'FOOD_CACHE');
      return null;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting cached product', 'FOOD_CACHE', e, stackTrace);
      return null;
    }
  }

  /// Get all cached products
  List<FoodProductModel> getCachedProducts() {
    try {
      final products = HiveManager.foodProductsBox.values.toList();
      TalkerService.info(
          'Retrieved ${products.length} cached products', 'FOOD_CACHE');
      return products;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting cached products', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Get all favorites
  List<FavoriteFoodModel> getFavorites() {
    try {
      final favorites = HiveManager.favoriteFoodsBox.values.toList();
      TalkerService.info(
          'Retrieved ${favorites.length} favorites', 'FOOD_CACHE');
      return favorites;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting favorites', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Get search history
  List<SearchHistoryModel> getHistory({int limit = 20}) {
    try {
      final history = HiveManager.searchHistoryBox.values.toList();
      // Sort by timestamp descending
      history.sort((a, b) => b.timestamp.compareTo(a.timestamp));

      final limitedHistory = history.take(limit).toList();
      TalkerService.info(
          'Retrieved ${limitedHistory.length} history items', 'FOOD_CACHE');
      return limitedHistory;
    } catch (e, stackTrace) {
      TalkerService.error('Error getting history', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Get recently scanned products
  List<FoodProductModel> getRecentlyScanned({int limit = 10}) {
    try {
      final products = HiveManager.foodProductsBox.values.toList();
      // Sort by lastUpdated descending
      products.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));

      final recentProducts = products.take(limit).toList();
      TalkerService.info(
          'Retrieved ${recentProducts.length} recent products', 'FOOD_CACHE');
      return recentProducts;
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error getting recently scanned', 'FOOD_CACHE', e, stackTrace);
      return [];
    }
  }

  /// Check if product is in favorites - O(1) using barcode as key
  bool isFavorite(String barcode) {
    try {
      return HiveManager.favoriteFoodsBox.containsKey(barcode);
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error checking if favorite', 'FOOD_CACHE', e, stackTrace);
      return false;
    }
  }

  /// Remove from favorites - O(1) using barcode as key
  Future<void> removeFromFavorites(String barcode) async {
    try {
      if (HiveManager.favoriteFoodsBox.containsKey(barcode)) {
        await HiveManager.favoriteFoodsBox.delete(barcode);
        TalkerService.info('Removed from favorites: $barcode', 'FOOD_CACHE');
      }
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error removing from favorites', 'FOOD_CACHE', e, stackTrace);
      rethrow;
    }
  }
}

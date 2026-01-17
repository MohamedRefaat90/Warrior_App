import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';

abstract class UserInteractionRepository {
  /// Add a product to favorites
  Future<void> addToFavorites(ProductEntity product);

  /// Clear all search history
  Future<void> clearHistory();

  /// Get all favorite products
  List<ProductEntity> getFavorites();

  /// Get search history
  List<SearchHistoryEntity> getHistory({int limit = 20});

  /// Check if a product is in favorites
  bool isFavorite(String barcode);

  /// Remove a product from favorites
  Future<void> removeFromFavorites(String barcode);
}

import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for favorites list with state management
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<FavoriteFoodModel>>(
        FavoritesNotifier.new);

/// Provider for current favorites sort option.
final favoritesSortProvider =
    NotifierProvider<FavoritesSortNotifier, FavoritesSortOption>(
        FavoritesSortNotifier.new);

/// Provider to check if a product is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, barcode) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((fav) => fav.foodProduct.barcode == barcode);
});

/// Provider for sorted favorites list.
final sortedFavoritesProvider = Provider<List<FavoriteFoodModel>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  final sortOption = ref.watch(favoritesSortProvider);

  // Create a copy to avoid modifying the original list
  final sorted = List<FavoriteFoodModel>.from(favorites);

  switch (sortOption) {
    case FavoritesSortOption.dateNewest:
      sorted.sort((a, b) => b.addedDate.compareTo(a.addedDate));
    case FavoritesSortOption.dateOldest:
      sorted.sort((a, b) => a.addedDate.compareTo(b.addedDate));
    case FavoritesSortOption.nameAsc:
      sorted.sort((a, b) => (a.foodProduct.productName ?? '')
          .toLowerCase()
          .compareTo((b.foodProduct.productName ?? '').toLowerCase()));
    case FavoritesSortOption.nameDesc:
      sorted.sort((a, b) => (b.foodProduct.productName ?? '')
          .toLowerCase()
          .compareTo((a.foodProduct.productName ?? '').toLowerCase()));
    case FavoritesSortOption.brandAsc:
      sorted.sort((a, b) => (a.foodProduct.brands ?? '')
          .toLowerCase()
          .compareTo((b.foodProduct.brands ?? '').toLowerCase()));
    case FavoritesSortOption.brandDesc:
      sorted.sort((a, b) => (b.foodProduct.brands ?? '')
          .toLowerCase()
          .compareTo((a.foodProduct.brands ?? '').toLowerCase()));
  }

  return sorted;
});

class FavoritesNotifier extends Notifier<List<FavoriteFoodModel>> {
  FoodSearchRepo get _repo => ref.read(foodSearchRepoProvider);

  Future<void> addFavorite(FoodProductModel product) async {
    try {
      await _repo.addToFavorites(product);
      state = _repo.getFavorites();
      HapticFeedback.mediumImpact();
      TalkerService.info(
          'Added to favorites: ${product.productName}', 'FAVORITES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding to favorites', 'FAVORITES', e, stackTrace);
    }
  }

  @override
  List<FavoriteFoodModel> build() {
    return _repo.getFavorites();
  }

  void refresh() {
    state = _repo.getFavorites();
  }

  Future<void> removeFavorite(String barcode) async {
    try {
      await _repo.removeFromFavorites(barcode);
      state = _repo.getFavorites();
      HapticFeedback.lightImpact();
      TalkerService.info('Removed from favorites: $barcode', 'FAVORITES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error removing from favorites', 'FAVORITES', e, stackTrace);
    }
  }

  void toggleFavorite(FoodProductModel product) {
    final isFavorite =
        state.any((fav) => fav.foodProduct.barcode == product.barcode);
    if (isFavorite) {
      removeFavorite(product.barcode);
    } else {
      addFavorite(product);
    }
  }
}

/// Notifier for managing favorites sort option.
class FavoritesSortNotifier extends Notifier<FavoritesSortOption> {
  @override
  FavoritesSortOption build() => FavoritesSortOption.dateNewest;

  void setSortOption(FavoritesSortOption option) {
    state = option;
  }
}

/// Sort options for favorites list.
enum FavoritesSortOption {
  /// Sort by date added (newest first).
  dateNewest,

  /// Sort by date added (oldest first).
  dateOldest,

  /// Sort alphabetically by name (A-Z).
  nameAsc,

  /// Sort alphabetically by name (Z-A).
  nameDesc,

  /// Sort alphabetically by brand (A-Z).
  brandAsc,

  /// Sort alphabetically by brand (Z-A).
  brandDesc,
}

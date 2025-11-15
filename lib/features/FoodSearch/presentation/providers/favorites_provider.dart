import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for favorites list with state management
final favoritesProvider =
    NotifierProvider.autoDispose<FavoritesNotifier, List<FavoriteFoodModel>>(
        FavoritesNotifier.new);

/// Provider to check if a product is favorite
final isFavoriteProvider =
    Provider.family.autoDispose<bool, String>((ref, barcode) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((fav) => fav.foodProduct.barcode == barcode);
});

class FavoritesNotifier extends Notifier<List<FavoriteFoodModel>> {
  FoodSearchRepo get _repo => ref.read(foodSearchRepoProvider);

  Future<void> addFavorite(FoodProductModel product) async {
    try {
      await _repo.addToFavorites(product);
      state = _repo.getFavorites();
      TalkerService.info(
          'Added to favorites: ${product.productName}', 'FAVORITES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding to favorites', 'FAVORITES', e, stackTrace);
    }
  }

  @override
  List<FavoriteFoodModel> build() {
    ref.keepAlive();
    return _repo.getFavorites();
  }

  void refresh() {
    state = _repo.getFavorites();
  }

  Future<void> removeFavorite(String barcode) async {
    try {
      await _repo.removeFromFavorites(barcode);
      state = _repo.getFavorites();
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

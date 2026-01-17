import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/usecases.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/product_use_cases_provider.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for favorites list with state management
final favoritesProvider =
    NotifierProvider<FavoritesNotifier, List<ProductEntity>>(
        FavoritesNotifier.new);

/// Provider for current favorites sort option.
final favoritesSortProvider =
    NotifierProvider<FavoritesSortNotifier, FavoritesSortOption>(
        FavoritesSortNotifier.new);

/// Provider to check if a product is favorite
final isFavoriteProvider = Provider.family<bool, String>((ref, barcode) {
  final favorites = ref.watch(favoritesProvider);
  return favorites.any((fav) => fav.barcode == barcode);
});

/// Provider for sorted favorites list.
final sortedFavoritesProvider = Provider<List<ProductEntity>>((ref) {
  final favorites = ref.watch(favoritesProvider);
  final sortOption = ref.watch(favoritesSortProvider);

  // Create a copy to avoid modifying the original list
  final sorted = List<ProductEntity>.from(favorites);

  switch (sortOption) {
    case FavoritesSortOption.dateNewest:
      sorted.sort((a, b) => b.lastUpdated.compareTo(a.lastUpdated));
    case FavoritesSortOption.dateOldest:
      sorted.sort((a, b) => a.lastUpdated.compareTo(b.lastUpdated));
    case FavoritesSortOption.nameAsc:
      sorted.sort((a, b) => (a.productName ?? '')
          .toLowerCase()
          .compareTo((b.productName ?? '').toLowerCase()));
    case FavoritesSortOption.nameDesc:
      sorted.sort((a, b) => (b.productName ?? '')
          .toLowerCase()
          .compareTo((a.productName ?? '').toLowerCase()));
    case FavoritesSortOption.brandAsc:
      sorted.sort((a, b) => (a.brands ?? '')
          .toLowerCase()
          .compareTo((b.brands ?? '').toLowerCase()));
    case FavoritesSortOption.brandDesc:
      sorted.sort((a, b) => (b.brands ?? '')
          .toLowerCase()
          .compareTo((a.brands ?? '').toLowerCase()));
  }

  return sorted;
});

class FavoritesNotifier extends Notifier<List<ProductEntity>> {
  // Individual use cases
  AddToFavoritesUseCase get _addToFavoritesUseCase =>
      ref.read(addToFavoritesUseCaseProvider);
  GetFavoritesUseCase get _getFavoritesUseCase =>
      ref.read(getFavoritesUseCaseProvider);
  RemoveFromFavoritesUseCase get _removeFromFavoritesUseCase =>
      ref.read(removeFromFavoritesUseCaseProvider);

  Future<void> addFavorite(ProductEntity product) async {
    try {
      await _addToFavoritesUseCase(product);
      state = _getFavoritesUseCase();
      HapticFeedback.mediumImpact();
      TalkerService.info(
          'Added to favorites: ${product.productName}', 'FAVORITES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error adding to favorites', 'FAVORITES', e, stackTrace);
    }
  }

  @override
  List<ProductEntity> build() {
    return _getFavoritesUseCase();
  }

  void refresh() {
    state = _getFavoritesUseCase();
  }

  Future<void> removeFavorite(String barcode) async {
    try {
      await _removeFromFavoritesUseCase(barcode);
      state = _getFavoritesUseCase();
      HapticFeedback.lightImpact();
      TalkerService.info('Removed from favorites: $barcode', 'FAVORITES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error removing from favorites', 'FAVORITES', e, stackTrace);
    }
  }

  void toggleFavorite(ProductEntity product) {
    final isFavorite = state.any((fav) => fav.barcode == product.barcode);
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

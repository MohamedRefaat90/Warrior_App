import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/usecases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// ============================================================================
// SEARCH USE CASE PROVIDERS
// ============================================================================

/// Provider for AddToFavoritesUseCase
final addToFavoritesUseCaseProvider = Provider<AddToFavoritesUseCase>((ref) {
  return AddToFavoritesUseCase(
    ref.watch(userInteractionRepositoryProvider),
  );
});

/// Provider for CompareProductsUseCase
final compareProductsUseCaseProvider = Provider<CompareProductsUseCase>((ref) {
  return CompareProductsUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

/// Provider for FilterProductsUseCase
final filterProductsUseCaseProvider = Provider<FilterProductsUseCase>((ref) {
  return FilterProductsUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

/// Provider for GetFavoritesUseCase
final getFavoritesUseCaseProvider = Provider<GetFavoritesUseCase>((ref) {
  return GetFavoritesUseCase(
    ref.watch(userInteractionRepositoryProvider),
  );
});

// ============================================================================
// FILTERING & COMPARISON USE CASE PROVIDERS
// ============================================================================

/// Provider for GetProductSuggestionsUseCase
final getProductSuggestionsUseCaseProvider =
    Provider<GetProductSuggestionsUseCase>((ref) {
  return GetProductSuggestionsUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

/// Provider for GetRecentlyScannedUseCase
final getRecentlyScannedUseCaseProvider =
    Provider<GetRecentlyScannedUseCase>((ref) {
  return GetRecentlyScannedUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

// ============================================================================
// FAVORITES USE CASE PROVIDERS
// ============================================================================

/// Provider for GetSearchHistoryUseCase
final getSearchHistoryUseCaseProvider =
    Provider<GetSearchHistoryUseCase>((ref) {
  return GetSearchHistoryUseCase(
    ref.watch(userInteractionRepositoryProvider),
  );
});

/// Provider for RemoveFromFavoritesUseCase
final removeFromFavoritesUseCaseProvider =
    Provider<RemoveFromFavoritesUseCase>((ref) {
  return RemoveFromFavoritesUseCase(
    ref.watch(userInteractionRepositoryProvider),
  );
});

/// Provider for SearchProductByBarcodeUseCase
final searchProductByBarcodeUseCaseProvider =
    Provider<SearchProductByBarcodeUseCase>((ref) {
  return SearchProductByBarcodeUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

/// Provider for SearchProductsByBrandUseCase
final searchProductsByBrandUseCaseProvider =
    Provider<SearchProductsByBrandUseCase>((ref) {
  return SearchProductsByBrandUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

// ============================================================================
// HISTORY & SUGGESTIONS USE CASE PROVIDERS
// ============================================================================

/// Provider for SearchProductsByCategoryUseCase
final searchProductsByCategoryUseCaseProvider =
    Provider<SearchProductsByCategoryUseCase>((ref) {
  return SearchProductsByCategoryUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

/// Provider for SearchProductsByNameUseCase
final searchProductsByNameUseCaseProvider =
    Provider<SearchProductsByNameUseCase>((ref) {
  return SearchProductsByNameUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

/// Provider for SubmitProductUseCase
final submitProductUseCaseProvider = Provider<SubmitProductUseCase>((ref) {
  return SubmitProductUseCase(
    ref.watch(productWriteRepositoryProvider),
  );
});

// ============================================================================
// PRODUCT MANAGEMENT USE CASE PROVIDERS
// ============================================================================

/// Provider for ToggleFavoriteUseCase
final toggleFavoriteUseCaseProvider = Provider<ToggleFavoriteUseCase>((ref) {
  return ToggleFavoriteUseCase(
    ref.watch(userInteractionRepositoryProvider),
  );
});

import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for filtered products
final filteredProductsProvider =
    Provider.autoDispose<List<FoodProductModel>>((ref) {
  final repo = ref.read(foodSearchRepoProvider);
  final filters = ref.watch(searchFiltersProvider);

  return repo.filterProducts(
    nutriScore: filters.nutriScore,
    vegan: filters.vegan,
    vegetarian: filters.vegetarian,
    palmOilFree: filters.palmOilFree,
    allergens: filters.allergens,
    novaGroup: filters.novaGroup,
  );
});

/// Provider for product suggestions (autocomplete)
final productSuggestionsProvider =
    FutureProvider.family.autoDispose<List<String>, String>((ref, query) async {
  if (query.length < 2) return [];
  final repo = ref.read(foodSearchRepoProvider);
  return await repo.getProductSuggestions(query);
});

/// Provider for recently scanned products
final recentlyScannedProvider =
    Provider.autoDispose<List<FoodProductModel>>((ref) {
  final repo = ref.read(foodSearchRepoProvider);
  return repo.getRecentlyScanned(limit: 10);
});

/// State provider for current search filters
final searchFiltersProvider =
    NotifierProvider.autoDispose<SearchFiltersNotifier, SearchFilters>(
        SearchFiltersNotifier.new);

/// Provider for searching product by barcode
final searchProductByBarcodeProvider = FutureProvider.family
    .autoDispose<FoodProductModel?, String>((ref, barcode) async {
  final repo = ref.read(foodSearchRepoProvider);
  return await repo.searchProductByBarcode(barcode);
});

/// Provider for searching products by name
final searchProductsByNameProvider = FutureProvider.family
    .autoDispose<List<FoodProductModel>, String>((ref, query) async {
  final repo = ref.read(foodSearchRepoProvider);
  return await repo.searchProductsByName(query);
});

/// Model for search filters
class SearchFilters {
  final String? nutriScore;
  final bool? vegan;
  final bool? vegetarian;
  final bool? palmOilFree;
  final List<String>? allergens;
  final int? novaGroup;

  SearchFilters({
    this.nutriScore,
    this.vegan,
    this.vegetarian,
    this.palmOilFree,
    this.allergens,
    this.novaGroup,
  });

  bool get hasActiveFilters =>
      nutriScore != null ||
      vegan == true ||
      vegetarian == true ||
      palmOilFree == true ||
      (allergens != null && allergens!.isNotEmpty) ||
      novaGroup != null;

  SearchFilters copyWith({
    String? nutriScore,
    bool? vegan,
    bool? vegetarian,
    bool? palmOilFree,
    List<String>? allergens,
    int? novaGroup,
  }) {
    return SearchFilters(
      nutriScore: nutriScore ?? this.nutriScore,
      vegan: vegan ?? this.vegan,
      vegetarian: vegetarian ?? this.vegetarian,
      palmOilFree: palmOilFree ?? this.palmOilFree,
      allergens: allergens ?? this.allergens,
      novaGroup: novaGroup ?? this.novaGroup,
    );
  }
}

class SearchFiltersNotifier extends Notifier<SearchFilters> {
  @override
  SearchFilters build() {
    ref.keepAlive();
    return SearchFilters();
  }

  void updateFilters(SearchFilters filters) {
    state = filters;
  }
}

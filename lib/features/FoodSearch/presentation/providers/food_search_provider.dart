import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/product_use_cases_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for filtered products
final filteredProductsProvider =
    Provider.autoDispose<List<ProductEntity>>((ref) {
  final filterUseCase = ref.watch(filterProductsUseCaseProvider);
  final filters = ref.watch(searchFiltersProvider);

  return filterUseCase(
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
  final suggestionsUseCase = ref.watch(getProductSuggestionsUseCaseProvider);
  // Logic for cache and query length validation is now handled in Domain/Data layers
  return await suggestionsUseCase(query);
});

/// Provider for recently scanned products
final recentlySearchedProvider =
    Provider.autoDispose<List<ProductEntity>>((ref) {
  final recentlySearchedUseCase = ref.watch(getRecentlySearchedUseCaseProvider);
  return recentlySearchedUseCase(limit: 10);
});

/// State provider for current search filters
final searchFiltersProvider =
    NotifierProvider.autoDispose<SearchFiltersNotifier, SearchFilters>(
        SearchFiltersNotifier.new);

/// Provider for searching product by barcode
final searchProductByBarcodeProvider = FutureProvider.family
    .autoDispose<ProductEntity?, String>((ref, barcode) async {
  final searchByBarcodeUseCase =
      ref.watch(searchProductByBarcodeUseCaseProvider);
  return await searchByBarcodeUseCase(barcode);
});

/// Provider for searching products by name
final searchProductsByNameProvider = FutureProvider.family
    .autoDispose<List<ProductEntity>, String>((ref, query) async {
  final searchByNameUseCase = ref.watch(searchProductsByNameUseCaseProvider);
  return await searchByNameUseCase(query);
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
    return SearchFilters();
  }

  void updateFilters(SearchFilters filters) {
    state = filters;
  }
}

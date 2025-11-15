import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for advanced search state
final advancedSearchProvider =
    NotifierProvider.autoDispose<AdvancedSearchNotifier, AdvancedSearchState>(
        AdvancedSearchNotifier.new);

/// Advanced search notifier
class AdvancedSearchNotifier extends Notifier<AdvancedSearchState> {
  FoodSearchRepo get _repo => ref.read(foodSearchRepoProvider);

  @override
  AdvancedSearchState build() {
    ref.keepAlive();
    return AdvancedSearchState();
  }

  void clearFilters() {
    state = AdvancedSearchState(query: state.query);
    TalkerService.info('Cleared all filters', 'ADVANCED_SEARCH');
  }

  Future<void> performSearch() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      List<FoodProductModel> results = [];

      if (state.query.isNotEmpty) {
        results = await _repo.searchProductsByName(state.query);
      } else if (state.selectedCategories.isNotEmpty) {
        for (final category in state.selectedCategories) {
          final categoryResults = await _repo.searchByCategory(category);
          results.addAll(categoryResults);
        }
      } else if (state.selectedBrands.isNotEmpty) {
        for (final brand in state.selectedBrands) {
          final brandResults = await _repo.searchByBrand(brand);
          results.addAll(brandResults);
        }
      }

      // Apply additional filters
      results = _applyFilters(results);

      state = state.copyWith(
        results: results,
        isLoading: false,
      );

      TalkerService.info('Found ${results.length} products', 'ADVANCED_SEARCH');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error performing advanced search', 'ADVANCED_SEARCH', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
      );
    }
  }

  void setNovaGroup(int? novaGroup) {
    state = state.copyWith(selectedNovaGroup: novaGroup);
  }

  void setNutriScore(String? nutriScore) {
    state = state.copyWith(selectedNutriScore: nutriScore);
  }

  void toggleAllergen(String allergen) {
    final allergens = List<String>.from(state.excludedAllergens);
    if (allergens.contains(allergen)) {
      allergens.remove(allergen);
    } else {
      allergens.add(allergen);
    }
    state = state.copyWith(excludedAllergens: allergens);
  }

  void toggleBrand(String brand) {
    final brands = List<String>.from(state.selectedBrands);
    if (brands.contains(brand)) {
      brands.remove(brand);
    } else {
      brands.add(brand);
    }
    state = state.copyWith(selectedBrands: brands);
  }

  void toggleCategory(String category) {
    final categories = List<String>.from(state.selectedCategories);
    if (categories.contains(category)) {
      categories.remove(category);
    } else {
      categories.add(category);
    }
    state = state.copyWith(selectedCategories: categories);
  }

  void togglePalmOilFree() {
    state = state.copyWith(palmOilFree: !state.palmOilFree);
  }

  void toggleVegan() {
    state = state.copyWith(veganOnly: !state.veganOnly);
  }

  void toggleVegetarian() {
    state = state.copyWith(vegetarianOnly: !state.vegetarianOnly);
  }

  void updateQuery(String query) {
    state = state.copyWith(query: query);
  }

  List<FoodProductModel> _applyFilters(List<FoodProductModel> products) {
    var filtered = products;

    if (state.selectedNutriScore != null) {
      filtered = filtered
          .where((p) =>
              p.nutriScore?.toUpperCase() ==
              state.selectedNutriScore!.toUpperCase())
          .toList();
    }

    if (state.selectedNovaGroup != null) {
      filtered = filtered
          .where((p) => p.novaGroup == state.selectedNovaGroup)
          .toList();
    }

    if (state.veganOnly) {
      filtered = filtered.where((p) => p.isVegan == true).toList();
    }

    if (state.vegetarianOnly) {
      filtered = filtered.where((p) => p.isVegetarian == true).toList();
    }

    if (state.palmOilFree) {
      filtered = filtered.where((p) => p.palmOilFree == true).toList();
    }

    if (state.excludedAllergens.isNotEmpty) {
      filtered = filtered.where((p) {
        if (p.allergens == null) return true;
        return !p.allergens!.any((allergen) => state.excludedAllergens
            .any((a) => allergen.toLowerCase().contains(a.toLowerCase())));
      }).toList();
    }

    return filtered;
  }
}

/// State for advanced search form
class AdvancedSearchState {
  final String query;
  final List<String> selectedCategories;
  final List<String> selectedBrands;
  final String? selectedNutriScore;
  final int? selectedNovaGroup;
  final bool veganOnly;
  final bool vegetarianOnly;
  final bool palmOilFree;
  final List<String> excludedAllergens;
  final bool isLoading;
  final List<FoodProductModel> results;
  final String? errorMessage;

  AdvancedSearchState({
    this.query = '',
    this.selectedCategories = const [],
    this.selectedBrands = const [],
    this.selectedNutriScore,
    this.selectedNovaGroup,
    this.veganOnly = false,
    this.vegetarianOnly = false,
    this.palmOilFree = false,
    this.excludedAllergens = const [],
    this.isLoading = false,
    this.results = const [],
    this.errorMessage,
  });

  bool get hasActiveFilters =>
      selectedCategories.isNotEmpty ||
      selectedBrands.isNotEmpty ||
      selectedNutriScore != null ||
      selectedNovaGroup != null ||
      veganOnly ||
      vegetarianOnly ||
      palmOilFree ||
      excludedAllergens.isNotEmpty;

  AdvancedSearchState copyWith({
    String? query,
    List<String>? selectedCategories,
    List<String>? selectedBrands,
    String? selectedNutriScore,
    int? selectedNovaGroup,
    bool? veganOnly,
    bool? vegetarianOnly,
    bool? palmOilFree,
    List<String>? excludedAllergens,
    bool? isLoading,
    List<FoodProductModel>? results,
    String? errorMessage,
  }) {
    return AdvancedSearchState(
      query: query ?? this.query,
      selectedCategories: selectedCategories ?? this.selectedCategories,
      selectedBrands: selectedBrands ?? this.selectedBrands,
      selectedNutriScore: selectedNutriScore ?? this.selectedNutriScore,
      selectedNovaGroup: selectedNovaGroup ?? this.selectedNovaGroup,
      veganOnly: veganOnly ?? this.veganOnly,
      vegetarianOnly: vegetarianOnly ?? this.vegetarianOnly,
      palmOilFree: palmOilFree ?? this.palmOilFree,
      excludedAllergens: excludedAllergens ?? this.excludedAllergens,
      isLoading: isLoading ?? this.isLoading,
      results: results ?? this.results,
      errorMessage: errorMessage,
    );
  }
}

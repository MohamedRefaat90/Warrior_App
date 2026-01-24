import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/usecases.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/product_use_cases_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for advanced search state
final advancedSearchProvider =
    NotifierProvider.autoDispose<AdvancedSearchNotifier, AdvancedSearchState>(
        AdvancedSearchNotifier.new);

/// Advanced search notifier
class AdvancedSearchNotifier extends Notifier<AdvancedSearchState> {
  // Individual use cases
  SearchProductsByNameUseCase get _searchByNameUseCase =>
      ref.read(searchProductsByNameUseCaseProvider);

  @override
  AdvancedSearchState build() {
    return AdvancedSearchState();
  }

  void clearFilters() {
    state = AdvancedSearchState(query: state.query);
    TalkerService.info('Cleared all filters', 'ADVANCED_SEARCH');
  }

  /// Loads more results for infinite scroll pagination.
  Future<void> loadMoreResults() async {
    if (state.isLoadingMore || !state.hasMoreResults || state.isLoading) return;

    state = state.copyWith(isLoadingMore: true);
    final nextPage = state.currentPage + 1;

    try {
      List<ProductEntity> newResults = [];

      if (state.query.isNotEmpty) {
        newResults = await _searchByNameUseCase(
          state.query,
          page: nextPage,
          pageSize: AdvancedSearchState.pageSize,
        );
      }

      // Apply additional filters
      newResults = _applyFilters(newResults);

      // Determine if there are more results
      final hasMore = newResults.length >= AdvancedSearchState.pageSize;

      state = state.copyWith(
        results: [...state.results, ...newResults],
        isLoadingMore: false,
        currentPage: nextPage,
        hasMoreResults: hasMore,
      );

      TalkerService.info(
        'Loaded ${newResults.length} more products (page $nextPage)',
        'ADVANCED_SEARCH',
      );
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error loading more results', 'ADVANCED_SEARCH', e, stackTrace);
      state = state.copyWith(isLoadingMore: false);
    }
  }

  Future<void> performSearch() async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      currentPage: 1,
      hasMoreResults: true,
      results: [],
    );
    try {
      List<ProductEntity> results = [];

      if (state.query.isNotEmpty) {
        results = await _searchByNameUseCase(
          state.query,
          page: 1,
          pageSize: AdvancedSearchState.pageSize,
        );
      }

      // Apply additional filters
      results = _applyFilters(results);

      // Determine if there are more results
      final hasMore = results.length >= AdvancedSearchState.pageSize;

      state = state.copyWith(
        results: results,
        isLoading: false,
        hasMoreResults: hasMore,
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
    if (novaGroup == null) {
      state = state.copyWith(clearNovaGroup: true);
    } else {
      state = state.copyWith(selectedNovaGroup: novaGroup);
    }
  }

  void setNutriScore(String? nutriScore) {
    if (nutriScore == null) {
      state = state.copyWith(clearNutriScore: true);
    } else {
      state = state.copyWith(selectedNutriScore: nutriScore);
    }
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

  /// Applies local filtering to search results.
  ///
  /// Note: This duplicates filtering logic. In a future refactor, consider
  /// using FilterProductsUseCase directly, but that would require caching
  /// all products first, which may not be desirable for search results.
  List<ProductEntity> _applyFilters(List<ProductEntity> products) {
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
  static const int pageSize = 25;
  final String query;
  final String? selectedNutriScore;
  final int? selectedNovaGroup;
  final bool veganOnly;
  final bool vegetarianOnly;
  final bool palmOilFree;
  final List<String> excludedAllergens;
  final bool isLoading;
  final bool isLoadingMore;
  final List<ProductEntity> results;
  final String? errorMessage;
  final int currentPage;
  final bool hasMoreResults;

  AdvancedSearchState({
    this.query = '',
    this.selectedNutriScore,
    this.selectedNovaGroup,
    this.veganOnly = false,
    this.vegetarianOnly = false,
    this.palmOilFree = false,
    this.excludedAllergens = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.results = const [],
    this.errorMessage,
    this.currentPage = 1,
    this.hasMoreResults = true,
  });

  bool get hasActiveFilters =>
      selectedNutriScore != null ||
      selectedNovaGroup != null ||
      veganOnly ||
      vegetarianOnly ||
      palmOilFree ||
      excludedAllergens.isNotEmpty;

  /// Creates a copy with optional field updates.
  ///
  /// Use [clearNutriScore], [clearNovaGroup], and [clearErrorMessage]
  /// to explicitly set these nullable fields to null.
  AdvancedSearchState copyWith({
    String? query,
    String? selectedNutriScore,
    int? selectedNovaGroup,
    bool? veganOnly,
    bool? vegetarianOnly,
    bool? palmOilFree,
    List<String>? excludedAllergens,
    bool? isLoading,
    bool? isLoadingMore,
    List<ProductEntity>? results,
    String? errorMessage,
    int? currentPage,
    bool? hasMoreResults,
    bool clearNutriScore = false,
    bool clearNovaGroup = false,
    bool clearErrorMessage = false,
  }) {
    return AdvancedSearchState(
      query: query ?? this.query,
      selectedNutriScore: clearNutriScore
          ? null
          : (selectedNutriScore ?? this.selectedNutriScore),
      selectedNovaGroup:
          clearNovaGroup ? null : (selectedNovaGroup ?? this.selectedNovaGroup),
      veganOnly: veganOnly ?? this.veganOnly,
      vegetarianOnly: vegetarianOnly ?? this.vegetarianOnly,
      palmOilFree: palmOilFree ?? this.palmOilFree,
      excludedAllergens: excludedAllergens ?? this.excludedAllergens,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      results: results ?? this.results,
      errorMessage: clearErrorMessage ? null : errorMessage,
      currentPage: currentPage ?? this.currentPage,
      hasMoreResults: hasMoreResults ?? this.hasMoreResults,
    );
  }
}

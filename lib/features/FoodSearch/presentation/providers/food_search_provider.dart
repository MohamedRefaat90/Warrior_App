import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/product_use_cases_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for filtered products
final filteredProductsProvider =
    Provider.autoDispose<List<ProductEntity>>((ref) {
  final useCases = ref.watch(productUseCasesProvider);
  final filters = ref.watch(searchFiltersProvider);

  return useCases.filterProducts(
    nutriScore: filters.nutriScore,
    vegan: filters.vegan,
    vegetarian: filters.vegetarian,
    palmOilFree: filters.palmOilFree,
    allergens: filters.allergens,
    novaGroup: filters.novaGroup,
  );
});

/// Provider for product suggestions (autocomplete) with LRU caching.
///
/// Uses LRU (Least Recently Used) cache strategy:
/// - Maximum 50 entries to prevent unbounded growth
/// - 5-minute expiry for cache entries
/// - Recently accessed entries are kept longer
final productSuggestionsProvider =
    FutureProvider.family.autoDispose<List<String>, String>((ref, query) async {
  if (query.length < 2) return [];

  // Normalize query for cache key
  final cacheKey = query.toLowerCase().trim();

  // Check cache first with LRU promotion
  final cached = _SuggestionsLRUCache.get(cacheKey);
  if (cached != null) {
    return cached;
  }

  // Fetch from USE CASE
  final useCases = ref.watch(productUseCasesProvider);
  final suggestions = await useCases.getSuggestions(query);

  // Cache the result
  _SuggestionsLRUCache.put(cacheKey, suggestions);

  return suggestions;
});

/// Provider for recently scanned products
final recentlyScannedProvider =
    Provider.autoDispose<List<ProductEntity>>((ref) {
  final useCases = ref.watch(productUseCasesProvider);
  return useCases.getRecentlyScanned(limit: 10);
});

/// State provider for current search filters
final searchFiltersProvider =
    NotifierProvider.autoDispose<SearchFiltersNotifier, SearchFilters>(
        SearchFiltersNotifier.new);

/// Provider for searching product by barcode
final searchProductByBarcodeProvider = FutureProvider.family
    .autoDispose<ProductEntity?, String>((ref, barcode) async {
  final useCases = ref.watch(productUseCasesProvider);
  return await useCases.searchByBarcode(barcode);
});

/// Provider for searching products by name
final searchProductsByNameProvider = FutureProvider.family
    .autoDispose<List<ProductEntity>, String>((ref, query) async {
  final useCases = ref.watch(productUseCasesProvider);
  return await useCases.searchByName(query);
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

/// Cache entry for suggestions with timestamp.
class _SuggestionCacheEntry {
  final List<String> suggestions;
  final DateTime timestamp;

  _SuggestionCacheEntry(this.suggestions, this.timestamp);

  /// Check if cache entry is still valid (5 minutes).
  bool get isValid => DateTime.now().difference(timestamp).inMinutes < 5;
}

/// LRU Cache for product suggestions.
/// Uses LinkedHashMap to maintain insertion order and enable LRU eviction.
class _SuggestionsLRUCache {
  static const int _maxSize = 50;
  static const Duration _expiry = Duration(minutes: 5);
  static final _cache = <String, _SuggestionCacheEntry>{};

  /// Clear all cached entries.
  static void clear() => _cache.clear();

  /// Get a cached value, promoting it to most-recently-used if valid.
  static List<String>? get(String key) {
    final entry = _cache[key];
    if (entry == null) return null;

    if (!entry.isValid) {
      _cache.remove(key);
      return null;
    }

    // LRU: Move to end (most recently used)
    _cache.remove(key);
    _cache[key] = entry;
    return entry.suggestions;
  }

  /// Put a value in cache, evicting oldest if at capacity.
  static void put(String key, List<String> suggestions) {
    // Evict oldest entries if at capacity
    while (_cache.length >= _maxSize) {
      _cache.remove(_cache.keys.first);
    }

    _cache[key] = _SuggestionCacheEntry(suggestions, DateTime.now());
  }
}

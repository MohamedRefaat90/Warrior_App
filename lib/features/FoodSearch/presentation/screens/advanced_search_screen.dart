import 'dart:async';

import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/advanced_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/food_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/allergens_filter.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/dietary_preferences_filter.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/nova_group_filter.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/nutri_score_filter.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';

/// Advanced search screen with filters and autocomplete
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const AdvancedSearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen>
    with SingleTickerProviderStateMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;
  late AnimationController _filterAnimationController;
  late Animation<double> _filterAnimation;
  Timer? _debounceTimer;

  @override
  Widget build(BuildContext context) {
    final searchState = ref.watch(advancedSearchProvider);
    final searchNotifier = ref.read(advancedSearchProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: Text('advancedSearch'.tr(context)),
        actions: [
          if (searchState.hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: context.l10n.clearAllFilters,
              onPressed: () {
                searchNotifier.clearFilters();
                _searchController.clear();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search bar with autocomplete
          Padding(
            padding: context.screenPadding,
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: context.l10n.searchByName,
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              searchNotifier.updateQuery('');
                            },
                          )
                        : null,
                    border: OutlineInputBorder(
                      borderRadius:
                          BorderRadius.circular(context.responsiveBorderRadius),
                    ),
                  ),
                  onChanged: (value) {
                    // Cancel previous debounce timer
                    _debounceTimer?.cancel();
                    // Start new debounce timer (400ms delay)
                    _debounceTimer =
                        Timer(const Duration(milliseconds: 400), () {
                      searchNotifier.updateQuery(value);
                    });
                  },
                  onSubmitted: (value) {
                    // Cancel debounce and search immediately on submit
                    _debounceTimer?.cancel();
                    if (value.isNotEmpty) {
                      searchNotifier.updateQuery(value);
                      searchNotifier.performSearch();
                    }
                  },
                ),
                SizedBox(height: context.smallSpacing),
                // Autocomplete suggestions
                if (_searchController.text.length >= 2)
                  Consumer(
                    builder: (context, ref, child) {
                      final suggestions = ref.watch(
                          productSuggestionsProvider(_searchController.text));
                      return suggestions.when(
                        data: (items) {
                          if (items.isEmpty) return const SizedBox.shrink();
                          return Container(
                            constraints: BoxConstraints(
                                maxHeight: ResponsiveUtils.value(context,
                                    mobile: 100.0,
                                    tablet: 250.0,
                                    desktop: 280.0)),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(
                                  context.responsiveBorderRadius),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.1),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: items.length,
                              itemBuilder: (context, index) {
                                final suggestion = items[index];
                                return ListTile(
                                  leading: const Icon(Icons.search),
                                  title: Text(suggestion),
                                  onTap: () {
                                    _searchController.text = suggestion;
                                    searchNotifier.updateQuery(suggestion);
                                    searchNotifier.performSearch();
                                  },
                                );
                              },
                            ),
                          );
                        },
                        loading: () => Padding(
                          padding: EdgeInsets.symmetric(
                            vertical: context.smallSpacing,
                          ),
                          child: const LinearProgressIndicator(),
                        ),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                SizedBox(height: context.mediumSpacing),
                // Filter toggle and search button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: _toggleFilters,
                        icon: Icon(_showFilters
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined),
                        label: Text(
                          '${_showFilters ? context.l10n.hideFilters : context.l10n.showFilters} ${searchState.hasActiveFilters ? '(${_getActiveFilterCount(searchState)})' : ''}',
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(width: context.mediumSpacing),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: searchState.isLoading
                            ? null
                            : () => searchNotifier.performSearch(),
                        icon: searchState.isLoading
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child:
                                    CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                        label: Text('search'.tr(context),
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters section with slide animation
          SizeTransition(
            sizeFactor: _filterAnimation,
            axisAlignment: -1.0,
            child: SizedBox(
              height: context.screenHeight * 0.35,
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: context.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nutri-Score filter
                    NutriScoreFilter(
                      selectedScore: searchState.selectedNutriScore,
                      onSelected: searchNotifier.setNutriScore,
                    ),
                    SizedBox(height: context.mediumSpacing),

                    // NOVA Group filter
                    NovaGroupFilter(
                      selectedGroup: searchState.selectedNovaGroup,
                      onSelected: searchNotifier.setNovaGroup,
                    ),
                    SizedBox(height: context.mediumSpacing),

                    // Dietary preferences
                    DietaryPreferencesFilter(
                      veganOnly: searchState.veganOnly,
                      vegetarianOnly: searchState.vegetarianOnly,
                      palmOilFree: searchState.palmOilFree,
                      onToggleVegan: searchNotifier.toggleVegan,
                      onToggleVegetarian: searchNotifier.toggleVegetarian,
                      onTogglePalmOilFree: searchNotifier.togglePalmOilFree,
                    ),
                    SizedBox(height: context.mediumSpacing),

                    // Common allergens
                    AllergensFilter(
                      excludedAllergens: searchState.excludedAllergens,
                      onToggleAllergen: searchNotifier.toggleAllergen,
                    ),
                    SizedBox(height: context.mediumSpacing),
                  ],
                ),
              ),
            ),
          ),

          const Divider(height: 1),

          // Results section
          Expanded(
            child: _buildResults(searchState),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _filterAnimationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _filterAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _filterAnimation = CurvedAnimation(
      parent: _filterAnimationController,
      curve: Curves.easeInOut,
    );

    // Pre-fill search query if provided
    if (widget.initialQuery != null && widget.initialQuery!.isNotEmpty) {
      _searchController.text = widget.initialQuery!;
      // Trigger search after frame is built
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(advancedSearchProvider.notifier)
            .updateQuery(widget.initialQuery!);
        ref.read(advancedSearchProvider.notifier).performSearch();
      });
    }
  }

  Widget _buildResults(AdvancedSearchState searchState) {
    if (searchState.isLoading) {
      return const LoadingProductGrid();
    }

    if (searchState.errorMessage != null) {
      return ErrorStateWidget(
        message: searchState.errorMessage!,
        onRetry: () =>
            ref.read(advancedSearchProvider.notifier).performSearch(),
      );
    }

    if (searchState.results.isEmpty) {
      return EmptyStateWidget(
        title: context.l10n.noResults,
        message: context.l10n.noResultsFound,
        icon: Icons.search_off,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.read(advancedSearchProvider.notifier).performSearch();
      },
      child: NotificationListener<ScrollNotification>(
        onNotification: (scrollInfo) {
          // Trigger load more when near the bottom
          if (scrollInfo.metrics.pixels >=
                  scrollInfo.metrics.maxScrollExtent - 200 &&
              searchState.hasMoreResults &&
              !searchState.isLoadingMore &&
              !searchState.isLoading) {
            ref.read(advancedSearchProvider.notifier).loadMoreResults();
          }
          return false;
        },
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: context.screenPadding,
              sliver: SliverGrid(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: ResponsiveUtils.getGridColumns(context,
                      mobile: 2, tablet: 3, desktop: 4),
                  crossAxisSpacing: context.smallSpacing,
                  mainAxisSpacing: context.smallSpacing,
                  childAspectRatio: 0.85,
                ),
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final product = searchState.results[index];
                    return AnimationConfiguration.staggeredGrid(
                      position: index,
                      duration: const Duration(milliseconds: 375),
                      columnCount: ResponsiveUtils.getGridColumns(context,
                          mobile: 2, tablet: 3, desktop: 4),
                      child: ScaleAnimation(
                        child: FadeInAnimation(
                          child: ProductCard(product: product),
                        ),
                      ),
                    );
                  },
                  childCount: searchState.results.length,
                ),
              ),
            ),
            // Loading indicator at the bottom
            if (searchState.isLoadingMore)
              const SliverToBoxAdapter(
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
            // End of results indicator
            if (!searchState.hasMoreResults && searchState.results.isNotEmpty)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Center(
                    child: Text(
                      context.l10n.noMoreResults,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  int _getActiveFilterCount(AdvancedSearchState state) {
    int count = 0;
    if (state.selectedNutriScore != null) count++;
    if (state.selectedNovaGroup != null) count++;
    if (state.veganOnly) count++;
    if (state.vegetarianOnly) count++;
    if (state.palmOilFree) count++;
    count += state.excludedAllergens.length;
    return count;
  }

  void _toggleFilters() {
    setState(() {
      _showFilters = !_showFilters;
      if (_showFilters) {
        _filterAnimationController.forward();
      } else {
        _filterAnimationController.reverse();
      }
    });
  }
}

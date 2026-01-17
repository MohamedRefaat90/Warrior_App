import 'dart:async';

import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/advanced_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/food_search_provider.dart';
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
                    hintText: context.l10n.searchByNameBrandCategory,
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
                          style: TextStyle(
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
                            ? SizedBox(
                                width: 16,
                                height: 16,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(
                                Icons.search,
                                color: Colors.white,
                              ),
                        label: Text('search'.tr(context),
                            style: TextStyle(
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
              height: context.screenHeight * 0.25,
              child: SingleChildScrollView(
                padding:
                    EdgeInsets.symmetric(horizontal: context.mediumSpacing),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nutri-Score filter
                    _buildFilterSection(
                      context.l10n.nutriScore,
                      Wrap(
                        spacing: context.smallSpacing,
                        children: ['A', 'B', 'C', 'D', 'E'].map((score) {
                          final isSelected =
                              searchState.selectedNutriScore == score;
                          return FilterChip(
                            label: Text(
                              score,
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            selected: isSelected,
                            onSelected: (selected) {
                              searchNotifier
                                  .setNutriScore(selected ? score : null);
                            },
                            backgroundColor: _getNutriScoreColor(score)
                                .withValues(alpha: 0.2),
                            selectedColor: _getNutriScoreColor(score),
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: context.mediumSpacing),

                    // NOVA Group filter
                    _buildFilterSection(
                      context.l10n.novaGroup,
                      Wrap(
                        spacing: context.smallSpacing,
                        children: [1, 2, 3, 4].map((group) {
                          final isSelected =
                              searchState.selectedNovaGroup == group;
                          return FilterChip(
                            label: Text('${context.l10n.group} $group'),
                            selected: isSelected,
                            onSelected: (selected) {
                              searchNotifier
                                  .setNovaGroup(selected ? group : null);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    SizedBox(height: context.mediumSpacing),

                    // Dietary preferences
                    _buildFilterSection(
                      context.l10n.dietaryPreferences,
                      Column(
                        children: [
                          SwitchListTile(
                            title: Text('veganOnly'.tr(context)),
                            value: searchState.veganOnly,
                            onChanged: (_) => searchNotifier.toggleVegan(),
                          ),
                          SwitchListTile(
                            title: Text('vegetarianOnly'.tr(context)),
                            value: searchState.vegetarianOnly,
                            onChanged: (_) => searchNotifier.toggleVegetarian(),
                          ),
                          SwitchListTile(
                            title: Text(context.l10n.palmOilFree),
                            value: searchState.palmOilFree,
                            onChanged: (_) =>
                                searchNotifier.togglePalmOilFree(),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: context.mediumSpacing),

                    // Common allergens
                    _buildFilterSection(
                      context.l10n.excludeAllergens,
                      Wrap(
                        spacing: context.smallSpacing,
                        children: {
                          'milk': context.l10n.milk,
                          'eggs': context.l10n.eggs,
                          'peanuts': context.l10n.peanuts,
                          'tree nuts': context.l10n.treeNuts,
                          'soy': context.l10n.soy,
                          'wheat': context.l10n.wheat,
                          'fish': context.l10n.fish,
                          'shellfish': context.l10n.shellfish,
                        }.entries.map((entry) {
                          final isSelected =
                              searchState.excludedAllergens.contains(entry.key);
                          return FilterChip(
                            label: Text(entry.value),
                            selected: isSelected,
                            onSelected: (_) =>
                                searchNotifier.toggleAllergen(entry.key),
                          );
                        }).toList(),
                      ),
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

  Widget _buildFilterSection(String title, Widget content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: context.smallSpacing),
        content,
      ],
    );
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

  Color _getNutriScoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.yellow;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
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

import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/advanced_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/food_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Advanced search screen with filters and autocomplete
class AdvancedSearchScreen extends ConsumerStatefulWidget {
  final String? initialQuery;

  const AdvancedSearchScreen({super.key, this.initialQuery});

  @override
  ConsumerState<AdvancedSearchScreen> createState() =>
      _AdvancedSearchScreenState();
}

class _AdvancedSearchScreenState extends ConsumerState<AdvancedSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  bool _showFilters = false;

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
              tooltip: 'Clear all filters',
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
            padding: EdgeInsets.all(16.w),
            child: Column(
              children: [
                // Search field
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search by name, brand, or category...',
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
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onChanged: (value) {
                    searchNotifier.updateQuery(value);
                  },
                  onSubmitted: (value) {
                    if (value.isNotEmpty) {
                      searchNotifier.performSearch();
                    }
                  },
                ),
                8.verticalSpace,
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
                            constraints: BoxConstraints(maxHeight: 200.h),
                            decoration: BoxDecoration(
                              color: Theme.of(context).cardColor,
                              borderRadius: BorderRadius.circular(12),
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
                        loading: () => const SizedBox.shrink(),
                        error: (_, __) => const SizedBox.shrink(),
                      );
                    },
                  ),
                16.verticalSpace,
                // Filter toggle and search button
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          setState(() {
                            _showFilters = !_showFilters;
                          });
                        },
                        icon: Icon(_showFilters
                            ? Icons.filter_alt
                            : Icons.filter_alt_outlined),
                        label: Text(
                            '${_showFilters ? 'Hide' : 'Show'} Filters ${searchState.hasActiveFilters ? '(${_getActiveFilterCount(searchState)})' : ''}'),
                      ),
                    ),
                    16.horizontalSpace,
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: searchState.isLoading
                            ? null
                            : () => searchNotifier.performSearch(),
                        icon: searchState.isLoading
                            ? SizedBox(
                                width: 16.w,
                                height: 16.h,
                                child: const CircularProgressIndicator(
                                    strokeWidth: 2),
                              )
                            : const Icon(Icons.search),
                        label: Text('search'.tr(context)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Filters section
          if (_showFilters)
            Expanded(
              flex: 0,
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(horizontal: 16.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Nutri-Score filter
                    _buildFilterSection(
                      'Nutri-Score',
                      Wrap(
                        spacing: 8,
                        children: ['A', 'B', 'C', 'D', 'E'].map((score) {
                          final isSelected =
                              searchState.selectedNutriScore == score;
                          return FilterChip(
                            label: Text(score),
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
                    16.verticalSpace,

                    // NOVA Group filter
                    _buildFilterSection(
                      'NOVA Group',
                      Wrap(
                        spacing: 8,
                        children: [1, 2, 3, 4].map((group) {
                          final isSelected =
                              searchState.selectedNovaGroup == group;
                          return FilterChip(
                            label: Text('Group $group'),
                            selected: isSelected,
                            onSelected: (selected) {
                              searchNotifier
                                  .setNovaGroup(selected ? group : null);
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    16.verticalSpace,

                    // Dietary preferences
                    _buildFilterSection(
                      'Dietary Preferences',
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
                            title: const Text('Palm Oil Free'),
                            value: searchState.palmOilFree,
                            onChanged: (_) =>
                                searchNotifier.togglePalmOilFree(),
                          ),
                        ],
                      ),
                    ),
                    16.verticalSpace,

                    // Common allergens
                    _buildFilterSection(
                      'Exclude Allergens',
                      Wrap(
                        spacing: 8,
                        children: [
                          'Milk',
                          'Eggs',
                          'Peanuts',
                          'Tree Nuts',
                          'Soy',
                          'Wheat',
                          'Fish',
                          'Shellfish'
                        ].map((allergen) {
                          final isSelected = searchState.excludedAllergens
                              .contains(allergen.toLowerCase());
                          return FilterChip(
                            label: Text(allergen),
                            selected: isSelected,
                            onSelected: (_) => searchNotifier
                                .toggleAllergen(allergen.toLowerCase()),
                          );
                        }).toList(),
                      ),
                    ),
                    16.verticalSpace,
                  ],
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
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
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
        8.verticalSpace,
        content,
      ],
    );
  }

  Widget _buildResults(AdvancedSearchState searchState) {
    if (searchState.isLoading) {
      return const Center(child: CircularProgressIndicator());
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
        title: 'No Results',
        message: 'No results found.\nTry adjusting your search or filters.',
        icon: Icons.search_off,
      );
    }

    return GridView.builder(
      padding: EdgeInsets.all(16.w),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.7,
      ),
      itemCount: searchState.results.length,
      itemBuilder: (context, index) {
        final product = searchState.results[index];
        return ProductCard(product: product);
      },
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
}

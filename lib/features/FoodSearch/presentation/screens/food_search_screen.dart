import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/food_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main food search screen
class FoodSearchScreen extends ConsumerWidget {
  const FoodSearchScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentlyScanned = ref.watch(recentlyScannedProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('foodSearch'.tr(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'advancedSearchTooltip'.tr(context),
            onPressed: () {
              context.pushNamed(AppRouters.advancedSearch);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'searchHistoryTooltip'.tr(context),
            onPressed: () {
              context.pushNamed(AppRouters.searchHistory);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BannerAdWidget(),
            Expanded(
              child: SingleChildScrollView(
                padding: context.screenPadding,
                child: Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      maxWidth: ResponsiveUtils.maxContentWidth,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Quick action buttons - responsive grid
                        LayoutBuilder(
                          builder: (context, constraints) {
                            final columns = ResponsiveUtils.getGridColumns(
                                context,
                                mobile: 2,
                                tablet: 4,
                                desktop: 4);
                            if (columns >= 4) {
                              // Wide layout - all buttons in one row
                              return Row(
                                children: [
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.add_box,
                                      label: 'addProductButton'.tr(context),
                                      color: Colors.green,
                                      onTap: () => context
                                          .pushNamed(AppRouters.productForm),
                                    ),
                                  ),
                                  SizedBox(width: context.smallSpacing),
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.favorite,
                                      label: 'favoritesButton'.tr(context),
                                      color: Colors.red,
                                      onTap: () => context
                                          .pushNamed(AppRouters.favorites),
                                    ),
                                  ),
                                  SizedBox(width: context.smallSpacing),
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.filter_list,
                                      label:
                                          'advancedSearchTooltip'.tr(context),
                                      color: Colors.orange,
                                      onTap: () => context
                                          .pushNamed(AppRouters.advancedSearch),
                                    ),
                                  ),
                                  SizedBox(width: context.smallSpacing),
                                  Expanded(
                                    child: _QuickActionButton(
                                      icon: Icons.compare_arrows,
                                      label: 'compareButton'.tr(context),
                                      color: Colors.blue,
                                      onTap: () => context.pushNamed(
                                          AppRouters.productComparison),
                                    ),
                                  ),
                                ],
                              );
                            }
                            // Narrow layout - 2x2 grid
                            return Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _QuickActionButton(
                                        icon: Icons.add_box,
                                        label: 'Add Product',
                                        color: Colors.green,
                                        onTap: () => context
                                            .pushNamed(AppRouters.productForm),
                                      ),
                                    ),
                                    SizedBox(width: context.smallSpacing),
                                    Expanded(
                                      child: _QuickActionButton(
                                        icon: Icons.favorite,
                                        label: 'Favorites',
                                        color: Colors.red,
                                        onTap: () => context
                                            .pushNamed(AppRouters.favorites),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: context.mediumSpacing),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _QuickActionButton(
                                        icon: Icons.filter_list,
                                        label: 'Advanced Search',
                                        color: Colors.orange,
                                        onTap: () => context.pushNamed(
                                            AppRouters.advancedSearch),
                                      ),
                                    ),
                                    SizedBox(width: context.smallSpacing),
                                    Expanded(
                                      child: _QuickActionButton(
                                        icon: Icons.compare_arrows,
                                        label: 'Compare',
                                        color: Colors.blue,
                                        onTap: () => context.pushNamed(
                                            AppRouters.productComparison),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            );
                          },
                        ),
                        SizedBox(height: context.mediumSpacing),
                        // Full-width guide button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            onPressed: () {
                              context.pushNamed(AppRouters.nutritionGuide);
                            },
                            icon: const Icon(Icons.school_outlined),
                            label: Text('understandingFoodScores'.tr(context)),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: context.mediumSpacing),
                              backgroundColor: Theme.of(context)
                                  .colorScheme
                                  .primaryContainer,
                              foregroundColor: Theme.of(context)
                                  .colorScheme
                                  .onPrimaryContainer,
                            ),
                          ),
                        ),
                        SizedBox(height: context.largeSpacing),
                        // Recently scanned section
                        if (recentlyScanned.isNotEmpty) ...[
                          Text(
                            'recentlyScanned'.tr(context),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          SizedBox(height: context.smallSpacing),
                          SizedBox(
                            height: ResponsiveUtils.value(context,
                                mobile: 220.0, tablet: 250.0, desktop: 280.0),
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: recentlyScanned.length,
                              itemBuilder: (context, index) {
                                return SizedBox(
                                  width: ResponsiveUtils.value(context,
                                      mobile: 160.0,
                                      tablet: 180.0,
                                      desktop: 200.0),
                                  child: ProductCard(
                                    product: recentlyScanned[index],
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: context.largeSpacing),
                        ],
                        // Empty state
                        if (recentlyScanned.isEmpty)
                          EmptyStateWidget(
                            title: 'noProductsYet'.tr(context),
                            message: 'startByScanningBarcode'.tr(context),
                            icon: Icons.qr_code_scanner,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          context.pushNamed(AppRouters.barcodeScanner);
        },
        icon: const Icon(Icons.qr_code_scanner),
        label: Text('scan'.tr(context)),
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      shadowColor: Colors.black.withValues(alpha: 0.7),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            vertical: context.mediumSpacing,
            horizontal: context.smallSpacing,
          ),
          child: Column(
            children: [
              Icon(
                icon,
                size: ResponsiveUtils.iconSize(context,
                    mobile: 32, tablet: 36, desktop: 40),
                color: color,
              ),
              SizedBox(height: context.smallSpacing),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

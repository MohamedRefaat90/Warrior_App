import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/interstitial_ad_manager.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/food_search_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_dialog.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Main food search screen
class FoodSearchScreen extends ConsumerStatefulWidget {
  const FoodSearchScreen({super.key});

  @override
  ConsumerState<FoodSearchScreen> createState() => _FoodSearchScreenState();
}

class _FoodSearchScreenState extends ConsumerState<FoodSearchScreen> {
  late final InterstitialAdManager foodSearchAd;

  @override
  Widget build(BuildContext context) {
    final recentlyScanned = ref.watch(recentlyScannedProvider);
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text('foodSearch'.tr(context)),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: context.l10n.advancedSearchTooltip,
            onPressed: () {
              context.pushNamed(AppRouters.advancedSearch);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: context.l10n.searchHistoryTooltip,
            onPressed: () {
              context.pushNamed(AppRouters.searchHistory);
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            const BannerAdWidget(
                adUnitId: "ca-app-pub-7417773148722475/3544140673"),
            Expanded(
              child: RefreshIndicator(
                onRefresh: () async {
                  // Reload recently scanned products
                  ref.invalidate(recentlyScannedProvider);
                },
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
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
                                        label: context.l10n.addProductButton,
                                        color: Colors.green,
                                        onTap: () => context
                                            .pushNamed(AppRouters.productForm),
                                      ),
                                    ),
                                    SizedBox(width: context.smallSpacing),
                                    Expanded(
                                      child: _QuickActionButton(
                                        icon: Icons.favorite,
                                        label: context.l10n.favoritesButton,
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
                                            context.l10n.advancedSearchTooltip,
                                        color: Colors.orange,
                                        onTap: () => context.pushNamed(
                                            AppRouters.advancedSearch),
                                      ),
                                    ),
                                    SizedBox(width: context.smallSpacing),
                                    Expanded(
                                      child: _QuickActionButton(
                                        icon: Icons.compare_arrows,
                                        label: context.l10n.compareButton,
                                        color: Colors.blue,
                                        onTap: () {
                                          foodSearchAd.showAd(
                                              onAdDismissed: () {
                                            context.pushNamed(
                                                AppRouters.productComparison);
                                          });
                                        },
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
                                          label: context.l10n.addProductButton,
                                          color: Colors.green,
                                          onTap: () => context.pushNamed(
                                              AppRouters.productForm),
                                        ),
                                      ),
                                      SizedBox(width: context.smallSpacing),
                                      Expanded(
                                        child: _QuickActionButton(
                                          icon: Icons.favorite,
                                          label: context.l10n.favoritesButton,
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
                                          label: context
                                              .l10n.advancedSearchTooltip,
                                          color: Colors.orange,
                                          onTap: () {
                                            foodSearchAd.showAd(
                                                onAdDismissed: () {
                                              context.pushNamed(
                                                  AppRouters.advancedSearch);
                                            });
                                          },
                                        ),
                                      ),
                                      SizedBox(width: context.smallSpacing),
                                      Expanded(
                                        child: _QuickActionButton(
                                          icon: Icons.compare_arrows,
                                          label: context.l10n.compareButton,
                                          color: Colors.blue,
                                          onTap: () {
                                            foodSearchAd.showAd(
                                                onAdDismissed: () {
                                              context.pushNamed(
                                                  AppRouters.productComparison);
                                            });
                                          },
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
                                foodSearchAd.showAd(onAdDismissed: () {
                                  context.pushNamed(AppRouters.nutritionGuide);
                                });
                              },
                              icon: Icon(
                                Icons.school_outlined,
                                color: isDarkMode
                                    ? AppColors.darkSurfaceVariant
                                    : AppColors.white,
                                size: 20,
                              ),
                              label: Text(
                                context.l10n.understandingFoodScores,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: isDarkMode
                                      ? AppColors.darkSurfaceVariant
                                      : AppColors.white,
                                ),
                              ),
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.symmetric(
                                    vertical: context.mediumSpacing),
                                backgroundColor: isDarkMode
                                    ? AppColors.white
                                    : AppColors.darkSurfaceVariant,
                                // foregroundColor: AppColors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: context.largeSpacing),
                          // Recently scanned section
                          if (recentlyScanned.isNotEmpty) ...[
                            Text(
                              context.l10n.recentlyScanned,
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
                              title: context.l10n.noProductsYet,
                              message: context.l10n.startByScanningBarcode,
                              icon: Icons.qr_code_scanner,
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.primaryColor,
        onPressed: () {
          foodSearchAd.showAd(onAdDismissed: () {
            context.pushNamed(AppRouters.barcodeScanner);
          });
        },
        icon: const Icon(
          Icons.qr_code_scanner,
          color: Colors.white,
        ),
        label: Text(context.l10n.scan,
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }

  @override
  void dispose() {
    foodSearchAd.dispose();
    super.dispose();
  }

  @override
  void initState() {
    foodSearchAd = InterstitialAdManager.forAdUnit(
        'ca-app-pub-7417773148722475/5173643464');
    foodSearchAd.loadAd();
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final bool? foodSearchAlert =
          SharedPref.getBool(StorageKeys.foodSearchAlert);
      if (foodSearchAlert == null || foodSearchAlert == false) {
        TalkerService.info('Showing food search dialog...', 'FOOD_SEARCH');
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const FoodSearchDialog(),
        );
      }
    });
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
                style: Theme.of(context)
                    .textTheme
                    .bodySmall!
                    .copyWith(fontWeight: FontWeight.w600),
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

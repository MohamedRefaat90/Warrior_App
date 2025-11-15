import 'package:Warrior/core/constants/routers.dart';
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
        title: const Text('Food Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Advanced Search',
            onPressed: () {
              context.pushNamed(AppRouters.advancedSearch);
            },
          ),
          IconButton(
            icon: const Icon(Icons.history),
            tooltip: 'Search History',
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
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Quick action buttons
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.add_box,
                            label: 'Add Product',
                            color: Colors.green,
                            onTap: () {
                              context.pushNamed(AppRouters.productForm);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.favorite,
                            label: 'Favorites',
                            color: Colors.red,
                            onTap: () {
                              context.pushNamed(AppRouters.favorites);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.filter_list,
                            label: 'Advanced Search',
                            color: Colors.orange,
                            onTap: () {
                              context.pushNamed(AppRouters.advancedSearch);
                            },
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _QuickActionButton(
                            icon: Icons.compare_arrows,
                            label: 'Compare',
                            color: Colors.blue,
                            onTap: () {
                              context.pushNamed(AppRouters.productComparison);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Full-width guide button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          context.pushNamed(AppRouters.nutritionGuide);
                        },
                        icon: const Icon(Icons.school_outlined),
                        label: const Text('Understanding Food Scores'),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          backgroundColor:
                              Theme.of(context).colorScheme.primaryContainer,
                          foregroundColor:
                              Theme.of(context).colorScheme.onPrimaryContainer,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Recently scanned section
                    if (recentlyScanned.isNotEmpty) ...[
                      Text(
                        'Recently Scanned',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 220,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: recentlyScanned.length,
                          itemBuilder: (context, index) {
                            return SizedBox(
                              width: 160,
                              child: ProductCard(
                                product: recentlyScanned[index],
                              ),
                            );
                          },
                        ),
                      ),
                      const SizedBox(height: 24),
                    ],
                    // Empty state
                    if (recentlyScanned.isEmpty)
                      const EmptyStateWidget(
                        title: 'No Products Yet',
                        message:
                            'Start by scanning a barcode or searching for products',
                        icon: Icons.qr_code_scanner,
                      ),
                  ],
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
        label: const Text('Scan'),
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
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 32,
                color: color,
              ),
              const SizedBox(height: 8),
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

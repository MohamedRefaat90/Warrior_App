import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/comparison_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_comparison/product_comparison_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Product comparison screen for side-by-side comparison
class ProductComparisonScreen extends ConsumerWidget {
  const ProductComparisonScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final comparisonProducts = ref.watch(comparisonProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text('compareProducts'.tr(context)),
        actions: [
          if (comparisonProducts.isNotEmpty)
            IconButton(
              icon: const Icon(Icons.clear_all),
              tooltip: context.l10n.clearAll,
              onPressed: () {
                ref.read(comparisonProvider.notifier).clearComparison();
              },
            ),
        ],
      ),
      body: _buildBody(context, comparisonProducts),
      floatingActionButton: comparisonProducts.length < 3
          ? FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed(AppRouters.advancedSearch);
              },
              icon: const Icon(Icons.add, color: AppColors.white),
              label: Text(
                'addProduct'.tr(context),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildBody(
      BuildContext context, List<ProductEntity> comparisonProducts) {
    if (comparisonProducts.isEmpty) {
      return EmptyStateWidget(
        title: context.l10n.noProductsToCompare,
        message: context.l10n.addProductsToCompare,
        icon: Icons.compare_arrows,
        actionLabel: context.l10n.searchProducts,
        onAction: () {
          context.pushNamed(AppRouters.advancedSearch);
        },
      );
    }

    if (comparisonProducts.length == 1) {
      return SingleProductView(product: comparisonProducts[0]);
    }

    return ComparisonContentView(products: comparisonProducts);
  }
}

import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// View displayed when only one product is in the comparison list.
class SingleProductView extends StatelessWidget {
  final ProductEntity product;

  const SingleProductView({
    super.key,
    required this.product,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProductImageWidget(
            imageUrl: product.imageUrl,
            width: 150,
            height: 150,
          ),
          const SizedBox(height: 16),
          Text(
            product.productName ?? context.l10n.unknownProduct,
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          if (product.brands != null) ...[
            const SizedBox(height: 4),
            Text(
              product.brands!,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            context.l10n.addMoreProductsToCompare,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              context.pushNamed(AppRouters.advancedSearch);
            },
            icon: const Icon(Icons.add),
            label: Text('addAnotherProduct'.tr(context)),
          ),
        ],
      ),
    );
  }
}

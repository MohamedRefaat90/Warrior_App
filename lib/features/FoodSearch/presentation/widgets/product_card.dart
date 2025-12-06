import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/favorites_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_score_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Compact product card for lists
class ProductCard extends ConsumerWidget {
  final FoodProductModel product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.barcode));

    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.5),
      child: InkWell(
        onTap: () {
          context.pushNamed(AppRouters.productDetails, extra: product);
        },
        child: Stack(
          children: [
            Padding(
              padding: context.cardPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Product image with favorite button
                  Stack(
                    children: [
                      Center(
                        child: ProductImageWidget(
                          imageUrl: product.imageFrontUrl ?? product.imageUrl,
                          width: double.infinity,
                          height: ResponsiveUtils.value(context,
                              mobile: 105.0, tablet: 130.0, desktop: 150.0),
                          fit: BoxFit.cover,
                        ),
                      ),
                      if (product.nutriScore != null)
                        Positioned(
                          bottom: 4,
                          left: 4,
                          child: NutritionScoreBadge(
                            nutriScore: product.nutriScore,
                            size: 32,
                          ),
                        ),
                    ],
                  ),
                  SizedBox(height: context.smallSpacing),
                  // Product name
                  Text(
                    product.productName ?? 'Unknown Product',
                    style: Theme.of(context).textTheme.titleSmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.smallSpacing / 2),
                  // Brand
                  if (product.brands != null)
                    Text(
                      product.brands!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.6),
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  SizedBox(height: context.smallSpacing / 3),
                  // Quantity
                  if (product.quantity != null)
                    Text(
                      product.quantity!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurface
                                .withValues(alpha: 0.5),
                          ),
                    ),
                ],
              ),
            ),
            // if (isFavorite)
            Positioned(
              bottom: 0,
              left: 0,
              child: IconButton(
                icon: Icon(isFavorite ? Icons.favorite : Icons.favorite_border,
                    color: isFavorite ? Colors.red : Colors.grey),
                onPressed: () {
                  isFavorite
                      ? ref
                          .read(favoritesProvider.notifier)
                          .removeFavorite(product.barcode)
                      : ref
                          .read(favoritesProvider.notifier)
                          .addFavorite(product);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

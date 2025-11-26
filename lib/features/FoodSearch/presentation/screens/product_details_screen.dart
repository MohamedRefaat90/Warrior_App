import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/comparison_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/favorites_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nova_group_indicator.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_score_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class Allergens extends StatelessWidget {
  final FoodProductModel product;

  const Allergens({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return product.allergens != null && product.allergens!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Allergens',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: context.smallSpacing),
              Wrap(
                spacing: context.smallSpacing,
                runSpacing: context.smallSpacing,
                children: product.allergens!
                    .map((allergen) => AllergenChip(allergen: allergen))
                    .toList(),
              ),
              SizedBox(height: context.largeSpacing),
            ],
          )
        : const SizedBox.shrink();
  }
}

class Ingredients extends StatelessWidget {
  final FoodProductModel product;

  const Ingredients({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return product.ingredients != null && product.ingredients!.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ingredients',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: context.smallSpacing),
              Text(
                product.ingredients!,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              SizedBox(height: context.largeSpacing),
            ],
          )
        : const SizedBox.shrink();
  }
}

class Labels extends StatelessWidget {
  final FoodProductModel product;

  const Labels({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return product.isVegan == true ||
            product.isVegetarian == true ||
            product.palmOilFree == true
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Labels',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: context.smallSpacing),
              Wrap(
                spacing: context.smallSpacing,
                runSpacing: context.smallSpacing,
                children: [
                  if (product.isVegan == true)
                    Chip(
                      label: Text('vegan'.tr(context)),
                      backgroundColor: Colors.green[100],
                    ),
                  if (product.isVegetarian == true)
                    Chip(
                      label: Text('vegetarian'.tr(context)),
                      backgroundColor: Colors.green[100],
                    ),
                  if (product.palmOilFree == true)
                    Chip(
                      label: Text('palmOilFree'.tr(context)),
                      backgroundColor: Colors.green[100],
                    ),
                ],
              ),
            ],
          )
        : const SizedBox.shrink();
  }
}

class NutritionFacts extends StatelessWidget {
  final FoodProductModel product;

  const NutritionFacts({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return product.nutritionValues != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nutrition Facts (per 100g)',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              SizedBox(height: context.smallSpacing),
              if (product.nutritionValues!.energyKcal != null)
                NutritionProgressBar(
                  label: 'Energy',
                  value: product.nutritionValues!.energyKcal!,
                  maxValue: 2000,
                  unit: 'kcal',
                ),
              SizedBox(height: context.smallSpacing),
              if (product.nutritionValues!.proteins != null)
                NutritionProgressBar(
                  label: 'Proteins',
                  value: product.nutritionValues!.proteins!,
                  maxValue: 50,
                ),
              SizedBox(height: context.smallSpacing),
              if (product.nutritionValues!.carbohydrates != null)
                NutritionProgressBar(
                  label: 'Carbohydrates',
                  value: product.nutritionValues!.carbohydrates!,
                  maxValue: 275,
                ),
              SizedBox(height: context.smallSpacing),
              if (product.nutritionValues!.sugars != null)
                NutritionProgressBar(
                  label: 'Sugars',
                  value: product.nutritionValues!.sugars!,
                  maxValue: 90,
                ),
              SizedBox(height: context.smallSpacing),
              if (product.nutritionValues!.fat != null)
                NutritionProgressBar(
                  label: 'Fat',
                  value: product.nutritionValues!.fat!,
                  maxValue: 70,
                ),
              SizedBox(height: context.largeSpacing),
            ],
          )
        : const SizedBox.shrink();
  }
}

/// Comprehensive product details screen
class ProductDetailsScreen extends ConsumerWidget {
  final FoodProductModel product;

  const ProductDetailsScreen({super.key, required this.product});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(product.barcode));
    final isInComparison = ref.watch(isInComparisonProvider(product.barcode));

    TalkerService.warning(
        'Eco-Score: ${product.ecoscore}', 'ProductDetailsScreen');
    TalkerService.warning('Labels: ${product.labels}', 'ProductDetailsScreen');
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: ResponsiveUtils.value(context,
                mobile: 300.0, tablet: 350.0, desktop: 400.0),
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Hero(
                tag: 'product_${product.barcode}',
                child: ProductImageWidget(
                  imageUrl: product.imageFrontUrl ?? product.imageUrl,
                  width: double.infinity,
                  height: ResponsiveUtils.value(context,
                      mobile: 300.0, tablet: 350.0, desktop: 400.0),
                  fit: BoxFit.contain,
                ),
              ),
            ),
            actions: [
              // Edit product button
              IconButton(
                icon: const Icon(Icons.edit),
                tooltip: 'Edit Product Info',
                onPressed: () {
                  context.pushNamed(
                    AppRouters.productForm,
                    extra: {'product': product},
                  );
                },
              ),
              // Favorite button
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  ref.read(favoritesProvider.notifier).toggleFavorite(product);
                },
              )
            ],
          ),
          SliverToBoxAdapter(
            child: Center(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: ResponsiveUtils.maxContentWidth,
                ),
                child: Padding(
                  padding: context.screenPadding,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Product name and brand
                      Text(
                        product.productName ?? 'Unknown Product',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      if (product.brands != null) ...[
                        SizedBox(height: context.smallSpacing / 2),
                        Text(
                          product.brands!,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                  ),
                        ),
                      ],
                      if (product.quantity != null) ...[
                        SizedBox(height: context.smallSpacing / 2),
                        Text(
                          product.quantity!,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                      SizedBox(height: context.largeSpacing),

                      // Nutrition Scores
                      Text(
                        'Nutrition Scores',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      SizedBox(height: context.smallSpacing),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          if (product.nutriScore != null)
                            Column(
                              children: [
                                NutritionScoreShield(
                                    nutriScore: product.nutriScore),
                                SizedBox(height: context.smallSpacing / 2),
                                Text('nutriScore'.tr(context),
                                    style:
                                        Theme.of(context).textTheme.bodySmall),
                              ],
                            ),
                          if (product.novaGroup != null)
                            Column(
                              children: [
                                NovaGroupIndicator(
                                  novaGroup: product.novaGroup,
                                  size: 20,
                                ),
                                SizedBox(height: context.smallSpacing),
                                Text(
                                  'NOVA ${product.novaGroup}',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          if (product.ecoscore != null)
                            Column(
                              children: [
                                EcoscoreWidget(
                                  ecoscore: product.ecoscore,
                                  size: 60,
                                ),
                                SizedBox(height: context.smallSpacing / 2),
                                Text(
                                  'Eco-Score',
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                        ],
                      ),
                      SizedBox(height: context.largeSpacing),

                      // Nutrition Facts
                      NutritionFacts(product: product),

                      // Allergens
                      Allergens(product: product),

                      // Ingredients
                      Ingredients(product: product),

                      // Labels
                      Labels(product: product)
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          if (isInComparison) {
            ref
                .read(comparisonProvider.notifier)
                .removeProduct(product.barcode);
          } else {
            ref.read(comparisonProvider.notifier).addProduct(product);
          }
        },
        icon: Icon(isInComparison ? Icons.remove : Icons.compare_arrows),
        label: Text(isInComparison ? 'Remove from Compare' : 'Add to Compare'),
      ),
    );
  }
}

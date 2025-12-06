import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_score_badge.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_comparison/comparison_section_row.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_comparison/nutrition_comparison_row.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_comparison/product_header_card.dart';
import 'package:flutter/material.dart';

/// The main comparison view displaying multiple products side by side.
class ComparisonContentView extends StatelessWidget {
  final List<FoodProductModel> products;

  const ComparisonContentView({
    super.key,
    required this.products,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Product headers
          SizedBox(
            height: ResponsiveUtils.value(context,
                mobile: 200.0, tablet: 220.0, desktop: 240.0),
            child: Row(
              children: products
                  .map((product) => Expanded(
                        child: ProductHeaderCard(product: product),
                      ))
                  .toList(),
            ),
          ),
          const Divider(thickness: 2),

          // Score comparison rows
          _buildScoreComparisons(context),

          const Divider(thickness: 2),

          // Nutrition comparison
          if (products.any((p) => p.nutritionValues != null))
            _buildNutritionComparisons(context),

          const Divider(thickness: 2),

          // Dietary information
          _buildDietaryInformation(context),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildDietaryInformation(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.dietaryInformation,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        ComparisonSectionRow(
          title: context.l10n.vegan,
          values: products
              .map((p) => Icon(
                    p.isVegan == true ? Icons.check_circle : Icons.cancel,
                    color: p.isVegan == true ? Colors.green : Colors.red,
                    size: 30,
                  ))
              .toList(),
        ),
        ComparisonSectionRow(
          title: context.l10n.vegetarian,
          values: products
              .map((p) => Icon(
                    p.isVegetarian == true ? Icons.check_circle : Icons.cancel,
                    color: p.isVegetarian == true ? Colors.green : Colors.red,
                    size: 30,
                  ))
              .toList(),
        ),
        ComparisonSectionRow(
          title: context.l10n.palmOilFree,
          values: products
              .map((p) => Icon(
                    p.palmOilFree == true ? Icons.check_circle : Icons.cancel,
                    color: p.palmOilFree == true ? Colors.green : Colors.red,
                    size: 30,
                  ))
              .toList(),
        ),
      ],
    );
  }

  Widget _buildNutritionComparisons(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16),
          child: Text(
            context.l10n.nutritionalValuesPer100g,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
          ),
        ),
        NutritionComparisonRow(
          label: '${context.l10n.energy} (kcal)',
          values: products
              .map((p) =>
                  p.nutritionValues?.energyKcal?.toStringAsFixed(0) ?? 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.proteins,
          values: products
              .map((p) => p.nutritionValues?.proteins != null
                  ? '${p.nutritionValues!.proteins!.toStringAsFixed(1)}g'
                  : 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.carbohydrates,
          values: products
              .map((p) => p.nutritionValues?.carbohydrates != null
                  ? '${p.nutritionValues!.carbohydrates!.toStringAsFixed(1)}g'
                  : 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.sugars,
          values: products
              .map((p) => p.nutritionValues?.sugars != null
                  ? '${p.nutritionValues!.sugars!.toStringAsFixed(1)}g'
                  : 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.fat,
          values: products
              .map((p) => p.nutritionValues?.fat != null
                  ? '${p.nutritionValues!.fat!.toStringAsFixed(1)}g'
                  : 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.saturatedFat,
          values: products
              .map((p) => p.nutritionValues?.saturatedFat != null
                  ? '${p.nutritionValues!.saturatedFat!.toStringAsFixed(1)}g'
                  : 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.fiber,
          values: products
              .map((p) => p.nutritionValues?.fiber != null
                  ? '${p.nutritionValues!.fiber!.toStringAsFixed(1)}g'
                  : 'N/A')
              .toList(),
        ),
        NutritionComparisonRow(
          label: context.l10n.salt,
          values: products
              .map((p) => p.nutritionValues?.salt != null
                  ? '${p.nutritionValues!.salt!.toStringAsFixed(2)}g'
                  : 'N/A')
              .toList(),
        ),
      ],
    );
  }

  Widget _buildScoreComparisons(BuildContext context) {
    return Column(
      children: [
        ComparisonSectionRow(
          title: context.l10n.nutriScore,
          values: products
              .map((p) => p.nutriScore != null
                  ? NutritionScoreBadge(nutriScore: p.nutriScore, size: 50)
                  : Text('na'.tr(context)))
              .toList(),
        ),
        ComparisonSectionRow(
          title: context.l10n.novaGroup,
          values: products
              .map((p) => Text(
                    p.novaGroup != null
                        ? '${context.l10n.group} ${p.novaGroup}'
                        : 'na'.tr(context),
                    style: const TextStyle(fontSize: 13),
                  ))
              .toList(),
        ),
        ComparisonSectionRow(
          title: context.l10n.ecoScore,
          values: products
              .map((p) => p.ecoscore != null
                  ? EcoscoreWidget(ecoscore: p.ecoscore, size: 50)
                  : Text('na'.tr(context)))
              .toList(),
        ),
      ],
    );
  }
}

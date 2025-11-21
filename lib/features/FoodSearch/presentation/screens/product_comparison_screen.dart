import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/comparison_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_score_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              tooltip: 'Clear all',
              onPressed: () {
                ref.read(comparisonProvider.notifier).clearComparison();
              },
            ),
        ],
      ),
      body: comparisonProducts.isEmpty
          ? EmptyStateWidget(
              title: 'No Products to Compare',
              message:
                  'Add products from search results to compare their nutritional values.',
              icon: Icons.compare_arrows,
              actionLabel: 'Search Products',
              onAction: () {
                context.pushNamed(AppRouters.advancedSearch);
              },
            )
          : comparisonProducts.length == 1
              ? _buildSingleProductView(context, comparisonProducts[0], ref)
              : _buildComparisonView(context, comparisonProducts, ref),
      floatingActionButton: comparisonProducts.length < 3
          ? FloatingActionButton.extended(
              onPressed: () {
                context.pushNamed(AppRouters.advancedSearch);
              },
              icon: const Icon(Icons.add),
              label: Text('addProduct'.tr(context)),
            )
          : null,
    );
  }

  Widget _buildComparisonSection(
    BuildContext context,
    String title,
    List<Widget> values,
  ) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...values.map((value) => Expanded(
                flex: 3,
                child: Center(child: value),
              )),
        ],
      ),
    );
  }

  Widget _buildComparisonView(
    BuildContext context,
    List<FoodProductModel> products,
    WidgetRef ref,
  ) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Product headers
          SizedBox(
            height: 200.h,
            child: Row(
              children: products
                  .map((product) => Expanded(
                        child: _buildProductHeader(context, product, ref),
                      ))
                  .toList(),
            ),
          ),
          const Divider(thickness: 2),

          // Comparison rows
          _buildComparisonSection(
            context,
            'Nutri-Score',
            products
                .map((p) => p.nutriScore != null
                    ? NutritionScoreBadge(nutriScore: p.nutriScore, size: 50)
                    : Text('na'.tr(context)))
                .toList(),
          ),
          _buildComparisonSection(
            context,
            'NOVA Group',
            products
                .map((p) => Text(
                      p.novaGroup != null
                          ? 'Group ${p.novaGroup}'
                          : 'na'.tr(context),
                      style: Theme.of(context).textTheme.titleMedium,
                    ))
                .toList(),
          ),
          _buildComparisonSection(
            context,
            'Eco-Score',
            products
                .map((p) => p.ecoscore != null
                    ? EcoscoreWidget(ecoscore: p.ecoscore, size: 50)
                    : Text('na'.tr(context)))
                .toList(),
          ),

          const Divider(thickness: 2),

          // Nutrition comparison
          if (products.any((p) => p.nutritionValues != null)) ...[
            Padding(
              padding: EdgeInsets.all(16.w),
              child: Text(
                'Nutritional Values (per 100g)',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            _buildNutritionComparisonRow(
              context,
              'Energy (kcal)',
              products
                  .map((p) =>
                      p.nutritionValues?.energyKcal?.toStringAsFixed(0) ??
                      'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Proteins',
              products
                  .map((p) => p.nutritionValues?.proteins != null
                      ? '${p.nutritionValues!.proteins!.toStringAsFixed(1)}g'
                      : 'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Carbohydrates',
              products
                  .map((p) => p.nutritionValues?.carbohydrates != null
                      ? '${p.nutritionValues!.carbohydrates!.toStringAsFixed(1)}g'
                      : 'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Sugars',
              products
                  .map((p) => p.nutritionValues?.sugars != null
                      ? '${p.nutritionValues!.sugars!.toStringAsFixed(1)}g'
                      : 'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Fat',
              products
                  .map((p) => p.nutritionValues?.fat != null
                      ? '${p.nutritionValues!.fat!.toStringAsFixed(1)}g'
                      : 'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Saturated Fat',
              products
                  .map((p) => p.nutritionValues?.saturatedFat != null
                      ? '${p.nutritionValues!.saturatedFat!.toStringAsFixed(1)}g'
                      : 'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Fiber',
              products
                  .map((p) => p.nutritionValues?.fiber != null
                      ? '${p.nutritionValues!.fiber!.toStringAsFixed(1)}g'
                      : 'N/A')
                  .toList(),
            ),
            _buildNutritionComparisonRow(
              context,
              'Salt',
              products
                  .map((p) => p.nutritionValues?.salt != null
                      ? '${p.nutritionValues!.salt!.toStringAsFixed(2)}g'
                      : 'N/A')
                  .toList(),
            ),
          ],

          const Divider(thickness: 2),

          // Dietary information
          Padding(
            padding: EdgeInsets.all(16.w),
            child: Text(
              'Dietary Information',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          _buildComparisonSection(
            context,
            'Vegan',
            products
                .map((p) => Icon(
                      p.isVegan == true ? Icons.check_circle : Icons.cancel,
                      color: p.isVegan == true ? Colors.green : Colors.red,
                      size: 30,
                    ))
                .toList(),
          ),
          _buildComparisonSection(
            context,
            'Vegetarian',
            products
                .map((p) => Icon(
                      p.isVegetarian == true
                          ? Icons.check_circle
                          : Icons.cancel,
                      color: p.isVegetarian == true ? Colors.green : Colors.red,
                      size: 30,
                    ))
                .toList(),
          ),
          _buildComparisonSection(
            context,
            'Palm Oil Free',
            products
                .map((p) => Icon(
                      p.palmOilFree == true ? Icons.check_circle : Icons.cancel,
                      color: p.palmOilFree == true ? Colors.green : Colors.red,
                      size: 30,
                    ))
                .toList(),
          ),

          32.verticalSpace,
        ],
      ),
    );
  }

  Widget _buildNutritionComparisonRow(
    BuildContext context,
    String label,
    List<String> values,
  ) {
    // Find the best and worst values
    final numericValues = values
        .map((v) => double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')))
        .toList();
    final validValues =
        numericValues.where((v) => v != null).cast<double>().toList();

    double? minValue;
    double? maxValue;
    if (validValues.isNotEmpty) {
      minValue = validValues.reduce((a, b) => a < b ? a : b);
      maxValue = validValues.reduce((a, b) => a > b ? a : b);
    }

    return Container(
      padding: EdgeInsets.symmetric(vertical: 12.h, horizontal: 16.w),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ...List.generate(values.length, (index) {
            final value = values[index];
            final numericValue = numericValues[index];
            final isBest = numericValue != null &&
                minValue != null &&
                numericValue == minValue &&
                label.toLowerCase().contains('energy') == false;
            final isWorst = numericValue != null &&
                maxValue != null &&
                numericValue == maxValue &&
                validValues.length > 1;

            return Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                  decoration: BoxDecoration(
                    color: isBest
                        ? Colors.green.withValues(alpha: 0.2)
                        : isWorst
                            ? Colors.red.withValues(alpha: 0.2)
                            : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isBest || isWorst ? FontWeight.bold : null,
                          color: isBest
                              ? Colors.green[700]
                              : isWorst
                                  ? Colors.red[700]
                                  : null,
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }

  Widget _buildProductHeader(
    BuildContext context,
    FoodProductModel product,
    WidgetRef ref,
  ) {
    return Card(
      margin: EdgeInsets.all(4.w),
      child: Stack(
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ProductImageWidget(
                imageUrl: product.imageFrontUrl ?? product.imageUrl,
                width: 80,
                height: 80,
              ),
              8.verticalSpace,
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8.w),
                child: Text(
                  product.productName ?? 'Unknown',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (product.brands != null) ...[
                4.verticalSpace,
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.w),
                  child: Text(
                    product.brands!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withValues(alpha: 0.6),
                        ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ],
          ),
          Positioned(
            top: 4,
            right: 4,
            child: IconButton(
              icon: const Icon(Icons.close, size: 20),
              onPressed: () {
                ref
                    .read(comparisonProvider.notifier)
                    .removeProduct(product.barcode);
              },
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSingleProductView(
    BuildContext context,
    FoodProductModel product,
    WidgetRef ref,
  ) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ProductImageWidget(
            imageUrl: product.imageFrontUrl ?? product.imageUrl,
            width: 150,
            height: 150,
          ),
          16.verticalSpace,
          Text(
            product.productName ?? 'Unknown Product',
            style: Theme.of(context).textTheme.headlineSmall,
            textAlign: TextAlign.center,
          ),
          8.verticalSpace,
          Text(
            'Add more products to compare',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context)
                      .colorScheme
                      .onSurface
                      .withValues(alpha: 0.6),
                ),
          ),
          24.verticalSpace,
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

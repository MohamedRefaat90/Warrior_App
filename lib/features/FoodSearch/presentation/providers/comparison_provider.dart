import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for product comparison
final comparisonProvider =
    NotifierProvider.autoDispose<ComparisonNotifier, List<FoodProductModel>>(
        ComparisonNotifier.new);

class ComparisonNotifier extends Notifier<List<FoodProductModel>> {
  @override
  List<FoodProductModel> build() {
    ref.keepAlive();
    return [];
  }

  void addProduct(FoodProductModel product) {
    if (state.length >= 3) {
      TalkerService.warning(
          'Cannot add more than 3 products for comparison', 'COMPARISON');
      return;
    }
    if (state.any((p) => p.barcode == product.barcode)) {
      TalkerService.info('Product already in comparison list', 'COMPARISON');
      return;
    }
    state = [...state, product];
    TalkerService.info(
        'Added product ${product.productName} to comparison', 'COMPARISON');
  }

  void removeProduct(String barcode) {
    state = state.where((p) => p.barcode != barcode).toList();
    TalkerService.info(
        'Removed product with barcode $barcode from comparison', 'COMPARISON');
  }

  void clearComparison() {
    state = [];
    TalkerService.info('Cleared comparison list', 'COMPARISON');
  }
}

/// Provider to check if a product is in comparison
final isInComparisonProvider =
    Provider.family.autoDispose<bool, String>((ref, barcode) {
  final comparison = ref.watch(comparisonProvider);
  return comparison.any((p) => p.barcode == barcode);
});


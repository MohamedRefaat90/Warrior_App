import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for product comparison
final comparisonProvider =
    NotifierProvider<ComparisonNotifier, List<ProductEntity>>(
        ComparisonNotifier.new);

/// Provider to check if a product is in comparison
final isInComparisonProvider = Provider.family<bool, String>((ref, barcode) {
  final comparison = ref.watch(comparisonProvider);
  return comparison.any((p) => p.barcode == barcode);
});

class ComparisonNotifier extends Notifier<List<ProductEntity>> {
  void addProduct(ProductEntity product) {
    if (state.length >= 3) {
      HapticFeedback.heavyImpact();
      TalkerService.warning(
          'Cannot add more than 3 products for comparison', 'COMPARISON');
      return;
    }
    if (state.any((p) => p.barcode == product.barcode)) {
      HapticFeedback.selectionClick();
      TalkerService.info('Product already in comparison list', 'COMPARISON');
      return;
    }
    state = [...state, product];
    HapticFeedback.mediumImpact();
    TalkerService.info(
        'Added product ${product.productName} to comparison', 'COMPARISON');
  }

  @override
  List<ProductEntity> build() {
    return [];
  }

  void clearComparison() {
    state = [];
    HapticFeedback.lightImpact();
    TalkerService.info('Cleared comparison list', 'COMPARISON');
  }

  void removeProduct(String barcode) {
    state = state.where((p) => p.barcode != barcode).toList();
    HapticFeedback.lightImpact();
    TalkerService.info(
        'Removed product with barcode $barcode from comparison', 'COMPARISON');
  }
}

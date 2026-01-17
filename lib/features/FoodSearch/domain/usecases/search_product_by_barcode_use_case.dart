import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for searching a product by its barcode.
///
/// Implements the search logic with cache fallback strategy.
class SearchProductByBarcodeUseCase {
  final ProductReadRepository _repository;

  SearchProductByBarcodeUseCase(this._repository);

  /// Searches for a product by barcode.
  ///
  /// Strategy:
  /// 1. Check offline cache first
  /// 2. If not found or stale, fetch from remote
  /// 3. Return null if product doesn't exist
  Future<ProductEntity?> call(String barcode) async {
    try {
      // 1. Check offline cache
      final cachedProduct = _repository.getProductFromCache(barcode);
      if (cachedProduct != null) {
        TalkerService.info('Using cached product: $barcode', 'USECASE');
        return cachedProduct;
      }

      // 2. Fetch from remote (repository handles caching)
      final product = await _repository.searchProductByBarcode(barcode);
      return product;
    } catch (e, stack) {
      TalkerService.error('Error searching by barcode', 'USECASE', e, stack);
      rethrow;
    }
  }
}

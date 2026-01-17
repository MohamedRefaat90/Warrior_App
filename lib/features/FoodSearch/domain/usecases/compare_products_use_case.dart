import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for comparing multiple products by their barcodes.
///
/// Fetches products and returns them for comparison purposes.
class CompareProductsUseCase {
  final ProductReadRepository _repository;

  CompareProductsUseCase(this._repository);

  /// Compares multiple products by fetching them using their barcodes.
  ///
  /// Returns a list of successfully fetched products.
  /// Products that cannot be found are excluded from the result.
  Future<List<ProductEntity>> call(List<String> barcodes) async {
    return await _repository.compareProducts(barcodes);
  }
}

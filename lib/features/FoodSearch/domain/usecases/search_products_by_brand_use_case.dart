import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for searching products by brand.
class SearchProductsByBrandUseCase {
  final ProductReadRepository _repository;

  SearchProductsByBrandUseCase(this._repository);

  /// Searches for products by brand with pagination support.
  ///
  /// The repository handles:
  /// - Remote API calls
  /// - Caching results
  /// - Offline fallback to cached data
  Future<List<ProductEntity>> call(
    String brand, {
    int page = 1,
    int pageSize = 25,
  }) async {
    return await _repository.searchByBrand(
      brand,
      page: page,
      pageSize: pageSize,
    );
  }
}

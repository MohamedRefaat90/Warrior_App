import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for searching products by name.
class SearchProductsByNameUseCase {
  final ProductReadRepository _repository;

  SearchProductsByNameUseCase(this._repository);

  /// Searches for products by name with pagination support.
  ///
  /// The repository handles:
  /// - Remote API calls
  /// - Caching results
  /// - Adding to search history
  /// - Offline fallback
  Future<List<ProductEntity>> call(
    String query, {
    int page = 1,
    int pageSize = 25,
  }) async {
    return await _repository.searchProductsByName(
      query,
      page: page,
      pageSize: pageSize,
    );
  }
}

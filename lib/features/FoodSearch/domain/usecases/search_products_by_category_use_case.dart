import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for searching products by category.
class SearchProductsByCategoryUseCase {
  final ProductReadRepository _repository;

  SearchProductsByCategoryUseCase(this._repository);

  /// Searches for products by category with pagination support.
  ///
  /// The repository handles:
  /// - Remote API calls
  /// - Caching results
  /// - Offline fallback to cached data
  Future<List<ProductEntity>> call(
    String category, {
    int page = 1,
    int pageSize = 25,
  }) async {
    return await _repository.searchByCategory(
      category,
      page: page,
      pageSize: pageSize,
    );
  }
}

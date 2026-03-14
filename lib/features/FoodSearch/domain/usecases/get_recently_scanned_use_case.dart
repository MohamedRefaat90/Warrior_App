import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for retrieving recently searched products.
class GetRecentlySearchedUseCase {
  final ProductReadRepository _repository;

  GetRecentlySearchedUseCase(this._repository);

  /// Gets recently searched products with optional limit.
  ///
  /// Returns the most recently searched products first.
  /// Default limit is 10 items.
  List<ProductEntity> call({int limit = 10}) {
    return _repository.getRecentlyScanned(limit: limit);
  }
}

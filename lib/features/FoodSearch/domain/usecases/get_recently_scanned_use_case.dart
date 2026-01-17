import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for retrieving recently scanned products.
class GetRecentlyScannedUseCase {
  final ProductReadRepository _repository;

  GetRecentlyScannedUseCase(this._repository);

  /// Gets recently scanned products with optional limit.
  ///
  /// Returns the most recently scanned products first.
  /// Default limit is 10 items.
  List<ProductEntity> call({int limit = 10}) {
    return _repository.getRecentlyScanned(limit: limit);
  }
}

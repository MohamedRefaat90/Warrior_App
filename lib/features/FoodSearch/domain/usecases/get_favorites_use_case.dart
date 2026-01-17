import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';

/// Use Case for retrieving favorite products.
class GetFavoritesUseCase {
  final UserInteractionRepository _repository;

  GetFavoritesUseCase(this._repository);

  /// Gets all products marked as favorites.
  ///
  /// Returns an empty list if no favorites exist.
  List<ProductEntity> call() {
    return _repository.getFavorites();
  }
}

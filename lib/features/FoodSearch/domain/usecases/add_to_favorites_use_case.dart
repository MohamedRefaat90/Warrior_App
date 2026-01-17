import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';

/// Use Case for adding a product to favorites.
class AddToFavoritesUseCase {
  final UserInteractionRepository _repository;

  AddToFavoritesUseCase(this._repository);

  /// Adds a product to the favorites list.
  Future<void> call(ProductEntity product) async {
    return await _repository.addToFavorites(product);
  }
}

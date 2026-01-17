import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';

/// Use Case for toggling a product's favorite status.
///
/// Contains the business logic for determining whether to add or remove
/// a product from favorites based on its current state.
class ToggleFavoriteUseCase {
  final UserInteractionRepository _repository;

  ToggleFavoriteUseCase(this._repository);

  /// Toggles the favorite status of a product.
  ///
  /// If the product is currently a favorite, it will be removed.
  /// If the product is not a favorite, it will be added.
  Future<void> call(ProductEntity product) async {
    final isFavorite = _repository.isFavorite(product.barcode);

    if (isFavorite) {
      await _repository.removeFromFavorites(product.barcode);
    } else {
      await _repository.addToFavorites(product);
    }
  }

  /// Checks if a product is currently marked as favorite.
  bool isFavorite(String barcode) {
    return _repository.isFavorite(barcode);
  }
}

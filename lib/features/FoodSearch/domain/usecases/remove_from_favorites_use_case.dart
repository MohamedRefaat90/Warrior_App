import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';

/// Use Case for removing a product from favorites.
class RemoveFromFavoritesUseCase {
  final UserInteractionRepository _repository;

  RemoveFromFavoritesUseCase(this._repository);

  /// Removes a product from favorites by its barcode.
  Future<void> call(String barcode) async {
    return await _repository.removeFromFavorites(barcode);
  }
}

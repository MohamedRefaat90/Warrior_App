import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Use Case for submitting a product (create or update).
///
/// Handles the business logic for product submission including
/// offline queueing when network is unavailable.
class SubmitProductUseCase {
  final ProductWriteRepository _repository;

  SubmitProductUseCase(this._repository);

  /// Submits a product to Open Food Facts.
  ///
  /// The repository handles:
  /// - Network availability checks
  /// - Offline queueing
  /// - Image upload if provided
  /// - Create vs Update logic
  ///
  /// Returns true if submission was successful or queued for later.
  Future<bool> call({
    required ProductEntity product,
    required User user,
    String? imagePath,
    bool isUpdate = false,
  }) async {
    return await _repository.submitProduct(
      product: product,
      user: user,
      imagePath: imagePath,
      isUpdate: isUpdate,
    );
  }
}

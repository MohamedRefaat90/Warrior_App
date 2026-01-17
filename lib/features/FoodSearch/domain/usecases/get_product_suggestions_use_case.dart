import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for getting product name suggestions for autocomplete.
class GetProductSuggestionsUseCase {
  final ProductReadRepository _repository;

  GetProductSuggestionsUseCase(this._repository);

  /// Gets product name suggestions based on a query string.
  ///
  /// Used for autocomplete functionality in search.
  /// Returns an empty list if offline or if no suggestions are found.
  Future<List<String>> call(String query) async {
    if (query.length < 2) {
      return [];
    }

    return await _repository.getProductSuggestions(query);
  }
}

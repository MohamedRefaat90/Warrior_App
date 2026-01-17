import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';

/// Use Case for filtering cached products based on various criteria.
///
/// This contains pure domain logic for filtering products without
/// depending on data layer implementation details.
class FilterProductsUseCase {
  final ProductReadRepository _repository;

  FilterProductsUseCase(this._repository);

  /// Filters products based on the provided criteria.
  ///
  /// All filtering logic is performed in the domain layer.
  /// The repository only provides the raw cached products.
  List<ProductEntity> call({
    String? nutriScore,
    bool? vegan,
    bool? vegetarian,
    bool? palmOilFree,
    List<String>? allergens,
    int? novaGroup,
  }) {
    // Get all cached products from repository (data access only)
    var products = _getAllCachedProducts();

    // Apply filters (domain logic)
    if (nutriScore != null) {
      products = _filterByNutriScore(products, nutriScore);
    }

    if (vegan == true) {
      products = _filterByVegan(products);
    }

    if (vegetarian == true) {
      products = _filterByVegetarian(products);
    }

    if (palmOilFree == true) {
      products = _filterByPalmOilFree(products);
    }

    if (novaGroup != null) {
      products = _filterByNovaGroup(products, novaGroup);
    }

    if (allergens != null && allergens.isNotEmpty) {
      products = _filterByAllergens(products, allergens);
    }

    return products;
  }

  /// Filters products to exclude those containing specified allergens.
  ///
  /// Products with null allergens are included (assumed safe).
  /// Uses case-insensitive matching.
  List<ProductEntity> _filterByAllergens(
    List<ProductEntity> products,
    List<String> allergens,
  ) {
    return products.where((p) {
      if (p.allergens == null) return true;
      return !p.allergens!.any((allergen) => allergens
          .any((a) => allergen.toLowerCase().contains(a.toLowerCase())));
    }).toList();
  }

  /// Filters products by NOVA group classification.
  List<ProductEntity> _filterByNovaGroup(
    List<ProductEntity> products,
    int novaGroup,
  ) {
    return products.where((p) => p.novaGroup == novaGroup).toList();
  }

  /// Filters products by Nutri-Score (case-insensitive).
  List<ProductEntity> _filterByNutriScore(
    List<ProductEntity> products,
    String nutriScore,
  ) {
    return products
        .where((p) => p.nutriScore?.toUpperCase() == nutriScore.toUpperCase())
        .toList();
  }

  /// Filters products to only include palm oil-free products.
  List<ProductEntity> _filterByPalmOilFree(List<ProductEntity> products) {
    return products.where((p) => p.palmOilFree == true).toList();
  }

  /// Filters products to only include vegan products.
  List<ProductEntity> _filterByVegan(List<ProductEntity> products) {
    return products.where((p) => p.isVegan == true).toList();
  }

  /// Filters products to only include vegetarian products.
  List<ProductEntity> _filterByVegetarian(List<ProductEntity> products) {
    return products.where((p) => p.isVegetarian == true).toList();
  }

  /// Gets all cached products from the repository.
  /// This is the only method that interacts with the repository.
  List<ProductEntity> _getAllCachedProducts() {
    return _repository.getAllCachedProducts();
  }
}

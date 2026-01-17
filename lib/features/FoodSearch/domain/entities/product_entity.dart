import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';

/// Domain entity representing a food product.
/// This is a pure domain class independent of any data source or storage mechanism.
class ProductEntity {
  final String barcode;
  final String? productName;
  final String? brands;
  final String? quantity;
  final String? imageUrl;
  // final String? imageFrontUrl;
  // final String? imageIngredientsUrl;
  // final String? imageNutritionUrl;
  final String? nutriScore;
  final int? novaGroup;
  final String? ecoscore;
  final NutritionFacts? nutrition;
  final String? ingredients;
  final List<String>? allergens;
  final List<String>? additives;
  final List<String>? categories;
  final List<String>? labels;
  final bool? isVegan;
  final bool? isVegetarian;
  final bool? palmOilFree;
  final DateTime lastUpdated;
  final String? servingSize;
  // final String? packagingText;
  final String? countries;

  const ProductEntity({
    required this.barcode,
    this.productName,
    this.brands,
    this.quantity,
    this.imageUrl,
    // this.imageFrontUrl,
    // this.imageIngredientsUrl,
    // this.imageNutritionUrl,
    this.nutriScore,
    this.novaGroup,
    this.ecoscore,
    this.nutrition,
    this.ingredients,
    this.allergens,
    this.additives,
    this.categories,
    this.labels,
    this.isVegan,
    this.isVegetarian,
    this.palmOilFree,
    required this.lastUpdated,
    this.servingSize,
    // this.packagingText,
    this.countries,
  });

  /// Returns a display name for the product
  String get displayName => productName ?? 'Unknown Product';

  /// Returns true if the product has basic required information
  bool get hasBasicInfo =>
      barcode.isNotEmpty && productName != null && productName!.isNotEmpty;

  @override
  int get hashCode => barcode.hashCode;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ProductEntity && other.barcode == barcode;
  }

  ProductEntity copyWith({
    String? barcode,
    String? productName,
    String? brands,
    String? quantity,
    String? imageUrl,
    // String? imageFrontUrl,
    // String? imageIngredientsUrl,
    // String? imageNutritionUrl,
    String? nutriScore,
    int? novaGroup,
    String? ecoscore,
    NutritionFacts? nutrition,
    String? ingredients,
    List<String>? allergens,
    List<String>? additives,
    List<String>? categories,
    List<String>? labels,
    bool? isVegan,
    bool? isVegetarian,
    bool? palmOilFree,
    DateTime? lastUpdated,
    String? servingSize,
    String? packagingText,
    String? countries,
  }) {
    return ProductEntity(
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brands: brands ?? this.brands,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      nutriScore: nutriScore ?? this.nutriScore,
      novaGroup: novaGroup ?? this.novaGroup,
      ecoscore: ecoscore ?? this.ecoscore,
      nutrition: nutrition ?? this.nutrition,
      ingredients: ingredients ?? this.ingredients,
      allergens: allergens ?? this.allergens,
      additives: additives ?? this.additives,
      categories: categories ?? this.categories,
      labels: labels ?? this.labels,
      isVegan: isVegan ?? this.isVegan,
      isVegetarian: isVegetarian ?? this.isVegetarian,
      palmOilFree: palmOilFree ?? this.palmOilFree,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      servingSize: servingSize ?? this.servingSize,
      countries: countries ?? this.countries,
    );
  }
}

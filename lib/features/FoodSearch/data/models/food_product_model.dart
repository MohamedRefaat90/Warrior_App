import 'package:Warrior/features/FoodSearch/data/models/nutrition_values_model.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:hive/hive.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

part 'food_product_model.g.dart';

/// Model for food product from Open Food Facts
/// Cached locally for offline access
@HiveType(typeId: 10)
class FoodProductModel extends HiveObject {
  @HiveField(0)
  final String barcode;

  @HiveField(1)
  final String? productName;

  @HiveField(2)
  final String? brands;

  @HiveField(3)
  final String? quantity;

  @HiveField(4)
  final String? imageUrl;

  @HiveField(5)
  final String? imageFrontUrl;

  @HiveField(6)
  final String? imageIngredientsUrl;

  @HiveField(7)
  final String? imageNutritionUrl;

  @HiveField(8)
  final String? nutriScore;

  @HiveField(9)
  final int? novaGroup;

  @HiveField(10)
  final String? ecoscore;

  @HiveField(11)
  final NutritionValuesModel? nutritionValues;

  @HiveField(12)
  final String? ingredients;

  @HiveField(13)
  final List<String>? allergens;

  @HiveField(14)
  final List<String>? additives;

  @HiveField(15)
  final List<String>? categories;

  @HiveField(16)
  final List<String>? labels;

  @HiveField(17)
  final bool? isVegan;

  @HiveField(18)
  final bool? isVegetarian;

  @HiveField(19)
  final bool? palmOilFree;

  @HiveField(20)
  final DateTime lastUpdated;

  @HiveField(21)
  final String? servingSize;

  @HiveField(22)
  final String? packagingText;

  @HiveField(23)
  final String? countries;

  /// Local file path to cached/compressed image (if any).
  @HiveField(24)
  final String? cachedImagePath;

  /// Timestamp when this product was cached.
  @HiveField(25)
  final DateTime cachedAt;

  /// Source of the product data (OpenFoodFacts, user manual, OCR, etc).
  @HiveField(26)
  final String dataSource;

  FoodProductModel({
    required this.barcode,
    this.productName,
    this.brands,
    this.quantity,
    this.imageUrl,
    this.imageFrontUrl,
    this.imageIngredientsUrl,
    this.imageNutritionUrl,
    this.nutriScore,
    this.novaGroup,
    this.ecoscore,
    this.nutritionValues,
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
    this.packagingText,
    this.countries,
    this.cachedImagePath,
    DateTime? cachedAt,
    this.dataSource = 'openFoodFacts',
  }) : cachedAt = cachedAt ?? DateTime.now();

  /// Create from domain entity
  factory FoodProductModel.fromEntity(ProductEntity entity) {
    return FoodProductModel(
      barcode: entity.barcode,
      productName: entity.productName,
      brands: entity.brands,
      quantity: entity.quantity,
      imageUrl: entity.imageUrl,
      nutriScore: entity.nutriScore,
      novaGroup: entity.novaGroup,
      ecoscore: entity.ecoscore,
      nutritionValues: entity.nutrition != null
          ? NutritionValuesModel.fromEntity(entity.nutrition!)
          : null,
      ingredients: entity.ingredients,
      allergens: entity.allergens,
      additives: entity.additives,
      categories: entity.categories,
      labels: entity.labels,
      isVegan: entity.isVegan,
      isVegetarian: entity.isVegetarian,
      palmOilFree: entity.palmOilFree,
      lastUpdated: entity.lastUpdated,
      servingSize: entity.servingSize,
      countries: entity.countries,
      dataSource: 'userManual',
    );
  }

  factory FoodProductModel.fromMap(Map<String, dynamic> map) {
    return FoodProductModel(
      barcode: map['barcode'] as String,
      productName: map['product_name'] as String?,
      brands: map['brands'] as String?,
      quantity: map['quantity'] as String?,
      imageUrl: map['image_url'] as String?,
      imageFrontUrl: map['image_front_url'] as String?,
      imageIngredientsUrl: map['image_ingredients_url'] as String?,
      imageNutritionUrl: map['image_nutrition_url'] as String?,
      nutriScore: map['nutri_score'] as String?,
      novaGroup: map['nova_group'] as int?,
      ecoscore: map['ecoscore'] as String?,
      nutritionValues: map['nutrition_values'] != null
          ? NutritionValuesModel.fromMap(
              map['nutrition_values'] as Map<String, dynamic>)
          : null,
      ingredients: map['ingredients'] as String?,
      allergens: (map['allergens'] as List<dynamic>?)?.cast<String>(),
      additives: (map['additives'] as List<dynamic>?)?.cast<String>(),
      categories: (map['categories'] as List<dynamic>?)?.cast<String>(),
      labels: (map['labels'] as List<dynamic>?)?.cast<String>(),
      isVegan: map['is_vegan'] as bool?,
      isVegetarian: map['is_vegetarian'] as bool?,
      palmOilFree: map['palm_oil_free'] as bool?,
      lastUpdated: DateTime.parse(map['last_updated'] as String),
      servingSize: map['serving_size'] as String?,
      packagingText: map['packaging_text'] as String?,
      countries: map['countries'] as String?,
    );
  }

  /// Create from Open Food Facts Product
  factory FoodProductModel.fromOpenFoodFactsProduct(Product product) {
    return FoodProductModel(
      barcode: product.barcode ?? '',
      productName: product.productName,
      brands: product.brands,
      quantity: product.quantity,
      imageUrl: product.imageFrontUrl,
      imageFrontUrl: product.imageFrontUrl,
      imageIngredientsUrl: product.imageIngredientsUrl,
      imageNutritionUrl: product.imageNutritionUrl,
      nutriScore: product.nutriscore?.toUpperCase(),
      novaGroup: product.novaGroup,
      ecoscore: product.ecoscoreGrade?.toUpperCase(),
      nutritionValues: product.nutriments != null
          ? NutritionValuesModel(
              energyKcal: product.nutriments!
                  .getValue(Nutrient.energyKCal, PerSize.oneHundredGrams),
              energyKj: product.nutriments!
                  .getValue(Nutrient.energyKJ, PerSize.oneHundredGrams),
              proteins: product.nutriments!
                  .getValue(Nutrient.proteins, PerSize.oneHundredGrams),
              carbohydrates: product.nutriments!
                  .getValue(Nutrient.carbohydrates, PerSize.oneHundredGrams),
              sugars: product.nutriments!
                  .getValue(Nutrient.sugars, PerSize.oneHundredGrams),
              fat: product.nutriments!
                  .getValue(Nutrient.fat, PerSize.oneHundredGrams),
              saturatedFat: product.nutriments!
                  .getValue(Nutrient.saturatedFat, PerSize.oneHundredGrams),
              fiber: product.nutriments!
                  .getValue(Nutrient.fiber, PerSize.oneHundredGrams),
              sodium: product.nutriments!
                  .getValue(Nutrient.sodium, PerSize.oneHundredGrams),
              salt: product.nutriments!
                  .getValue(Nutrient.salt, PerSize.oneHundredGrams),
              servingSize: product.servingSize != null
                  ? double.tryParse(product.servingSize!)
                  : null,
            )
          : null,
      ingredients: product.ingredientsText,
      allergens: product.allergens?.names.map((e) => e.toString()).toList(),
      additives: product.additives?.names.map((e) => e.toString()).toList(),
      categories: product.categoriesTags?.map((e) => e.toString()).toList(),
      labels: product.labelsTags?.map((e) => e.toString()).toList(),
      isVegan:
          product.ingredientsAnalysisTags?.veganStatus == VeganStatus.VEGAN,
      isVegetarian: product.ingredientsAnalysisTags?.vegetarianStatus ==
          VegetarianStatus.VEGETARIAN,
      palmOilFree: product.ingredientsAnalysisTags?.palmOilFreeStatus ==
          PalmOilFreeStatus.PALM_OIL_FREE,
      lastUpdated: DateTime.now(),
      servingSize: product.servingSize,
      packagingText: product.packagingTextInLanguages != null &&
              product.packagingTextInLanguages!.isNotEmpty
          ? product.packagingTextInLanguages!.values.first
          : null,
      countries: product.countries,
    );
  }

  /// Check if cache is still fresh (less than 7 days old)
  bool get isCacheFresh {
    return DateTime.now().difference(lastUpdated).inDays < 7;
  }

  FoodProductModel copyWith({
    String? barcode,
    String? productName,
    String? brands,
    String? quantity,
    String? imageUrl,
    String? imageFrontUrl,
    String? imageIngredientsUrl,
    String? imageNutritionUrl,
    String? nutriScore,
    int? novaGroup,
    String? ecoscore,
    NutritionValuesModel? nutritionValues,
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
    return FoodProductModel(
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brands: brands ?? this.brands,
      quantity: quantity ?? this.quantity,
      imageUrl: imageUrl ?? this.imageUrl,
      imageFrontUrl: imageFrontUrl ?? this.imageFrontUrl,
      imageIngredientsUrl: imageIngredientsUrl ?? this.imageIngredientsUrl,
      imageNutritionUrl: imageNutritionUrl ?? this.imageNutritionUrl,
      nutriScore: nutriScore ?? this.nutriScore,
      novaGroup: novaGroup ?? this.novaGroup,
      ecoscore: ecoscore ?? this.ecoscore,
      nutritionValues: nutritionValues ?? this.nutritionValues,
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
      packagingText: packagingText ?? this.packagingText,
      countries: countries ?? this.countries,
    );
  }

  /// Convert to domain entity
  ProductEntity toEntity() {
    return ProductEntity(
      barcode: barcode,
      productName: productName,
      brands: brands,
      quantity: quantity,
      imageUrl: imageUrl,
      nutriScore: nutriScore,
      novaGroup: novaGroup,
      ecoscore: ecoscore,
      nutrition: nutritionValues?.toEntity(),
      ingredients: ingredients,
      allergens: allergens,
      additives: additives,
      categories: categories,
      labels: labels,
      isVegan: isVegan,
      isVegetarian: isVegetarian,
      palmOilFree: palmOilFree,
      lastUpdated: lastUpdated,
      servingSize: servingSize,
      countries: countries,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'barcode': barcode,
      'product_name': productName,
      'brands': brands,
      'quantity': quantity,
      'image_url': imageUrl,
      'image_front_url': imageFrontUrl,
      'image_ingredients_url': imageIngredientsUrl,
      'image_nutrition_url': imageNutritionUrl,
      'nutri_score': nutriScore,
      'nova_group': novaGroup,
      'ecoscore': ecoscore,
      'nutrition_values': nutritionValues?.toMap(),
      'ingredients': ingredients,
      'allergens': allergens,
      'additives': additives,
      'categories': categories,
      'labels': labels,
      'is_vegan': isVegan,
      'is_vegetarian': isVegetarian,
      'palm_oil_free': palmOilFree,
      'last_updated': lastUpdated.toIso8601String(),
      'serving_size': servingSize,
      'packaging_text': packagingText,
      'countries': countries,
    };
  }

  /// Convert to Open Food Facts Product for editing/uploading
  Product toOpenFoodFactsProduct() {
    return Product(
      barcode: barcode,
      productName: productName,
      brands: brands,
      quantity: quantity,
      imageFrontUrl: imageFrontUrl,
      imageIngredientsUrl: imageIngredientsUrl,
      imageNutritionUrl: imageNutritionUrl,
      ingredientsText: ingredients,
      servingSize: servingSize,
      countries: countries,
    );
  }
}

import 'package:hive/hive.dart';

part 'nutrition_values_model.g.dart';

/// Model for nutritional values of a food product
/// Contains nutritional information per 100g and per serving
@HiveType(typeId: 15)
class NutritionValuesModel extends HiveObject {
  @HiveField(0)
  final double? energyKcal;

  @HiveField(1)
  final double? energyKj;

  @HiveField(2)
  final double? proteins;

  @HiveField(3)
  final double? carbohydrates;

  @HiveField(4)
  final double? sugars;

  @HiveField(5)
  final double? fat;

  @HiveField(6)
  final double? saturatedFat;

  @HiveField(7)
  final double? fiber;

  @HiveField(8)
  final double? sodium;

  @HiveField(9)
  final double? salt;

  @HiveField(10)
  final double? servingSize;

  NutritionValuesModel({
    this.energyKcal,
    this.energyKj,
    this.proteins,
    this.carbohydrates,
    this.sugars,
    this.fat,
    this.saturatedFat,
    this.fiber,
    this.sodium,
    this.salt,
    this.servingSize,
  });

  factory NutritionValuesModel.fromMap(Map<String, dynamic> map) {
    return NutritionValuesModel(
      energyKcal: map['energy_kcal'] as double?,
      energyKj: map['energy_kj'] as double?,
      proteins: map['proteins'] as double?,
      carbohydrates: map['carbohydrates'] as double?,
      sugars: map['sugars'] as double?,
      fat: map['fat'] as double?,
      saturatedFat: map['saturated_fat'] as double?,
      fiber: map['fiber'] as double?,
      sodium: map['sodium'] as double?,
      salt: map['salt'] as double?,
      servingSize: map['serving_size'] as double?,
    );
  }

  NutritionValuesModel copyWith({
    double? energyKcal,
    double? energyKj,
    double? proteins,
    double? carbohydrates,
    double? sugars,
    double? fat,
    double? saturatedFat,
    double? fiber,
    double? sodium,
    double? salt,
    double? servingSize,
  }) {
    return NutritionValuesModel(
      energyKcal: energyKcal ?? this.energyKcal,
      energyKj: energyKj ?? this.energyKj,
      proteins: proteins ?? this.proteins,
      carbohydrates: carbohydrates ?? this.carbohydrates,
      sugars: sugars ?? this.sugars,
      fat: fat ?? this.fat,
      saturatedFat: saturatedFat ?? this.saturatedFat,
      fiber: fiber ?? this.fiber,
      sodium: sodium ?? this.sodium,
      salt: salt ?? this.salt,
      servingSize: servingSize ?? this.servingSize,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'energy_kcal': energyKcal,
      'energy_kj': energyKj,
      'proteins': proteins,
      'carbohydrates': carbohydrates,
      'sugars': sugars,
      'fat': fat,
      'saturated_fat': saturatedFat,
      'fiber': fiber,
      'sodium': sodium,
      'salt': salt,
      'serving_size': servingSize,
    };
  }
}

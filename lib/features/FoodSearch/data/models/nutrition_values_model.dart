import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:hive_ce/hive.dart';

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

  /// OCR confidence scores for each field (0.0 to 1.0).
  @HiveField(11)
  final Map<String, double>? confidenceScores;

  /// Whether this data requires manual review due to low confidence.
  @HiveField(12)
  final bool? requiresManualReview;

  /// Timestamp when OCR scan was performed.
  @HiveField(13)
  final DateTime? ocrScannedAt;

  /// Raw OCR text for debugging purposes.
  @HiveField(14)
  final String? rawOcrText;

  /// Data mode: "100g" for per-100g values, "serving" for per-serving values.
  @HiveField(15)
  final String? dataMode;

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
    this.confidenceScores,
    this.requiresManualReview,
    this.ocrScannedAt,
    this.rawOcrText,
    this.dataMode,
  });

  /// Creates a NutritionValuesModel from a NutritionFacts domain entity.
  factory NutritionValuesModel.fromEntity(NutritionFacts facts) {
    return NutritionValuesModel(
      energyKcal: facts.energyKcal100g,
      energyKj: facts.energyKj100g,
      proteins: facts.proteins100g,
      carbohydrates: facts.carbohydrates100g,
      sugars: facts.sugars100g,
      fat: facts.fat100g,
      saturatedFat: facts.saturatedFat100g,
      fiber: facts.fiber100g,
      sodium: facts.sodium100g,
      salt: facts.salt100g,
      servingSize: facts.servingSizeGrams,
      confidenceScores: facts.confidenceScores.isNotEmpty
          ? Map<String, double>.from(facts.confidenceScores)
          : null,
      requiresManualReview: facts.requiresReview,
      ocrScannedAt: facts.scannedAt,
      rawOcrText: facts.rawOcrText,
      dataMode: facts.dataMode,
    );
  }

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
      confidenceScores: map['confidence_scores'] != null
          ? Map<String, double>.from(map['confidence_scores'] as Map)
          : null,
      requiresManualReview: map['requires_manual_review'] as bool?,
      ocrScannedAt: map['ocr_scanned_at'] != null
          ? DateTime.parse(map['ocr_scanned_at'] as String)
          : null,
      rawOcrText: map['raw_ocr_text'] as String?,
      dataMode: map['data_mode'] as String?,
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
    Map<String, double>? confidenceScores,
    bool? requiresManualReview,
    DateTime? ocrScannedAt,
    String? rawOcrText,
    String? dataMode,
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
      confidenceScores: confidenceScores ?? this.confidenceScores,
      requiresManualReview: requiresManualReview ?? this.requiresManualReview,
      ocrScannedAt: ocrScannedAt ?? this.ocrScannedAt,
      rawOcrText: rawOcrText ?? this.rawOcrText,
      dataMode: dataMode ?? this.dataMode,
    );
  }

  /// Converts back to domain entity.
  NutritionFacts toEntity() {
    return NutritionFacts(
      energyKcal100g: energyKcal,
      energyKj100g: energyKj,
      fat100g: fat,
      saturatedFat100g: saturatedFat,
      carbohydrates100g: carbohydrates,
      sugars100g: sugars,
      fiber100g: fiber,
      proteins100g: proteins,
      sodium100g: sodium,
      salt100g: salt,
      servingSizeGrams: servingSize,
      dataMode: dataMode ?? '100g',
      confidenceScores: confidenceScores ?? const {},
      requiresReview: requiresManualReview ?? false,
      scannedAt: ocrScannedAt,
      rawOcrText: rawOcrText,
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
      'confidence_scores': confidenceScores,
      'requires_manual_review': requiresManualReview,
      'ocr_scanned_at': ocrScannedAt?.toIso8601String(),
      'raw_ocr_text': rawOcrText,
      'data_mode': dataMode,
    };
  }

  /// Converts to Open Food Facts API nutriments format.
  ///
  /// Returns a map with keys matching the OFF API specification.
  Map<String, dynamic> toOFFNutriments() {
    final map = <String, dynamic>{};

    if (energyKcal != null) map['energy-kcal_100g'] = energyKcal;
    if (energyKj != null) map['energy-kj_100g'] = energyKj;
    if (fat != null) map['fat_100g'] = fat;
    if (saturatedFat != null) map['saturated-fat_100g'] = saturatedFat;
    if (carbohydrates != null) map['carbohydrates_100g'] = carbohydrates;
    if (sugars != null) map['sugars_100g'] = sugars;
    if (fiber != null) map['fiber_100g'] = fiber;
    if (proteins != null) map['proteins_100g'] = proteins;
    if (sodium != null) map['sodium_100g'] = sodium;
    if (salt != null) map['salt_100g'] = salt;

    return map;
  }
}

/// Domain entity for nutrition facts with OCR metadata.
///
/// This entity represents nutrition information extracted from food labels,
/// supporting both manual entry and OCR-based extraction with confidence scores.
class NutritionFacts {
  /// Confidence threshold for considering a field as high confidence.
  static const double highConfidenceThreshold = 0.7;

  /// Energy in kilocalories per 100g.
  final double? energyKcal100g;

  /// Energy in kilojoules per 100g.
  final double? energyKj100g;

  /// Total fat in grams per 100g.
  final double? fat100g;

  /// Saturated fat in grams per 100g.
  final double? saturatedFat100g;

  /// Total carbohydrates in grams per 100g.
  final double? carbohydrates100g;

  /// Sugars in grams per 100g.
  final double? sugars100g;

  /// Dietary fiber in grams per 100g.
  final double? fiber100g;

  /// Proteins in grams per 100g.
  final double? proteins100g;

  /// Sodium in grams per 100g.
  final double? sodium100g;

  /// Salt in grams per 100g.
  final double? salt100g;

  /// Serving size description (e.g., "30g", "200ml", "1 cup").
  final String? servingSize;

  /// Serving size in grams for calculations.
  final double? servingSizeGrams;

  /// Data mode: "100g" for per-100g values, "serving" for per-serving values.
  final String dataMode;

  /// OCR confidence scores for each field (0.0 to 1.0).
  ///
  /// Keys match the field names (e.g., "energyKcal100g", "fat100g").
  final Map<String, double> confidenceScores;

  /// Whether this data requires manual review due to low confidence.
  final bool requiresReview;

  /// Timestamp when OCR scan was performed.
  final DateTime? scannedAt;

  /// Raw OCR text for debugging purposes.
  final String? rawOcrText;

  const NutritionFacts({
    this.energyKcal100g,
    this.energyKj100g,
    this.fat100g,
    this.saturatedFat100g,
    this.carbohydrates100g,
    this.sugars100g,
    this.fiber100g,
    this.proteins100g,
    this.sodium100g,
    this.salt100g,
    this.servingSize,
    this.servingSizeGrams,
    this.dataMode = '100g',
    this.confidenceScores = const {},
    this.requiresReview = false,
    this.scannedAt,
    this.rawOcrText,
  });

  /// Creates an empty NutritionFacts instance.
  const factory NutritionFacts.empty() = NutritionFacts;

  @override
  int get hashCode {
    return Object.hash(
      energyKcal100g,
      energyKj100g,
      fat100g,
      saturatedFat100g,
      carbohydrates100g,
      sugars100g,
      fiber100g,
      proteins100g,
      sodium100g,
      salt100g,
      servingSize,
      servingSizeGrams,
      dataMode,
      requiresReview,
    );
  }

  /// Returns the count of populated nutrition fields.
  int get populatedFieldCount => getPopulatedFields().length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! NutritionFacts) return false;

    return energyKcal100g == other.energyKcal100g &&
        energyKj100g == other.energyKj100g &&
        fat100g == other.fat100g &&
        saturatedFat100g == other.saturatedFat100g &&
        carbohydrates100g == other.carbohydrates100g &&
        sugars100g == other.sugars100g &&
        fiber100g == other.fiber100g &&
        proteins100g == other.proteins100g &&
        sodium100g == other.sodium100g &&
        salt100g == other.salt100g &&
        servingSize == other.servingSize &&
        servingSizeGrams == other.servingSizeGrams &&
        dataMode == other.dataMode &&
        requiresReview == other.requiresReview;
  }

  /// Converts per-serving values to per-100g values.
  ///
  /// Returns a new instance with converted values.
  /// If already in per-100g mode or serving size is unknown, returns this.
  NutritionFacts convertToPer100g() {
    if (dataMode == '100g') return this;
    if (servingSizeGrams == null || servingSizeGrams! <= 0) return this;

    final factor = 100.0 / servingSizeGrams!;

    return copyWith(
      energyKcal100g: _multiplyIfNotNull(energyKcal100g, factor),
      energyKj100g: _multiplyIfNotNull(energyKj100g, factor),
      fat100g: _multiplyIfNotNull(fat100g, factor),
      saturatedFat100g: _multiplyIfNotNull(saturatedFat100g, factor),
      carbohydrates100g: _multiplyIfNotNull(carbohydrates100g, factor),
      sugars100g: _multiplyIfNotNull(sugars100g, factor),
      fiber100g: _multiplyIfNotNull(fiber100g, factor),
      proteins100g: _multiplyIfNotNull(proteins100g, factor),
      sodium100g: _multiplyIfNotNull(sodium100g, factor),
      salt100g: _multiplyIfNotNull(salt100g, factor),
      dataMode: '100g',
    );
  }

  /// Converts per-100g values to per-serving values.
  ///
  /// Returns a new instance with converted values.
  /// If already in per-serving mode or serving size is unknown, returns this.
  NutritionFacts convertToPerServing() {
    if (dataMode == 'serving') return this;
    if (servingSizeGrams == null || servingSizeGrams! <= 0) return this;

    final factor = servingSizeGrams! / 100.0;

    return copyWith(
      energyKcal100g: _multiplyIfNotNull(energyKcal100g, factor),
      energyKj100g: _multiplyIfNotNull(energyKj100g, factor),
      fat100g: _multiplyIfNotNull(fat100g, factor),
      saturatedFat100g: _multiplyIfNotNull(saturatedFat100g, factor),
      carbohydrates100g: _multiplyIfNotNull(carbohydrates100g, factor),
      sugars100g: _multiplyIfNotNull(sugars100g, factor),
      fiber100g: _multiplyIfNotNull(fiber100g, factor),
      proteins100g: _multiplyIfNotNull(proteins100g, factor),
      sodium100g: _multiplyIfNotNull(sodium100g, factor),
      salt100g: _multiplyIfNotNull(salt100g, factor),
      dataMode: 'serving',
    );
  }

  /// Creates a copy with the given fields replaced.
  NutritionFacts copyWith({
    double? energyKcal100g,
    double? energyKj100g,
    double? fat100g,
    double? saturatedFat100g,
    double? carbohydrates100g,
    double? sugars100g,
    double? fiber100g,
    double? proteins100g,
    double? sodium100g,
    double? salt100g,
    String? servingSize,
    double? servingSizeGrams,
    String? dataMode,
    Map<String, double>? confidenceScores,
    bool? requiresReview,
    DateTime? scannedAt,
    String? rawOcrText,
  }) {
    return NutritionFacts(
      energyKcal100g: energyKcal100g ?? this.energyKcal100g,
      energyKj100g: energyKj100g ?? this.energyKj100g,
      fat100g: fat100g ?? this.fat100g,
      saturatedFat100g: saturatedFat100g ?? this.saturatedFat100g,
      carbohydrates100g: carbohydrates100g ?? this.carbohydrates100g,
      sugars100g: sugars100g ?? this.sugars100g,
      fiber100g: fiber100g ?? this.fiber100g,
      proteins100g: proteins100g ?? this.proteins100g,
      sodium100g: sodium100g ?? this.sodium100g,
      salt100g: salt100g ?? this.salt100g,
      servingSize: servingSize ?? this.servingSize,
      servingSizeGrams: servingSizeGrams ?? this.servingSizeGrams,
      dataMode: dataMode ?? this.dataMode,
      confidenceScores: confidenceScores ?? this.confidenceScores,
      requiresReview: requiresReview ?? this.requiresReview,
      scannedAt: scannedAt ?? this.scannedAt,
      rawOcrText: rawOcrText ?? this.rawOcrText,
    );
  }

  /// Returns the confidence level for a field.
  double getFieldConfidence(String field) {
    return confidenceScores[field] ?? 0.0;
  }

  /// Returns all fields with low confidence (< 0.7).
  List<String> getLowConfidenceFields() {
    return getPopulatedFields()
        .where((field) => !isFieldConfident(field))
        .toList();
  }

  /// Returns all fields that have values.
  List<String> getPopulatedFields() {
    final fields = <String>[];
    if (energyKcal100g != null) fields.add('energyKcal100g');
    if (energyKj100g != null) fields.add('energyKj100g');
    if (fat100g != null) fields.add('fat100g');
    if (saturatedFat100g != null) fields.add('saturatedFat100g');
    if (carbohydrates100g != null) fields.add('carbohydrates100g');
    if (sugars100g != null) fields.add('sugars100g');
    if (fiber100g != null) fields.add('fiber100g');
    if (proteins100g != null) fields.add('proteins100g');
    if (sodium100g != null) fields.add('sodium100g');
    if (salt100g != null) fields.add('salt100g');
    return fields;
  }

  /// Returns validation errors if any.
  List<String> getValidationErrors() {
    final errors = <String>[];

    // Check for negative values
    if (energyKcal100g != null && energyKcal100g! < 0) {
      errors.add('Energy (kcal) cannot be negative');
    }
    if (fat100g != null && fat100g! < 0) {
      errors.add('Fat cannot be negative');
    }
    if (carbohydrates100g != null && carbohydrates100g! < 0) {
      errors.add('Carbohydrates cannot be negative');
    }
    if (proteins100g != null && proteins100g! < 0) {
      errors.add('Proteins cannot be negative');
    }

    // Check for impossible values
    if (fat100g != null && fat100g! > 100) {
      errors.add('Fat cannot exceed 100g per 100g');
    }
    if (carbohydrates100g != null && carbohydrates100g! > 100) {
      errors.add('Carbohydrates cannot exceed 100g per 100g');
    }
    if (proteins100g != null && proteins100g! > 100) {
      errors.add('Proteins cannot exceed 100g per 100g');
    }

    // Check relationships
    if (saturatedFat100g != null &&
        fat100g != null &&
        saturatedFat100g! > fat100g!) {
      errors.add('Saturated fat cannot exceed total fat');
    }
    if (sugars100g != null &&
        carbohydrates100g != null &&
        sugars100g! > carbohydrates100g!) {
      errors.add('Sugars cannot exceed total carbohydrates');
    }

    return errors;
  }

  /// Checks if a specific field has high confidence (≥ 0.7).
  bool isFieldConfident(String field) {
    return (confidenceScores[field] ?? 0.0) >= highConfidenceThreshold;
  }

  /// Validates that nutrition values are sensible.
  ///
  /// Returns true if all values pass validation checks.
  bool isValid() {
    // Check for negative values
    final values = [
      energyKcal100g,
      energyKj100g,
      fat100g,
      saturatedFat100g,
      carbohydrates100g,
      sugars100g,
      fiber100g,
      proteins100g,
      sodium100g,
      salt100g,
    ];

    for (final value in values) {
      if (value != null && value < 0) return false;
    }

    // Check for impossible values (> 100g per 100g for macros)
    if (fat100g != null && fat100g! > 100) return false;
    if (saturatedFat100g != null && saturatedFat100g! > 100) return false;
    if (carbohydrates100g != null && carbohydrates100g! > 100) return false;
    if (sugars100g != null && sugars100g! > 100) return false;
    if (fiber100g != null && fiber100g! > 100) return false;
    if (proteins100g != null && proteins100g! > 100) return false;
    if (sodium100g != null && sodium100g! > 100) return false;
    if (salt100g != null && salt100g! > 100) return false;

    // Saturated fat should not exceed total fat
    if (saturatedFat100g != null &&
        fat100g != null &&
        saturatedFat100g! > fat100g!) {
      return false;
    }

    // Sugars should not exceed carbohydrates
    if (sugars100g != null &&
        carbohydrates100g != null &&
        sugars100g! > carbohydrates100g!) {
      return false;
    }

    return true;
  }

  @override
  String toString() {
    return 'NutritionFacts('
        'energyKcal100g: $energyKcal100g, '
        'fat100g: $fat100g, '
        'carbohydrates100g: $carbohydrates100g, '
        'proteins100g: $proteins100g, '
        'dataMode: $dataMode, '
        'requiresReview: $requiresReview)';
  }

  /// Helper to multiply a nullable value.
  double? _multiplyIfNotNull(double? value, double factor) {
    if (value == null) return null;
    return double.parse((value * factor).toStringAsFixed(2));
  }
}

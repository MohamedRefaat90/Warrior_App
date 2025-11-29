import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';

/// Pure Dart service for parsing nutrition facts from OCR text.
///
/// Supports Arabic and English nutrition labels with automatic detection
/// of serving size vs per-100g values and unit conversion.
class NutritionParsingService {
  /// Keyword mappings for different languages.
  ///
  /// Maps standard nutrient keys to possible label variations in
  /// English and Arabic.
  static const Map<String, List<String>> _keyMapping = {
    'energy': [
      // English
      'energy',
      'calories',
      'kcal',
      'cal',
      'energie',
      // Arabic
      'طاقة',
      'سعرات',
      'سعرة',
      'سعرات حرارية',
      'الطاقة',
    ],
    'energyKj': [
      'kj',
      'kilojoules',
      'كيلو جول',
    ],
    'fat': [
      // English
      'fat',
      'total fat',
      'fats',
      'lipids',
      'matières grasses',
      // Arabic
      'دهون',
      'الدهون',
      'دهون كلية',
      'إجمالي الدهون',
    ],
    'saturatedFat': [
      // English
      'saturated',
      'saturated fat',
      'saturates',
      'sat fat',
      'saturated fatty acids',
      // Arabic
      'مشبعة',
      'دهون مشبعة',
      'الدهون المشبعة',
      'أحماض دهنية مشبعة',
    ],
    'carbohydrates': [
      // English
      'carbohydrate',
      'carbohydrates',
      'carbs',
      'total carbohydrate',
      'glucides',
      // Arabic
      'كربوهيدرات',
      'الكربوهيدرات',
      'نشويات',
    ],
    'sugars': [
      // English
      'sugar',
      'sugars',
      'total sugars',
      'sucres',
      // Arabic
      'سكر',
      'سكريات',
      'السكريات',
      'سكر كلي',
    ],
    'fiber': [
      // English
      'fiber',
      'fibre',
      'dietary fiber',
      'fibres',
      // Arabic
      'ألياف',
      'الألياف',
      'ألياف غذائية',
    ],
    'proteins': [
      // English
      'protein',
      'proteins',
      'protéines',
      // Arabic
      'بروتين',
      'البروتين',
      'بروتينات',
    ],
    'sodium': [
      // English
      'sodium',
      'na',
      // Arabic
      'صوديوم',
      'الصوديوم',
    ],
    'salt': [
      // English
      'salt',
      'sel',
      // Arabic
      'ملح',
      'الملح',
    ],
  };

  /// Arabic to Western numeral conversion map.
  static const Map<String, String> _arabicNumerals = {
    '٠': '0',
    '١': '1',
    '٢': '2',
    '٣': '3',
    '٤': '4',
    '٥': '5',
    '٦': '6',
    '٧': '7',
    '٨': '8',
    '٩': '9',
    '٫': '.', // Arabic decimal separator
    '،': '.', // Arabic comma (sometimes used as decimal)
  };

  /// Unit patterns for value extraction.
  static final RegExp _valuePattern = RegExp(
    r'(\d+[.,]?\d*)\s*(g|mg|kg|kcal|kj|cal|جم|جرام|مجم|كيلو جول)?',
    caseSensitive: false,
  );

  /// Pattern for serving size detection in English.
  static final RegExp _servingSizePatternEn = RegExp(
    r'(?:serving\s*size|per\s*serving|portion)[:\s]*(\d+[.,]?\d*)\s*(g|ml|oz)?',
    caseSensitive: false,
  );

  /// Pattern for serving size detection in Arabic.
  static final RegExp _servingSizePatternAr = RegExp(
    r'(?:حجم\s*الحصة|لكل\s*حصة|الحصة)[:\s]*([\d٠-٩]+[.,٫،]?[\d٠-٩]*)\s*(جم|مل|جرام)?',
    caseSensitive: false,
  );

  /// Pattern to detect per-100g indication.
  static final RegExp _per100gPattern = RegExp(
    r'(?:per\s*100\s*g|pour\s*100\s*g|لكل\s*100\s*جم|لكل\s*١٠٠\s*جم|/100g)',
    caseSensitive: false,
  );

  /// Maps a label to a standard nutrient key.
  String? mapToStandardKey(String label) {
    final labelLower = label.toLowerCase().trim();

    for (final entry in _keyMapping.entries) {
      for (final keyword in entry.value) {
        if (labelLower.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// Main parsing method.
  ///
  /// Takes raw OCR text and extracts structured nutrition facts.
  NutritionFacts parseOcrText(String text) {
    // Normalize text (convert Arabic numerals, clean up)
    final normalizedText = _normalizeText(text);
    final lines = normalizedText.split('\n');

    // Extract results
    final results = <String, double>{};
    final confidence = <String, double>{};
    String? servingSize;
    double? servingSizeGrams;
    String dataMode = '100g';

    // Detect if this is per-serving or per-100g
    if (!_per100gPattern.hasMatch(normalizedText)) {
      // Try to find serving size
      final servingMatch = _extractServingSize(normalizedText);
      if (servingMatch != null) {
        servingSize = servingMatch.$1;
        servingSizeGrams = servingMatch.$2;
        dataMode = 'serving';
      }
    }

    // Process each line
    for (final line in lines) {
      _extractNutrientFromLine(
        line,
        results,
        confidence,
      );
    }

    // Determine if review is needed
    final hasLowConfidence = confidence.values
        .any((c) => c < NutritionFacts.highConfidenceThreshold);
    final requiresReview = hasLowConfidence || results.length < 3;

    return NutritionFacts(
      energyKcal100g: results['energy'],
      energyKj100g: results['energyKj'],
      fat100g: results['fat'],
      saturatedFat100g: results['saturatedFat'],
      carbohydrates100g: results['carbohydrates'],
      sugars100g: results['sugars'],
      fiber100g: results['fiber'],
      proteins100g: results['proteins'],
      sodium100g: results['sodium'],
      salt100g: results['salt'],
      servingSize: servingSize,
      servingSizeGrams: servingSizeGrams,
      dataMode: dataMode,
      confidenceScores: confidence,
      requiresReview: requiresReview,
      scannedAt: DateTime.now(),
      rawOcrText: text,
    );
  }

  /// Calculates confidence score for an extracted value.
  double _calculateConfidence({
    required bool hasUnit,
    required int distanceFromKeyword,
    required String line,
  }) {
    double confidence = 0.5; // Base confidence

    // Boost for having a unit
    if (hasUnit) {
      confidence += 0.25;
    }

    // Boost for value being close to keyword
    if (distanceFromKeyword < 5) {
      confidence += 0.15;
    } else if (distanceFromKeyword < 15) {
      confidence += 0.1;
    }

    // Boost for line containing separator (more structured)
    if (line.contains(':') || line.contains('\t')) {
      confidence += 0.1;
    }

    return confidence.clamp(0.0, 1.0);
  }

  /// Converts various units to grams.
  double _convertToGrams(double value, String unit) {
    final unitLower = unit.toLowerCase();
    if (unitLower == 'ml' || unitLower == 'مل') {
      return value; // Assume 1ml ≈ 1g for liquids
    }
    if (unitLower == 'oz') {
      return value * 28.35;
    }
    return value; // Assume grams
  }

  /// Converts a value to the standard unit for storage.
  ///
  /// - Energy: kcal (converts kJ to kcal)
  /// - Macros: grams (converts mg to g, kg to g)
  double _convertToStandardUnit(
      double value, String? unit, String nutrientKey) {
    if (unit == null) return value;

    final unitLower = unit.toLowerCase();

    // Handle energy conversions
    if (nutrientKey == 'energy' || nutrientKey == 'energyKj') {
      if (unitLower == 'kj' || unitLower == 'كيلو جول') {
        // Convert kJ to kcal (1 kcal = 4.184 kJ)
        return double.parse((value / 4.184).toStringAsFixed(1));
      }
      return value; // Already in kcal
    }

    // Handle mass conversions
    switch (unitLower) {
      case 'mg':
      case 'مجم':
        return value / 1000; // mg to g
      case 'kg':
        return value * 1000; // kg to g
      default:
        return value; // Already in grams
    }
  }

  /// Extracts a nutrient value from a single line.
  void _extractNutrientFromLine(
    String line,
    Map<String, double> results,
    Map<String, double> confidence,
  ) {
    final lineLower = line.toLowerCase();

    // Try to match each known nutrient
    for (final entry in _keyMapping.entries) {
      final nutrientKey = entry.key;
      final keywords = entry.value;

      // Skip if already found with higher confidence
      if (results.containsKey(nutrientKey) &&
          (confidence[nutrientKey] ?? 0) >= 0.8) {
        continue;
      }

      // Check if any keyword matches
      for (final keyword in keywords) {
        if (lineLower.contains(keyword.toLowerCase())) {
          // Found a match, try to extract value
          final extractedValue = _extractValue(line, keyword);
          if (extractedValue != null) {
            final (value, unit, conf) = extractedValue;

            // Convert to standard unit
            final standardValue = _convertToStandardUnit(
              value,
              unit,
              nutrientKey,
            );

            // Only update if confidence is higher
            if (!results.containsKey(nutrientKey) ||
                conf > (confidence[nutrientKey] ?? 0)) {
              results[nutrientKey] = standardValue;
              confidence[nutrientKey] = conf;
            }
          }
          break; // Found a keyword match, stop looking for this nutrient
        }
      }
    }
  }

  /// Extracts serving size from text.
  ///
  /// Returns a tuple of (display string, grams value) or null if not found.
  (String, double)? _extractServingSize(String text) {
    // Try English pattern first
    var match = _servingSizePatternEn.firstMatch(text);
    if (match != null) {
      final value = double.tryParse(match.group(1)?.replaceAll(',', '.') ?? '');
      if (value != null) {
        final unit = match.group(2) ?? 'g';
        final grams = _convertToGrams(value, unit);
        return ('$value$unit', grams);
      }
    }

    // Try Arabic pattern
    match = _servingSizePatternAr.firstMatch(text);
    if (match != null) {
      final value = double.tryParse(match.group(1)?.replaceAll(',', '.') ?? '');
      if (value != null) {
        final unit = match.group(2) ?? 'جم';
        final grams = _convertToGrams(value, unit);
        return ('$value$unit', grams);
      }
    }

    return null;
  }

  /// Extracts a numeric value from text near a keyword.
  ///
  /// Returns (value, unit, confidence) or null if not found.
  (double, String?, double)? _extractValue(String line, String keyword) {
    // Find the keyword position
    final keywordIndex = line.toLowerCase().indexOf(keyword.toLowerCase());
    if (keywordIndex == -1) return null;

    // Look for value after the keyword
    final afterKeyword = line.substring(keywordIndex + keyword.length);
    final match = _valuePattern.firstMatch(afterKeyword);

    if (match != null) {
      final valueStr = match.group(1)?.replaceAll(',', '.');
      final value = double.tryParse(valueStr ?? '');
      if (value != null) {
        final unit = match.group(2);

        // Calculate confidence based on match quality
        final confidence = _calculateConfidence(
          hasUnit: unit != null && unit.isNotEmpty,
          distanceFromKeyword: match.start,
          line: line,
        );

        return (value, unit, confidence);
      }
    }

    return null;
  }

  /// Normalizes text by converting Arabic numerals to Western.
  String _normalizeText(String text) {
    var normalized = text;

    // Convert Arabic numerals
    for (final entry in _arabicNumerals.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    // Clean up extra whitespace
    normalized = normalized.replaceAll(RegExp(r'\s+'), ' ');

    // Normalize common separators
    normalized = normalized.replaceAll(RegExp(r'[:\-–—]'), ':');

    return normalized.trim();
  }
}

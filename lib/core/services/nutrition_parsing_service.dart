import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';

/// Pure Dart service for parsing nutrition facts from OCR text.
///
/// Supports Arabic and English nutrition labels with automatic detection
/// of serving size vs per-100g values and unit conversion.
///
/// Handles multiple OCR output formats:
/// - Same-line: "Protein 25g"
/// - Table format: Labels and values on separate lines
/// - Mixed formats with various separators
class NutritionParsingService {
  /// Labels that should be SKIPPED when counting positions.
  /// These are sub-labels or informational lines that don't have their own value.
  static const List<String> _skipLabels = [
    'calories from fat', // Sub-info under Calories
    'amount per serving',
    'amount per',
    'per serving',
    '% daily value',
    'daily value',
    'المقدار لكل حصة',
    'القيمة اليومية',
  ];

  /// Labels that we don't track but DO have their own value row.
  /// These take up a position in the value matching.
  static const List<String> _untrackedButCountedLabels = [
    'trans fat',
    'trans',
    'cholesterol',
    'calcium',
    'salcium', // Common OCR error
    'potassium',
    'vitamin',
    'iron',
    'دهون متحولة',
    'كوليسترول',
    'كالسيوم',
    'بوتاسيوم',
  ];

  /// Keyword mappings for different languages.
  ///
  /// Maps standard nutrient keys to possible label variations in
  /// English and Arabic. Order matters - more specific keywords first.
  static const Map<String, List<String>> _keyMapping = {
    'energy': [
      // English
      'energy',
      'calories',
      'energie',
      // Arabic
      'طاقة',
      'سعرات حرارية',
      'سعرات',
      'سعرة',
      'الطاقة',
    ],
    'energyKj': [
      'kilojoules',
      'كيلو جول',
    ],
    'fat': [
      // English - more specific first
      'total fat',
      'fats',
      'fat',
      'lipids',
      'matières grasses',
      // Arabic
      'دهون كلية',
      'إجمالي الدهون',
      'الدهون',
      'دهون',
    ],
    'saturatedFat': [
      // English
      'saturated fat',
      'saturated fatty acids',
      'saturates',
      'sat fat',
      'saturated',
      // Arabic
      'دهون مشبعة',
      'الدهون المشبعة',
      'أحماض دهنية مشبعة',
      'مشبعة',
    ],
    'carbohydrates': [
      // English
      'total carbohydrate',
      'Total Carb',
      'carbohydrates',
      'carbohydrate',
      'carbs',
      'glucides',
      // Arabic
      'الكربوهيدرات',
      'كربوهيدرات',
      'نشويات',
      'النشويات',
      "كارب",
      "الكارب"
    ],
    'sugars': [
      // English
      'total sugar',
      'sugars',
      'sugar',
      'sucres',
      // Arabic
      'السكريات',
      'سكريات',
      'سكر كلي',
      'سكر',
    ],
    'fiber': [
      // English
      'dietary fiber',
      'dietary fibre',
      'fiber',
      'fibre',
      'fibres',
      // Arabic
      'ألياف غذائية',
      'الألياف',
      'ألياف',
    ],
    'proteins': [
      // English
      'proteins',
      'protein',
      'protéines',
      // Arabic
      'البروتين',
      'بروتينات',
      'بروتين',
    ],
    'sodium': [
      // English
      'sodium',
      // Arabic
      'الصوديوم',
      'صوديوم',
    ],
    'salt': [
      // English
      'salt',
      'sel',
      // Arabic
      'الملح',
      'ملح',
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

  /// Pattern for extracting values with units.
  /// Matches: "25g", "0.5 mg", "100 kcal", "13 g", etc.
  static final RegExp _valueWithUnitPattern = RegExp(
    r'(\d+[.,]?\d*)\s*(g|mg|kg|kcal|kj|cal|جم|جرام|مجم|كيلو جول)\b',
    caseSensitive: false,
  );

  /// Pattern for standalone numbers (no unit).
  static final RegExp _standaloneNumberPattern = RegExp(
    r'^(\d+[.,]?\d*)$',
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
    r'(?:per\s*100\s*(?:g|ml|gm)|pour\s*100\s*g|لكل\s*100\s*جم|لكل\s*١٠٠\s*جم|/\s*100\s*g)',
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
  /// Handles both same-line and table formats where labels and values
  /// may be on separate lines.
  NutritionFacts parseOcrText(String text) {
    // Normalize text (convert Arabic numerals, clean up)
    final normalizedText = _normalizeText(text);

    // Extract results
    final results = <String, double>{};
    final confidence = <String, double>{};
    String? servingSize;
    double? servingSizeGrams;
    String dataMode = '100g';

    // Detect if this is per-serving or per-100g
    if (_per100gPattern.hasMatch(normalizedText)) {
      dataMode = '100g';
    } else {
      // Try to find serving size
      final servingMatch = _extractServingSize(normalizedText);
      if (servingMatch != null) {
        servingSize = servingMatch.$1;
        servingSizeGrams = servingMatch.$2;
        dataMode = 'serving';
      }
    }

    // Try line-by-line parsing first (works best with spatially ordered OCR)
    _parseLineByLine(normalizedText, results, confidence);

    // If line-by-line didn't find much, try table strategy as fallback
    if (results.length < 3) {
      _parseWithTableStrategy(normalizedText, results, confidence);
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
    double conf = 0.5; // Base confidence

    // Boost for having a unit
    if (hasUnit) {
      conf += 0.25;
    }

    // Boost for value being close to keyword
    if (distanceFromKeyword < 5) {
      conf += 0.15;
    } else if (distanceFromKeyword < 15) {
      conf += 0.1;
    }

    // Boost for line containing separator (more structured)
    if (line.contains(':') || line.contains('\t')) {
      conf += 0.1;
    }

    return conf.clamp(0.0, 1.0);
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

  /// Extracts a nutrient value from a single line (legacy fallback).
  void _extractNutrientFromLine(
    String line,
    Map<String, double> results,
    Map<String, double> confidence,
  ) {
    final lineLower = line.toLowerCase();

    // Skip lines that should be ignored (sub-labels without own values)
    if (_shouldSkipLabel(line)) {
      return;
    }

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
          // Found a match, try to extract value from same line
          final extractedValue = _extractValueAfterKeyword(line, keyword);
          if (extractedValue != null) {
            final (value, unit, conf) = extractedValue;

            // Convert to standard unit
            final standardValue = _convertToStandardUnit(
              value,
              unit,
              nutrientKey,
            );

            // Convert unit to standard (e.g., mg to g for sodium/salt)
            double finalValue = standardValue;
            if (unit?.toLowerCase() == 'mg' &&
                (nutrientKey == 'sodium' || nutrientKey == 'salt')) {
              finalValue = standardValue / 1000;
            }

            // Only update if confidence is higher
            if (!results.containsKey(nutrientKey) ||
                conf > (confidence[nutrientKey] ?? 0)) {
              results[nutrientKey] = finalValue;
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

  /// Extracts a numeric value from text after a keyword.
  ///
  /// Returns (value, unit, confidence) or null if not found.
  (double, String?, double)? _extractValueAfterKeyword(
      String line, String keyword) {
    // Find the keyword position
    final keywordIndex = line.toLowerCase().indexOf(keyword.toLowerCase());
    if (keywordIndex == -1) return null;

    // Look for value after the keyword
    final afterKeyword = line.substring(keywordIndex + keyword.length);

    // Try value with unit first
    final unitMatch = _valueWithUnitPattern.firstMatch(afterKeyword);
    if (unitMatch != null) {
      final valueStr = unitMatch.group(1)?.replaceAll(',', '.');
      final value = double.tryParse(valueStr ?? '');
      if (value != null) {
        final unit = unitMatch.group(2);
        final conf = _calculateConfidence(
          hasUnit: unit != null && unit.isNotEmpty,
          distanceFromKeyword: unitMatch.start,
          line: line,
        );
        return (value, unit, conf);
      }
    }

    // Try any number
    final numberMatch = RegExp(r'(\d+[.,]?\d*)').firstMatch(afterKeyword);
    if (numberMatch != null) {
      final valueStr = numberMatch.group(1)?.replaceAll(',', '.');
      final value = double.tryParse(valueStr ?? '');
      if (value != null) {
        final conf = _calculateConfidence(
          hasUnit: false,
          distanceFromKeyword: numberMatch.start,
          line: line,
        );
        return (value, null, conf);
      }
    }

    return null;
  }

  /// Extracts a numeric value from a line.
  ///
  /// Returns (value, unit, confidence) or null if no value found.
  (double, String?, double)? _extractValueFromLine(String line,
      {bool allowHighEnergy = true}) {
    final trimmed = line.trim();

    // Skip lines that are clearly not values
    if (trimmed.isEmpty) return null;

    // Skip lines that look like headers or labels only (no numbers)
    if (!RegExp(r'\d').hasMatch(trimmed)) return null;

    // First try to find value with unit (more reliable)
    final unitMatch = _valueWithUnitPattern.firstMatch(trimmed);
    if (unitMatch != null) {
      final valueStr = unitMatch.group(1)?.replaceAll(',', '.');
      final value = double.tryParse(valueStr ?? '');
      if (value != null) {
        final unit = unitMatch.group(2);
        return (value, unit, 0.85); // Higher base confidence with unit
      }
    }

    // Try standalone number
    final standaloneMatch = _standaloneNumberPattern.firstMatch(trimmed);
    if (standaloneMatch != null) {
      final valueStr = standaloneMatch.group(1)?.replaceAll(',', '.');
      final value = double.tryParse(valueStr ?? '');
      if (value != null) {
        // For standalone numbers, infer the type based on value range:
        // - 0-100: likely grams (macros)
        // - 100-3000: likely kcal (energy) - mass gainers can have 1000+ kcal
        // - >3000: likely kJ or OCR noise
        if (value <= 100) {
          return (value, 'g', 0.6); // Assume grams
        } else if (value <= 3000 && allowHighEnergy) {
          return (value, 'kcal', 0.5); // Assume kcal for energy
        } else {
          // Could be kJ or noise - low confidence
          return (value, null, 0.3);
        }
      }
    }

    // Try to extract any number from the line
    final anyNumberMatch = RegExp(r'(\d+[.,]?\d*)').firstMatch(trimmed);
    if (anyNumberMatch != null) {
      final valueStr = anyNumberMatch.group(1)?.replaceAll(',', '.');
      final value = double.tryParse(valueStr ?? '');
      if (value != null) {
        // Check if there's a unit nearby
        final afterNumber = trimmed.substring(anyNumberMatch.end).trim();
        final unitMatchAfter =
            RegExp(r'^(g|mg|kcal|kj|cal)\b', caseSensitive: false)
                .firstMatch(afterNumber);
        final unit = unitMatchAfter?.group(1);

        return (value, unit ?? 'g', unit != null ? 0.75 : 0.5);
      }
    }

    return null;
  }

  /// Identifies if a line is primarily a nutrient label.
  ///
  /// Returns the nutrient key if found, null otherwise.
  String? _identifyNutrientLabel(String line) {
    final lineLower = line.toLowerCase().trim();

    // Skip lines that are primarily numeric
    if (_standaloneNumberPattern.hasMatch(lineLower)) {
      return null;
    }

    // Skip lines that look like values with units only
    if (_valueWithUnitPattern.hasMatch(lineLower) &&
        _valueWithUnitPattern.firstMatch(lineLower)?.group(0)?.length ==
            lineLower.length) {
      return null;
    }

    for (final entry in _keyMapping.entries) {
      for (final keyword in entry.value) {
        if (lineLower.contains(keyword.toLowerCase())) {
          return entry.key;
        }
      }
    }

    return null;
  }

  /// Checks if a line is an untracked but counted label.
  ///
  /// These labels (like Cholesterol, Trans fat, Calcium) have values in the
  /// nutrition table but we don't track them in our app. They need to be
  /// counted to correctly match tracked labels to their values.
  bool _isUntrackedButCountedLabel(String line) {
    final lineLower = line.trim().toLowerCase();

    for (final label in _untrackedButCountedLabels) {
      if (lineLower.contains(label)) {
        return true;
      }
    }

    return false;
  }

  /// Checks if a value is plausible for a given nutrient.
  bool _isValuePlausibleForNutrient(
      double value, String? unit, String nutrientKey) {
    final unitLower = unit?.toLowerCase() ?? '';

    // Energy can be 0-3000 kcal (mass gainers!) or 0-12000 kJ
    if (nutrientKey == 'energy') {
      if (unitLower == 'kj') return value >= 0 && value <= 15000;
      return value >= 0 && value <= 3000; // kcal
    }

    // Convert mg to g for comparison
    var valueInGrams = value;
    if (unitLower == 'mg') {
      valueInGrams = value / 1000;
    }

    // Macros should be 0-100g per serving (or per 100g)
    // But some supplements can have higher values per serving
    switch (nutrientKey) {
      case 'fat':
      case 'saturatedFat':
      case 'carbohydrates':
      case 'sugars':
      case 'fiber':
      case 'proteins':
        return valueInGrams >= 0 &&
            valueInGrams <= 500; // Allow high for supplements
      case 'sodium':
      case 'salt':
        return valueInGrams >= 0 &&
            valueInGrams <= 10; // Sodium is usually small
      default:
        return value >= 0;
    }
  }

  /// Checks if a line looks like a label (text with minimal numbers).
  bool _looksLikeLabel(String line) {
    final trimmed = line.trim().toLowerCase();
    if (trimmed.isEmpty) return false;

    // Must have some letters
    if (!RegExp(r'[a-zأ-ي]').hasMatch(trimmed)) return false;

    // Should not be primarily numeric
    final digits = RegExp(r'\d').allMatches(trimmed).length;
    final letters = RegExp(r'[a-zأ-ي]').allMatches(trimmed).length;

    // More letters than digits suggests it's a label
    return letters > digits;
  }

  /// Matches tracked labels to values, accounting for untracked labels.
  void _matchLabelsToValues(
    Map<int, String> trackedLabels,
    List<int> untrackedLabels,
    Map<int, (double, String?, double)> valueLines,
    Map<String, double> results,
    Map<String, double> confidence,
  ) {
    final sortedTrackedIndices = trackedLabels.keys.toList()..sort();
    final sortedValueIndices = valueLines.keys.toList()..sort();

    // Combine all labels (tracked + untracked) to understand the full structure
    final allLabelIndices = [...sortedTrackedIndices, ...untrackedLabels]
      ..sort();

    // Check if this is a "labels first, then values" pattern
    if (allLabelIndices.isEmpty || sortedValueIndices.isEmpty) return;

    final lastLabelIndex = allLabelIndices.last;
    final firstValueIndex = sortedValueIndices.first;

    if (lastLabelIndex < firstValueIndex) {
      // Pattern: All labels first, then all values
      // Match by relative position within each group

      // For each tracked label, find its position in ALL labels
      // Then match to the value at the same relative position
      for (final trackedIndex in sortedTrackedIndices) {
        final nutrientKey = trackedLabels[trackedIndex]!;
        if (results.containsKey(nutrientKey)) continue;

        // Find position of this label among ALL labels
        final labelPosition = allLabelIndices.indexOf(trackedIndex);
        if (labelPosition == -1) continue;

        // Match to value at same position
        if (labelPosition < sortedValueIndices.length) {
          final valueIndex = sortedValueIndices[labelPosition];
          final (value, unit, baseConf) = valueLines[valueIndex]!;

          // Validate the match makes sense
          if (_isValuePlausibleForNutrient(value, unit, nutrientKey)) {
            final standardValue =
                _convertToStandardUnit(value, unit, nutrientKey);
            results[nutrientKey] = standardValue;
            confidence[nutrientKey] = (baseConf + 0.1).clamp(0.4, 0.95);
          }
        }
      }
    } else {
      // Pattern: Interleaved - match labels to nearest following values
      final usedValueIndices = <int>{};

      for (final labelIndex in sortedTrackedIndices) {
        final nutrientKey = trackedLabels[labelIndex]!;
        if (results.containsKey(nutrientKey)) continue;

        // Find the closest unused value after this label
        int? closestValueIndex;
        for (final valueIndex in sortedValueIndices) {
          if (valueIndex > labelIndex &&
              !usedValueIndices.contains(valueIndex)) {
            closestValueIndex = valueIndex;
            break;
          }
        }

        if (closestValueIndex != null) {
          final (value, unit, baseConf) = valueLines[closestValueIndex]!;

          if (_isValuePlausibleForNutrient(value, unit, nutrientKey)) {
            final standardValue =
                _convertToStandardUnit(value, unit, nutrientKey);
            final distance = closestValueIndex - labelIndex;

            var conf = baseConf;
            if (distance == 1) {
              conf += 0.15;
            } else if (distance == 2) {
              conf += 0.05;
            } else if (distance > 3) {
              conf -= 0.1;
            }

            results[nutrientKey] = standardValue;
            confidence[nutrientKey] = conf.clamp(0.4, 0.95);
            usedValueIndices.add(closestValueIndex);
          }
        }
      }
    }
  }

  /// Normalizes text by converting Arabic numerals to Western.
  String _normalizeText(String text) {
    var normalized = text;

    // Convert Arabic numerals
    for (final entry in _arabicNumerals.entries) {
      normalized = normalized.replaceAll(entry.key, entry.value);
    }

    // Fix common OCR errors
    // Replace letter 'O' with '0' when it appears before units like mg, g, kcal
    normalized = normalized.replaceAllMapped(
      RegExp(r'\bO\s*(mg|g|kcal|kj)\b', caseSensitive: false),
      (m) => '0 ${m.group(1)}',
    );

    // Replace standalone 'O' at start of line followed by space and unit
    normalized = normalized.replaceAllMapped(
      RegExp(r'^O\s+', multiLine: true),
      (m) => '0 ',
    );

    // Normalize common separators
    normalized = normalized.replaceAll(RegExp(r'[:\-–—]'), ':');

    // Don't collapse all whitespace - keep newlines for structure
    normalized = normalized.replaceAll(RegExp(r'[ \t]+'), ' ');

    return normalized.trim();
  }

  /// Traditional line-by-line parsing with look-ahead for split labels/values.
  void _parseLineByLine(
    String text,
    Map<String, double> results,
    Map<String, double> confidence,
  ) {
    final lines = text.split('\n').map((l) => l.trim()).toList();

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip lines that should be ignored
      if (_shouldSkipLabel(line)) {
        continue;
      }

      // First try to extract from this line alone
      _extractNutrientFromLine(line, results, confidence);

      // If this line looks like a label without a value,
      // check if the next line has a value
      final nutrientKey = _identifyNutrientLabel(line);
      if (nutrientKey != null &&
          !results.containsKey(nutrientKey) &&
          i + 1 < lines.length) {
        final nextLine = lines[i + 1];
        final valueData = _extractValueFromLine(nextLine);

        if (valueData != null) {
          final (value, unit, baseConf) = valueData;

          // Validate the value makes sense for this nutrient
          if (_isValuePlausibleForNutrient(value, unit, nutrientKey)) {
            final standardValue =
                _convertToStandardUnit(value, unit, nutrientKey);
            results[nutrientKey] = standardValue;
            confidence[nutrientKey] =
                baseConf * 0.9; // Slightly lower confidence
            i++; // Skip the value line since we consumed it
          }
        }
      }
    }
  }

  /// Parses text using table strategy.
  ///
  /// This handles OCR output where labels are in one column and values
  /// in another. Common patterns:
  /// 1. Labels and values on same line: "Protein 25g"
  /// 2. Labels first, then values in order (table scanned column by column)
  /// 3. Interleaved labels and values
  void _parseWithTableStrategy(
    String text,
    Map<String, double> results,
    Map<String, double> confidence,
  ) {
    final lines = text
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    // First pass: categorize each line
    final trackedLabels =
        <int, String>{}; // Lines with labels WE track (energy, fat, etc.)
    final untrackedLabels =
        <int>[]; // Lines with labels we DON'T track but have values (cholesterol, trans fat, etc.)
    final valueLines =
        <int, (double, String?, double)>{}; // Lines with numeric values

    for (var i = 0; i < lines.length; i++) {
      final line = lines[i];

      // Skip labels that don't have their own value row (like "Calories from fat")
      if (_shouldSkipLabel(line)) {
        continue;
      }

      // Check if this line contains a tracked nutrient label
      final nutrientKey = _identifyNutrientLabel(line);

      // Check if line looks like a label (has text, minimal numbers)
      final looksLikeLabel = _looksLikeLabel(line);

      // Check if line has a value
      final valueData = _extractValueFromLine(line);

      if (nutrientKey != null) {
        // This is a label we track
        if (valueData != null) {
          // Value on same line - extract directly
          final (value, unit, _) = valueData;
          final standardValue =
              _convertToStandardUnit(value, unit, nutrientKey);
          if (!results.containsKey(nutrientKey)) {
            results[nutrientKey] = standardValue;
            confidence[nutrientKey] = _calculateConfidence(
              hasUnit: unit != null && unit.isNotEmpty,
              distanceFromKeyword: 0,
              line: line,
            );
          }
        } else {
          // Label only - mark for matching
          trackedLabels[i] = nutrientKey;
        }
      } else if (looksLikeLabel && valueData == null) {
        // Check if this is an untracked label that has a value row
        if (_isUntrackedButCountedLabel(line)) {
          untrackedLabels.add(i);
        }
        // If it's neither tracked nor in our untracked list, skip it
        // (e.g., headers like "Nutrition Facts", "Amount per serving", etc.)
      } else if (valueData != null) {
        // This is a value line
        valueLines[i] = valueData;
      }
    }

    // If we found tracked labels and values separately, match them
    if (trackedLabels.isNotEmpty && valueLines.isNotEmpty) {
      _matchLabelsToValues(
        trackedLabels,
        untrackedLabels,
        valueLines,
        results,
        confidence,
      );
    }
  }

  /// Checks if a line should be skipped (doesn't have its own value row).
  ///
  /// These are typically header rows or sub-labels that appear on the label
  /// but don't have a corresponding value in the values column.
  bool _shouldSkipLabel(String line) {
    final lineLower = line.trim().toLowerCase();

    for (final skip in _skipLabels) {
      if (lineLower.contains(skip)) {
        return true;
      }
    }

    return false;
  }
}

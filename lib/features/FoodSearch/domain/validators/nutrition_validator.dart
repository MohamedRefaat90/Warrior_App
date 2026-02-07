import '../entities/product_validation_result.dart';

/// Validates nutrition values format and content.
class NutritionValidator {
  /// Maximum acceptable calorie value per 100g.
  static const double maxCalories = 1000;

  /// Maximum acceptable percentage values (0-100%).
  static const double maxPercentage = 100;

  /// Validates calories value is within acceptable range.
  ///
  /// Calories is optional (can be empty or null).
  /// If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 1000 (calories per 100g)
  ///
  /// Returns a successful validation if valid, field error otherwise.
  static ProductValidationResult validateCalories(String? calories) {
    final trimmedCalories = (calories ?? '').trim();

    if (trimmedCalories.isEmpty) {
      return ProductValidationResult.success();
    }

    final parsed = double.tryParse(trimmedCalories);
    if (parsed == null) {
      return ProductValidationResult.fieldErrors({
        'calories': 'Calories must be a valid number',
      });
    }

    if (parsed < 0) {
      return ProductValidationResult.fieldErrors({
        'calories': 'Calories cannot be negative',
      });
    }

    if (parsed > maxCalories) {
      return ProductValidationResult.fieldErrors({
        'calories': 'Calories must be at most $maxCalories per 100g',
      });
    }

    return ProductValidationResult.success();
  }

  /// Validates protein value is within acceptable range.
  ///
  /// Protein is optional. If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 100 (percentage)
  static ProductValidationResult validateProtein(String? protein) {
    return _validatePercentageValue(protein, 'protein');
  }

  /// Validates fat value is within acceptable range.
  ///
  /// Fat is optional. If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 100 (percentage or grams)
  static ProductValidationResult validateFat(String? fat) {
    return _validatePercentageValue(fat, 'fat');
  }

  /// Validates carbohydrates value is within acceptable range.
  ///
  /// Carbs is optional. If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 100 (percentage or grams)
  static ProductValidationResult validateCarbohydrates(String? carbs) {
    return _validatePercentageValue(carbs, 'carbohydrates');
  }

  /// Validates fiber value is within acceptable range.
  ///
  /// Fiber is optional. If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 100 (grams)
  static ProductValidationResult validateFiber(String? fiber) {
    return _validatePercentageValue(fiber, 'fiber');
  }

  /// Validates sugar value is within acceptable range.
  ///
  /// Sugar is optional. If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 100 (grams)
  static ProductValidationResult validateSugar(String? sugar) {
    return _validatePercentageValue(sugar, 'sugar');
  }

  /// Validates salt/sodium value is within acceptable range.
  ///
  /// Salt is optional. If provided, must be:
  /// - A valid positive number
  /// - Between 0 and 100 (grams)
  static ProductValidationResult validateSalt(String? salt) {
    return _validatePercentageValue(salt, 'salt');
  }

  /// Internal helper to validate percentage/percentage-like values.
  static ProductValidationResult _validatePercentageValue(
    String? value,
    String fieldName,
  ) {
    final trimmedValue = (value ?? '').trim();

    if (trimmedValue.isEmpty) {
      return ProductValidationResult.success();
    }

    final parsed = double.tryParse(trimmedValue);
    if (parsed == null) {
      return ProductValidationResult.fieldErrors({
        fieldName: '$fieldName must be a valid number',
      });
    }

    if (parsed < 0) {
      return ProductValidationResult.fieldErrors({
        fieldName: '$fieldName cannot be negative',
      });
    }

    if (parsed > maxPercentage) {
      return ProductValidationResult.fieldErrors({
        fieldName: '$fieldName must be at most $maxPercentage',
      });
    }

    return ProductValidationResult.success();
  }
}

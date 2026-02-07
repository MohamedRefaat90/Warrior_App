import '../entities/product_validation_result.dart';

/// Validates product brand name format and content.
class BrandValidator {
  /// Minimum length for brand name (if provided).
  static const int minLength = 2;

  /// Maximum length for brand name.
  static const int maxLength = 50;

  /// Validates brand name is valid if provided.
  ///
  /// Brand is optional, so empty value is acceptable.
  /// If brand is provided, it must be:
  /// - Between 2 and 50 characters
  ///
  /// Returns a successful validation if:
  /// - Brand is not provided (empty after trimming), OR
  /// - Brand length is at least 2 characters AND at most 50 characters
  ///
  /// Returns a field error with message describing the issue otherwise.
  static ProductValidationResult validate(String? brand) {
    final trimmedBrand = (brand ?? '').trim();

    // Brand is optional - empty is valid
    if (trimmedBrand.isEmpty) {
      return ProductValidationResult.success();
    }

    if (trimmedBrand.length < minLength) {
      return ProductValidationResult.fieldErrors({
        'brand': 'Brand must be at least $minLength characters',
      });
    }

    if (trimmedBrand.length > maxLength) {
      return ProductValidationResult.fieldErrors({
        'brand': 'Brand must be at most $maxLength characters',
      });
    }

    return ProductValidationResult.success();
  }
}

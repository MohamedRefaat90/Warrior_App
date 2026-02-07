import '../entities/product_validation_result.dart';

/// Validates product name format and content.
class ProductNameValidator {
  /// Minimum length for product name.
  static const int minLength = 2;

  /// Maximum length for product name.
  static const int maxLength = 100;

  /// Validates product name is not empty and is between 2 and 100 characters.
  ///
  /// Returns a successful validation if:
  /// - Product name is provided (not empty after trimming)
  /// - Product name length is at least 2 characters
  /// - Product name length is at most 100 characters
  ///
  /// Returns a field error with message describing the issue otherwise.
  static ProductValidationResult validate(String? productName) {
    final trimmedName = (productName ?? '').trim();

    if (trimmedName.isEmpty) {
      return ProductValidationResult.fieldErrors({
        'productName': 'Product name is required',
      });
    }

    if (trimmedName.length < minLength) {
      return ProductValidationResult.fieldErrors({
        'productName': 'Product name must be at least $minLength characters',
      });
    }

    if (trimmedName.length > maxLength) {
      return ProductValidationResult.fieldErrors({
        'productName': 'Product name must be at most $maxLength characters',
      });
    }

    return ProductValidationResult.success();
  }
}

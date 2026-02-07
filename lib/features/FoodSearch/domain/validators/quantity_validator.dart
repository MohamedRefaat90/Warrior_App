import '../entities/product_validation_result.dart';

/// Validates product quantity format and content.
class QuantityValidator {
  /// Validates quantity is a positive number.
  ///
  /// Quantity is optional (can be empty or null).
  /// If quantity is provided, it must be:
  /// - A valid number (can contain digits and decimal point)
  /// - Greater than zero
  ///
  /// Returns a successful validation if:
  /// - Quantity is not provided (empty after trimming), OR
  /// - Quantity is a valid positive number
  ///
  /// Returns a field error with message describing the issue otherwise.
  static ProductValidationResult validate(String? quantity) {
    final trimmedQuantity = (quantity ?? '').trim();

    // Quantity is optional - empty is valid
    if (trimmedQuantity.isEmpty) {
      return ProductValidationResult.success();
    }

    // Try to parse as double
    final parsed = double.tryParse(trimmedQuantity);
    if (parsed == null) {
      return ProductValidationResult.fieldErrors({
        'quantity': 'Quantity must be a valid number',
      });
    }

    if (parsed <= 0) {
      return ProductValidationResult.fieldErrors({
        'quantity': 'Quantity must be greater than zero',
      });
    }

    return ProductValidationResult.success();
  }
}

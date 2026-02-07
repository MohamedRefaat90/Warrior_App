import '../entities/product_validation_result.dart';

/// Validates product barcode format and content.
class BarcodeValidator {
  /// Validates barcode is not empty and contains 8-13 digits.
  ///
  /// Returns a successful validation if:
  /// - Barcode is provided (not empty after trimming)
  /// - Barcode contains only digits
  /// - Barcode length is between 8 and 13 characters
  ///
  /// Returns a field error with message describing the issue otherwise.
  static ProductValidationResult validate(String? barcode) {
    final trimmedBarcode = (barcode ?? '').trim();

    if (trimmedBarcode.isEmpty) {
      return ProductValidationResult.fieldErrors({
        'barcode': 'Barcode is required',
      });
    }

    if (!RegExp(r'^\d+$').hasMatch(trimmedBarcode)) {
      return ProductValidationResult.fieldErrors({
        'barcode': 'Barcode must contain only digits',
      });
    }

    if (trimmedBarcode.length < 8 || trimmedBarcode.length > 13) {
      return ProductValidationResult.fieldErrors({
        'barcode': 'Barcode must be 8-13 digits',
      });
    }

    return ProductValidationResult.success();
  }
}

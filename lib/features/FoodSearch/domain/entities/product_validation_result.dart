import 'package:equatable/equatable.dart';

/// Result of product validation.
///
/// Contains validation success/failure information and detailed error messages
/// for form fields, enabling precise error feedback to users.
class ProductValidationResult extends Equatable {
  /// Whether the product passed all validations.
  final bool isValid;

  /// Map of field names to validation error messages.
  /// Empty map indicates all fields are valid.
  final Map<String, String> fieldErrors;

  /// General validation error message (if applicable).
  final String? generalError;

  const ProductValidationResult({
    required this.isValid,
    Map<String, String>? fieldErrors,
    this.generalError,
  }) : fieldErrors = fieldErrors ?? const {};

  /// Creates a failed validation result with a general error.
  factory ProductValidationResult.error(String message) {
    return ProductValidationResult(
      isValid: false,
      generalError: message,
    );
  }

  /// Creates a failed validation result with field-level errors.
  factory ProductValidationResult.fieldErrors(
    Map<String, String> errors, {
    String? generalError,
  }) {
    return ProductValidationResult(
      isValid: false,
      fieldErrors: errors,
      generalError: generalError,
    );
  }

  /// Creates a successful validation result.
  factory ProductValidationResult.success() {
    return const ProductValidationResult(isValid: true);
  }

  /// Returns all validation errors as a single message.
  String get errorMessage {
    if (generalError != null) return generalError!;
    if (fieldErrors.isEmpty) return 'Validation failed';
    return fieldErrors.values.join(', ');
  }

  @override
  List<Object?> get props => [isValid, fieldErrors, generalError];
}

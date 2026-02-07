# Contract: Product Validation Rules

**Feature**: 001-food-search-polish  
**Version**: 1.0.0  
**Date**: 2026-02-07

## Overview

This contract defines the validation rules for product submissions to OpenFoodFacts API. These rules ensure data quality and API compatibility.

---

## Field: Barcode

**Purpose**: Unique product identifier (EAN-8, EAN-13, UPC-A, UPC-E formats)

### Validation Rules

| Rule | Type | Description | Error Message |
|------|------|-------------|---------------|
| Required | Presence | Barcode must be provided | "Barcode is required" |
| Format | Regex | Must be 8-13 digits only | "Barcode must be 8-13 digits" |
| Length | Range | Min 8, Max 13 characters | "Barcode must be 8-13 digits" |

### Implementation

```dart
class BarcodeValidator {
  static const _barcodePattern = r'^\d{8,13}$';
  static final _barcodeRegex = RegExp(_barcodePattern);
  
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Barcode is required';
    }
    
    if (!_barcodeRegex.hasMatch(value.trim())) {
      return 'Barcode must be 8-13 digits';
    }
    
    return null; // Valid
  }
}
```

### Test Cases

```dart
test('BarcodeValidator accepts valid EAN-13', () {
  expect(BarcodeValidator.validate('5449000000996'), isNull);
});

test('BarcodeValidator accepts valid EAN-8', () {
  expect(BarcodeValidator.validate('12345678'), isNull);
});

test('BarcodeValidator rejects empty string', () {
  expect(BarcodeValidator.validate(''), equals('Barcode is required'));
});

test('BarcodeValidator rejects non-digits', () {
  expect(BarcodeValidator.validate('123ABC456'), equals('Barcode must be 8-13 digits'));
});

test('BarcodeValidator rejects too short', () {
  expect(BarcodeValidator.validate('1234567'), equals('Barcode must be 8-13 digits'));
});

test('BarcodeValidator rejects too long', () {
  expect(BarcodeValidator.validate('12345678901234'), equals('Barcode must be 8-13 digits'));
});
```

### OpenFoodFacts API Contract

According to [OpenFoodFacts API documentation](https://wiki.openfoodfacts.org/API):

```json
{
  "code": "5449000000996",  // Required, 8-13 digit string
  "product": {
    // ... product fields
  }
}
```

---

## Field: Product Name

**Purpose**: Human-readable product name/title

### Validation Rules

| Rule | Type | Description | Error Message |
|------|------|-------------|---------------|
| Required | Presence | Product name must be provided | "Product name is required" |
| Length Min | Range | At least 2 characters | "Product name must be at least 2 characters" |
| Length Max | Range | At most 200 characters | "Product name must not exceed 200 characters" |
| Non-empty | Whitespace | Not just whitespace | "Product name cannot be empty" |

### Implementation

```dart
class ProductNameValidator {
  static const int minLength = 2;
  static const int maxLength = 200;
  
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Product name is required';
    }
    
    final trimmed = value.trim();
    
    if (trimmed.length < minLength) {
      return 'Product name must be at least $minLength characters';
    }
    
    if (trimmed.length > maxLength) {
      return 'Product name must not exceed $maxLength characters';
    }
    
    return null; // Valid
  }
}
```

### Test Cases

```dart
test('ProductNameValidator accepts valid name', () {
  expect(ProductNameValidator.validate('Coca Cola'), isNull);
});

test('ProductNameValidator accepts name at min length', () {
  expect(ProductNameValidator.validate('Ok'), isNull);
});

test('ProductNameValidator accepts name at max length', () {
  final name = 'A' * 200;
  expect(ProductNameValidator.validate(name), isNull);
});

test('ProductNameValidator rejects empty string', () {
  expect(ProductNameValidator.validate(''), equals('Product name is required'));
});

test('ProductNameValidator rejects whitespace only', () {
  expect(ProductNameValidator.validate('   '), equals('Product name is required'));
});

test('ProductNameValidator rejects too short', () {
  expect(
    ProductNameValidator.validate('A'),
    equals('Product name must be at least 2 characters'),
  );
});

test('ProductNameValidator rejects too long', () {
  final name = 'A' * 201;
  expect(
    ProductNameValidator.validate(name),
    equals('Product name must not exceed 200 characters'),
  );
});
```

---

## Field: Brand (Optional)

**Purpose**: Product manufacturer/brand name

### Validation Rules

| Rule | Type | Description | Error Message |
|------|------|-------------|---------------|
| Optional | Presence | Can be null/empty | N/A |
| Length Max | Range | At most 100 characters if provided | "Brand name must not exceed 100 characters" |

### Implementation

```dart
class BrandValidator {
  static const int maxLength = 100;
  
  static String? validate(String? value) {
    // Optional field - null/empty is valid
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    
    if (value.trim().length > maxLength) {
      return 'Brand name must not exceed $maxLength characters';
    }
    
    return null; // Valid
  }
}
```

---

## Field: Quantity (Optional)

**Purpose**: Product quantity/size (e.g., "330ml", "1L", "500g")

### Validation Rules

| Rule | Type | Description | Error Message |
|------|------|-------------|---------------|
| Optional | Presence | Can be null/empty | N/A |
| Length Max | Range | At most 50 characters if provided | "Quantity must not exceed 50 characters" |

### Implementation

```dart
class QuantityValidator {
  static const int maxLength = 50;
  
  static String? validate(String? value) {
    // Optional field - null/empty is valid
    if (value == null || value.trim().isEmpty) {
      return null;
    }
    
    if (value.trim().length > maxLength) {
      return 'Quantity must not exceed $maxLength characters';
    }
    
    return null; // Valid
  }
}
```

---

## Field: Nutrition Values (Optional)

**Purpose**: Nutritional information per 100g/100ml

### Validation Rules

| Field | Type | Min | Max | Required | Error Message |
|-------|------|-----|-----|----------|---------------|
| energy | double | 0 | 9999 | No | "Energy must be between 0-9999 kcal" |
| proteins | double | 0 | 100 | No | "Proteins must be between 0-100g" |
| carbohydrates | double | 0 | 100 | No | "Carbohydrates must be between 0-100g" |
| fat | double | 0 | 100 | No | "Fat must be between 0-100g" |
| fiber | double | 0 | 100 | No | "Fiber must be between 0-100g" |
| sodium | double | 0 | 100 | No | "Sodium must be between 0-100g" |
| sugars | double | 0 | 100 | No | "Sugars must be between 0-100g" |

### Implementation

```dart
class NutritionValidator {
  static String? validateEnergy(double? value) {
    if (value == null) return null; // Optional
    if (value < 0 || value > 9999) {
      return 'Energy must be between 0-9999 kcal';
    }
    return null;
  }
  
  static String? validateMacro(double? value, String macroName) {
    if (value == null) return null; // Optional
    if (value < 0 || value > 100) {
      return '$macroName must be between 0-100g';
    }
    return null;
  }
  
  static String? validateProteins(double? value) => 
      validateMacro(value, 'Proteins');
  
  static String? validateCarbohydrates(double? value) => 
      validateMacro(value, 'Carbohydrates');
  
  static String? validateFat(double? value) => 
      validateMacro(value, 'Fat');
  
  static String? validateFiber(double? value) => 
      validateMacro(value, 'Fiber');
  
  static String? validateSodium(double? value) => 
      validateMacro(value, 'Sodium');
  
  static String? validateSugars(double? value) => 
      validateMacro(value, 'Sugars');
}
```

---

## Composite Validator

### ProductValidation Service

Combines all field validators into a single validation service:

```dart
class ProductValidation {
  static ProductValidationResult validate({
    required String? barcode,
    required String? productName,
    String? brand,
    String? quantity,
    double? energy,
    double? proteins,
    double? carbohydrates,
    double? fat,
    double? fiber,
    double? sodium,
    double? sugars,
  }) {
    final errors = <String, String>{};
    
    // Required fields
    final barcodeError = BarcodeValidator.validate(barcode);
    if (barcodeError != null) {
      errors['barcode'] = barcodeError;
    }
    
    final nameError = ProductNameValidator.validate(productName);
    if (nameError != null) {
      errors['productName'] = nameError;
    }
    
    // Optional fields
    final brandError = BrandValidator.validate(brand);
    if (brandError != null) {
      errors['brand'] = brandError;
    }
    
    final quantityError = QuantityValidator.validate(quantity);
    if (quantityError != null) {
      errors['quantity'] = quantityError;
    }
    
    // Nutrition validation
    final energyError = NutritionValidator.validateEnergy(energy);
    if (energyError != null) {
      errors['energy'] = energyError;
    }
    
    final proteinsError = NutritionValidator.validateProteins(proteins);
    if (proteinsError != null) {
      errors['proteins'] = proteinsError;
    }
    
    final carbsError = NutritionValidator.validateCarbohydrates(carbohydrates);
    if (carbsError != null) {
      errors['carbohydrates'] = carbsError;
    }
    
    final fatError = NutritionValidator.validateFat(fat);
    if (fatError != null) {
      errors['fat'] = fatError;
    }
    
    final fiberError = NutritionValidator.validateFiber(fiber);
    if (fiberError != null) {
      errors['fiber'] = fiberError;
    }
    
    final sodiumError = NutritionValidator.validateSodium(sodium);
    if (sodiumError != null) {
      errors['sodium'] = sodiumError;
    }
    
    final sugarsError = NutritionValidator.validateSugars(sugars);
    if (sugarsError != null) {
      errors['sugars'] = sugarsError;
    }
    
    return errors.isEmpty
        ? ProductValidationResult.valid()
        : ProductValidationResult.invalid(errors);
  }
}
```

---

## UI Integration Contract

### Form Error Display

**Requirement**: Show validation errors inline below each field with error styling.

```dart
// In widget
TextField(
  controller: _barcodeController,
  decoration: InputDecoration(
    labelText: 'Barcode',
    errorText: _validationErrors['barcode'], // Show error if present
    border: OutlineInputBorder(),
    errorBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Colors.red, width: 2),
    ),
  ),
  keyboardType: TextInputType.number,
  onChanged: (_) => _clearFieldError('barcode'),
)
```

### Real-time Validation

**Requirement**: Validate on blur (onSubmitted) and on form submission

```dart
class _ProductFormState extends State<ProductFormScreen> {
  Map<String, String> _validationErrors = {};
  
  void _validateField(String fieldName, String? value) {
    String? error;
    switch (fieldName) {
      case 'barcode':
        error = BarcodeValidator.validate(value);
        break;
      case 'productName':
        error = ProductNameValidator.validate(value);
        break;
      // ... other fields
    }
    
    setState(() {
      if (error != null) {
        _validationErrors[fieldName] = error;
      } else {
        _validationErrors.remove(fieldName);
      }
    });
  }
  
  void _clearFieldError(String fieldName) {
    setState(() {
      _validationErrors.remove(fieldName);
    });
  }
  
  Future<void> _submitForm() async {
    // Validate all fields
    final result = ProductValidation.validate(
      barcode: _barcodeController.text,
      productName: _nameController.text,
      brand: _brandController.text,
      quantity: _quantityController.text,
      // ... nutrition fields
    );
    
    if (!result.isValid) {
      setState(() {
        _validationErrors = result.fieldErrors;
      });
      
      // Show snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please fix ${result.fieldErrors.length} error(s)'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    
    // Proceed with submission
    await _submitProduct();
  }
}
```

---

## Test Coverage Requirements

**Minimum**: 100% coverage for all validators (unit tests)

**Required Test Cases**:
- ✅ Valid inputs (happy path)
- ✅ Null/empty inputs
- ✅ Boundary values (min/max lengths)
- ✅ Invalid formats
- ✅ Whitespace handling
- ✅ Edge cases (just beyond boundaries)

**Test Location**: `test/unit/food_search/validators/`

---

## Summary

| Validator | Fields | Required | Complexity |
|-----------|--------|----------|------------|
| BarcodeValidator | barcode | Yes | Medium (regex) |
| ProductNameValidator | productName | Yes | Low |
| BrandValidator | brand | No | Low |
| QuantityValidator | quantity | No | Low |
| NutritionValidator | 7 nutrition fields | No | Low |

**Total Validators**: 5  
**Total Validation Rules**: 15+  
**Test Cases Required**: 30+ (minimum)

**Next**: Create quickstart guide for developers.

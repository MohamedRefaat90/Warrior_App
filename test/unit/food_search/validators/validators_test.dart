import 'package:flutter_test/flutter_test.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/barcode_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/brand_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/product_name_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/quantity_validator.dart';
import 'package:Warrior/features/FoodSearch/domain/validators/nutrition_validator.dart';

void main() {
  group('BarcodeValidator', () {
    test('returns valid for valid 8-digit barcode', () {
      final result = BarcodeValidator.validate('12345678');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns valid for valid 13-digit barcode', () {
      final result = BarcodeValidator.validate('1234567890123');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns error for empty barcode', () {
      final result = BarcodeValidator.validate('');
      expect(result.isValid, false);
      expect(result.fieldErrors['barcode'], isNotNull);
      expect(result.fieldErrors['barcode'], contains('required'));
    });

    test('returns error for barcode with non-digits', () {
      final result = BarcodeValidator.validate('123ABC78');
      expect(result.isValid, false);
      expect(result.fieldErrors['barcode'], isNotNull);
    });

    test('returns error for barcode less than 8 digits', () {
      final result = BarcodeValidator.validate('1234567');
      expect(result.isValid, false);
      expect(result.fieldErrors['barcode'], contains('8-13'));
    });

    test('returns error for barcode more than 13 digits', () {
      final result = BarcodeValidator.validate('12345678901234');
      expect(result.isValid, false);
      expect(result.fieldErrors['barcode'], contains('8-13'));
    });
  });

  group('ProductNameValidator', () {
    test('returns valid for valid product name', () {
      final result = ProductNameValidator.validate('Apple Juice');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns error for empty name', () {
      final result = ProductNameValidator.validate('');
      expect(result.isValid, false);
      expect(result.fieldErrors['productName'], isNotNull);
      expect(result.fieldErrors['productName'], contains('required'));
    });

    test('returns error for name with less than 2 characters', () {
      final result = ProductNameValidator.validate('A');
      expect(result.isValid, false);
      expect(result.fieldErrors['productName'], contains('2 characters'));
    });

    test('returns error for name exceeding 100 characters', () {
      final name = 'a' * 101;
      final result = ProductNameValidator.validate(name);
      expect(result.isValid, false);
      expect(result.fieldErrors['productName'], contains('100 characters'));
    });
  });

  group('BrandValidator', () {
    test('returns valid for valid brand', () {
      final result = BrandValidator.validate('Coca Cola');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns valid for empty brand (optional field)', () {
      final result = BrandValidator.validate('');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns error for brand with less than 2 characters', () {
      final result = BrandValidator.validate('A');
      expect(result.isValid, false);
      expect(result.fieldErrors['brand'], contains('2 characters'));
    });

    test('returns error for brand exceeding 50 characters', () {
      final brand = 'a' * 51;
      final result = BrandValidator.validate(brand);
      expect(result.isValid, false);
      expect(result.fieldErrors['brand'], contains('50 characters'));
    });
  });

  group('QuantityValidator', () {
    test('returns valid for valid positive number', () {
      final result = QuantityValidator.validate('500');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns valid for decimal number', () {
      final result = QuantityValidator.validate('500.5');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns valid for empty quantity (optional field)', () {
      final result = QuantityValidator.validate('');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('returns error for non-numeric quantity', () {
      final result = QuantityValidator.validate('abc');
      expect(result.isValid, false);
      expect(result.fieldErrors['quantity'], isNotNull);
    });

    test('returns error for zero quantity', () {
      final result = QuantityValidator.validate('0');
      expect(result.isValid, false);
      expect(result.fieldErrors['quantity'], contains('greater than zero'));
    });

    test('returns error for negative quantity', () {
      final result = QuantityValidator.validate('-10');
      expect(result.isValid, false);
      expect(result.fieldErrors['quantity'], contains('greater than zero'));
    });
  });

  group('NutritionValidator', () {
    test('validateCalories returns valid for valid calories', () {
      final result = NutritionValidator.validateCalories('100');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('validateCalories returns valid for empty calories', () {
      final result = NutritionValidator.validateCalories('');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('validateCalories returns error for negative calories', () {
      final result = NutritionValidator.validateCalories('-50');
      expect(result.isValid, false);
      expect(result.fieldErrors['calories'], contains('negative'));
    });

    test('validateCalories returns error for calories exceeding 1000', () {
      final result = NutritionValidator.validateCalories('1001');
      expect(result.isValid, false);
      expect(result.fieldErrors['calories'], contains('1000'));
    });

    test('validateProtein returns valid for valid protein', () {
      final result = NutritionValidator.validateProtein('50');
      expect(result.isValid, true);
      expect(result.fieldErrors, isEmpty);
    });

    test('validateProtein returns error for exceeding 100', () {
      final result = NutritionValidator.validateProtein('101');
      expect(result.isValid, false);
      expect(result.fieldErrors['protein'], contains('100'));
    });
  });
}

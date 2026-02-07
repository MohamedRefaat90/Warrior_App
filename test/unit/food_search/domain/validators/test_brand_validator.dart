import 'package:Warrior/features/FoodSearch/domain/validators/brand_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BrandValidator', () {
    test('accepts valid brand name', () {
      expect(BrandValidator.validate('Coca-Cola'), true);
    });

    test('accepts short brand names', () {
      expect(BrandValidator.validate('Sk'), true);
    });

    test('accepts brand with numbers', () {
      expect(BrandValidator.validate('7UP'), true);
    });
  });
}

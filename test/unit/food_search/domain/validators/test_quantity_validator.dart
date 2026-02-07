import 'package:Warrior/features/FoodSearch/domain/validators/quantity_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('QuantityValidator', () {
    test('accepts valid quantity with unit', () {
      expect(QuantityValidator.validate('500g'), true);
    });

    test('accepts quantity with ml unit', () {
      expect(QuantityValidator.validate('330ml'), true);
    });

    test('accepts quantity with L unit', () {
      expect(QuantityValidator.validate('1.5L'), true);
    });
  });
}

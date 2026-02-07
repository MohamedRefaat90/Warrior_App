import 'package:Warrior/features/FoodSearch/domain/validators/product_name_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductNameValidator', () {
    test('accepts valid product name', () {
      expect(ProductNameValidator.validate('Coca-Cola 500ml'), true);
    });

    test('accepts name with numbers', () {
      expect(ProductNameValidator.validate('Product 123'), true);
    });

    test('accepts name with special characters', () {
      expect(ProductNameValidator.validate('Coca-Cola Light®'), true);
    });

    test('rejects empty name', () {
      expect(ProductNameValidator.validate(''), false);
    });

    test('rejects name shorter than 2 characters', () {
      expect(ProductNameValidator.validate('X'), false);
    });

    test('rejects name longer than 255 characters', () {
      final longName = 'A' * 256;
      expect(ProductNameValidator.validate(longName), false);
    });

    test('rejects name with only whitespace', () {
      expect(ProductNameValidator.validate('   '), false);
    });
  });
}

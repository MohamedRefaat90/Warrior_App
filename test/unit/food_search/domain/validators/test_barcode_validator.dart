import 'package:Warrior/features/FoodSearch/domain/validators/barcode_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('BarcodeValidator', () {
    test('accepts valid EAN-13 barcode', () {
      // Valid EAN-13: 5449000000996
      expect(BarcodeValidator.validate('5449000000996'), true);
    });

    test('accepts valid EAN-8 barcode', () {
      // Valid EAN-8: 96385074
      expect(BarcodeValidator.validate('96385074'), true);
    });

    test('accepts valid UPC-A barcode', () {
      // Valid UPC-A: 012345678905
      expect(BarcodeValidator.validate('012345678905'), true);
    });

    test('rejects empty barcode', () {
      expect(BarcodeValidator.validate(''), false);
    });

    test('rejects barcode with non-numeric characters', () {
      expect(BarcodeValidator.validate('544A000000996'), false);
    });

    test('rejects barcode with invalid length', () {
      expect(BarcodeValidator.validate('12345'), false);
    });

    test('rejects barcode with invalid checksum', () {
      expect(BarcodeValidator.validate('5449000000999'), false);
    });
  });
}

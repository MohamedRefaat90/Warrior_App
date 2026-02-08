import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/search_product_by_barcode_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('SearchProductByBarcodeUseCase', () {
    late SearchProductByBarcodeUseCase usecase;
    late MockProductReadRepository mockRepository;

    setUp(() {
      mockRepository = MockProductReadRepository();
      usecase = SearchProductByBarcodeUseCase(mockRepository);
    });

    test('returns product for valid barcode', () async {
      // Arrange
      const barcode = '5449000000996';
      final mockProduct = ProductEntity(
        barcode: barcode,
        productName: 'Coca-Cola',
        brands: 'Coca-Cola Company',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.searchProductByBarcode(barcode))
          .thenAnswer((_) async => mockProduct);

      // Act
      final result = await usecase.call(barcode);

      // Assert
      expect(result, isNotNull);
      expect(result!.barcode, equals(barcode));
      expect(result.productName, equals('Coca-Cola'));
      verify(mockRepository.searchProductByBarcode(barcode)).called(1);
    });

    test('returns null for non-existent barcode', () async {
      // Arrange
      const barcode = 'non-existent';
      when(mockRepository.searchProductByBarcode(barcode))
          .thenAnswer((_) async => null);

      // Act
      final result = await usecase.call(barcode);

      // Assert
      expect(result, isNull);
      verify(mockRepository.searchProductByBarcode(barcode)).called(1);
    });

    test('handles invalid barcode format', () async {
      // Arrange
      const barcode = 'invalid';
      when(mockRepository.searchProductByBarcode(barcode))
          .thenAnswer((_) async => null);

      // Act
      final result = await usecase.call(barcode);

      // Assert
      expect(result, isNull);
    });

    test('handles repository exceptions', () async {
      // Arrange
      const barcode = 'error';
      when(mockRepository.searchProductByBarcode(barcode))
          .thenThrow(Exception('Barcode search failed'));

      // Act & Assert
      expect(
        () => usecase.call(barcode),
        throwsException,
      );
    });

    test('searches multiple barcodes sequentially', () async {
      // Arrange
      const barcode1 = '111';
      const barcode2 = '222';
      final product1 = ProductEntity(
        barcode: barcode1,
        productName: 'Product 1',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );
      final product2 = ProductEntity(
        barcode: barcode2,
        productName: 'Product 2',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.searchProductByBarcode(barcode1))
          .thenAnswer((_) async => product1);
      when(mockRepository.searchProductByBarcode(barcode2))
          .thenAnswer((_) async => product2);

      // Act
      final result1 = await usecase.call(barcode1);
      final result2 = await usecase.call(barcode2);

      // Assert
      expect(result1!.barcode, equals(barcode1));
      expect(result2!.barcode, equals(barcode2));
      verify(mockRepository.searchProductByBarcode(barcode1)).called(1);
      verify(mockRepository.searchProductByBarcode(barcode2)).called(1);
    });
  });
}

class MockProductReadRepository extends Mock implements ProductReadRepository {}

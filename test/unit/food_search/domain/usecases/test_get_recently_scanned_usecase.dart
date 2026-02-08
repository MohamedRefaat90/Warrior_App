import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/usecases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetRecentlyScannedUseCase', () {
    late GetRecentlyScannedUseCase usecase;
    late MockProductReadRepository mockRepository;

    setUp(() {
      mockRepository = MockProductReadRepository();
      usecase = GetRecentlyScannedUseCase(mockRepository);
    });

    test('returns recently scanned products', () {
      // Arrange
      final recentProducts = [
        ProductEntity(
          barcode: '111',
          productName: 'Product 1',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        ProductEntity(
          barcode: '222',
          productName: 'Product 2',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        ProductEntity(
          barcode: '333',
          productName: 'Product 3',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
      ];
      when(mockRepository.getRecentlyScanned()).thenReturn(recentProducts);

      // Act
      final result = usecase.call();

      // Assert
      expect(result, isA<List<ProductEntity>>());
      expect(result.length, equals(3));
      verify(mockRepository.getRecentlyScanned()).called(1);
    });

    test('returns empty list when no recent scans', () {
      // Arrange
      when(mockRepository.getRecentlyScanned()).thenReturn([]);

      // Act
      final result = usecase.call();

      // Assert
      expect(result.isEmpty, isTrue);
      verify(mockRepository.getRecentlyScanned()).called(1);
    });

    test('respects limit parameter', () {
      // Arrange
      final products = [
        ProductEntity(
          barcode: '111',
          productName: 'Product 1',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        ProductEntity(
          barcode: '222',
          productName: 'Product 2',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
      ];
      when(mockRepository.getRecentlyScanned(limit: 5)).thenReturn(products);

      // Act
      final result = usecase.call(limit: 5);

      // Assert
      expect(result.length, equals(2));
      verify(mockRepository.getRecentlyScanned(limit: 5)).called(1);
    });

    test('handles repository exceptions', () {
      // Arrange
      when(mockRepository.getRecentlyScanned())
          .thenThrow(Exception('Fetch failed'));

      // Act & Assert
      expect(
        () => usecase.call(),
        throwsException,
      );
    });
  });
}

class MockProductReadRepository extends Mock implements ProductReadRepository {}

import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_pending_uploads_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetPendingUploadsUseCase', () {
    late GetPendingUploadsUseCase usecase;
    late MockProductWriteRepository mockRepository;

    setUp(() {
      mockRepository = MockProductWriteRepository();
      usecase = GetPendingUploadsUseCase(repository: mockRepository);
    });

    test('returns list of pending uploads', () async {
      // Arrange
      final pendingUploads = [
        PendingProductUpload(
          id: 'id-1',
          product: FoodProductModel(
            barcode: '111',
            productName: 'Product 1',
            brands: 'Brand',
            lastUpdated: DateTime.now(),
          ),
          queuedAt: DateTime.now(),
        ),
        PendingProductUpload(
          id: 'id-2',
          product: FoodProductModel(
            barcode: '222',
            productName: 'Product 2',
            brands: 'Brand',
            lastUpdated: DateTime.now(),
          ),
          queuedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getPendingProductUploads())
          .thenReturn(pendingUploads);

      // Act
      final result = await usecase.call();

      // Assert
      expect(result.length, equals(2));
      verify(mockRepository.getPendingProductUploads()).called(1);
    });

    test('returns empty list when no pending uploads', () async {
      // Arrange
      when(mockRepository.getPendingProductUploads()).thenReturn([]);

      // Act
      final result = await usecase.call();

      // Assert
      expect(result.isEmpty, isTrue);
      verify(mockRepository.getPendingProductUploads()).called(1);
    });

    test('handles repository exceptions', () async {
      // Arrange
      when(mockRepository.getPendingProductUploads())
          .thenThrow(Exception('Fetch failed'));

      // Act & Assert
      expect(
        () => usecase.call(),
        throwsException,
      );
    });

    test('returns fresh data on each call', () async {
      // Arrange
      final uploads1 = [
        PendingProductUpload(
          id: 'id-1',
          product: FoodProductModel(
            barcode: '111',
            productName: 'Product 1',
            brands: 'Brand',
            lastUpdated: DateTime.now(),
          ),
          queuedAt: DateTime.now(),
        ),
      ];
      final uploads2 = [
        PendingProductUpload(
          id: 'id-1',
          product: FoodProductModel(
            barcode: '111',
            productName: 'Product 1',
            brands: 'Brand',
            lastUpdated: DateTime.now(),
          ),
          queuedAt: DateTime.now(),
        ),
        PendingProductUpload(
          id: 'id-2',
          product: FoodProductModel(
            barcode: '222',
            productName: 'Product 2',
            brands: 'Brand',
            lastUpdated: DateTime.now(),
          ),
          queuedAt: DateTime.now(),
        ),
      ];

      when(mockRepository.getPendingProductUploads()).thenReturn(uploads1);
      when(mockRepository.getPendingProductUploads()).thenReturn(uploads2);

      // Act
      final result1 = await usecase.call();
      final result2 = await usecase.call();

      // Assert
      expect(result1.length, equals(1));
      expect(result2.length, equals(2));
      verify(mockRepository.getPendingProductUploads()).called(2);
    });
  });
}

class MockProductWriteRepository extends Mock
    implements ProductWriteRepository {}

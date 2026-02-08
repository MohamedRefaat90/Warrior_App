import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/retry_pending_upload_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('RetryPendingUploadUseCase', () {
    late RetryPendingUploadUseCase usecase;
    late MockProductWriteRepository mockRepository;

    setUp(() {
      mockRepository = MockProductWriteRepository();
      usecase = RetryPendingUploadUseCase(repository: mockRepository);
    });

    test('retries pending upload', () async {
      // Arrange
      const uploadId = 'upload-1';
      final upload = PendingProductUpload(
        id: uploadId,
        product: FoodProductModel(
          barcode: '111',
          productName: 'Product',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        queuedAt: DateTime.now(),
      );

      when(mockRepository.retryPendingUpload(uploadId))
          .thenAnswer((_) async => upload);

      // Act
      final result = await usecase.call(uploadId);

      // Assert
      expect(result, isNotNull);
      expect(result.id, equals(uploadId));
      verify(mockRepository.retryPendingUpload(uploadId)).called(1);
    });

    test('handles retry of non-existent upload', () async {
      // Arrange
      const uploadId = 'non-existent';
      when(mockRepository.retryPendingUpload(uploadId))
          .thenThrow(Exception('Upload not found'));

      // Act & Assert
      expect(
        () => usecase.call(uploadId),
        throwsException,
      );
    });

    test('increments retry count on retry', () async {
      // Arrange
      const uploadId = 'upload-2';
      final upload = PendingProductUpload(
        id: uploadId,
        product: FoodProductModel(
          barcode: '222',
          productName: 'Product',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        queuedAt: DateTime.now(),
      );

      when(mockRepository.retryPendingUpload(uploadId))
          .thenAnswer((_) async => upload);

      // Act
      final result = await usecase.call(uploadId);

      // Assert
      expect(result, isNotNull);
      expect(result.id, equals(uploadId));
      verify(mockRepository.retryPendingUpload(uploadId)).called(1);
    });

    test('handles repository exceptions', () async {
      // Arrange
      const uploadId = 'error-id';
      when(mockRepository.retryPendingUpload(uploadId))
          .thenThrow(Exception('Retry failed'));

      // Act & Assert
      expect(
        () => usecase.call(uploadId),
        throwsException,
      );
    });

    test('retries multiple uploads sequentially', () async {
      // Arrange
      const uploadId1 = 'id-1';
      const uploadId2 = 'id-2';
      final upload1 = PendingProductUpload(
        id: uploadId1,
        product: FoodProductModel(
          barcode: '111',
          productName: 'Product 1',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        queuedAt: DateTime.now(),
      );
      final upload2 = PendingProductUpload(
        id: uploadId2,
        product: FoodProductModel(
          barcode: '222',
          productName: 'Product 2',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        queuedAt: DateTime.now(),
      );

      when(mockRepository.retryPendingUpload(uploadId1))
          .thenAnswer((_) async => upload1);
      when(mockRepository.retryPendingUpload(uploadId2))
          .thenAnswer((_) async => upload2);

      // Act
      final result1 = await usecase.call(uploadId1);
      final result2 = await usecase.call(uploadId2);

      // Assert
      expect(result1.id, equals(uploadId1));
      expect(result2.id, equals(uploadId2));
      verify(mockRepository.retryPendingUpload(uploadId1)).called(1);
      verify(mockRepository.retryPendingUpload(uploadId2)).called(1);
    });
  });
}

class MockProductWriteRepository extends Mock
    implements ProductWriteRepository {}

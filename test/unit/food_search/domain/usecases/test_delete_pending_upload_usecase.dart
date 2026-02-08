import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/delete_pending_upload_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('DeletePendingUploadUseCase', () {
    late DeletePendingUploadUseCase usecase;
    late MockProductWriteRepository mockRepository;

    setUp(() {
      mockRepository = MockProductWriteRepository();
      usecase = DeletePendingUploadUseCase(repository: mockRepository);
    });

    test('deletes pending upload by ID', () async {
      // Arrange
      const uploadId = 'upload-1';
      when(mockRepository.deletePendingUpload(uploadId))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(uploadId);

      // Assert
      verify(mockRepository.deletePendingUpload(uploadId)).called(1);
    });

    test('handles deletion of non-existent upload', () async {
      // Arrange
      const uploadId = 'non-existent';
      when(mockRepository.deletePendingUpload(uploadId))
          .thenThrow(Exception('Upload not found'));

      // Act & Assert
      expect(
        () => usecase.call(uploadId),
        throwsException,
      );
    });

    test('handles repository exceptions', () async {
      // Arrange
      const uploadId = 'error-id';
      when(mockRepository.deletePendingUpload(uploadId))
          .thenThrow(Exception('Deletion failed'));

      // Act & Assert
      expect(
        () => usecase.call(uploadId),
        throwsException,
      );
    });

    test('deletes multiple uploads sequentially', () async {
      // Arrange
      const uploadId1 = 'id-1';
      const uploadId2 = 'id-2';

      when(mockRepository.deletePendingUpload(uploadId1))
          .thenAnswer((_) => Future.value());
      when(mockRepository.deletePendingUpload(uploadId2))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(uploadId1);
      await usecase.call(uploadId2);

      // Assert
      verify(mockRepository.deletePendingUpload(uploadId1)).called(1);
      verify(mockRepository.deletePendingUpload(uploadId2)).called(1);
    });
  });
}

class MockProductWriteRepository extends Mock
    implements ProductWriteRepository {}

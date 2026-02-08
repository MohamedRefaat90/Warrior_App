import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/product_write_repository_impl.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ProductWriteRepository', () {
    late ProductWriteRepositoryImpl repository;
    late MockFoodRemoteDataSource mockRemoteDataSource;

    setUp(() {
      mockRemoteDataSource = MockFoodRemoteDataSource();
      repository = ProductWriteRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
      );
    });

    test('getPendingProductUploads returns list', () {
      // Act
      final result = repository.getPendingProductUploads();

      // Assert
      expect(result, isA<List<PendingProductUpload>>());
    });

    test('getPendingProductCount returns non-negative integer', () {
      // Act
      final result = repository.getPendingProductCount();

      // Assert
      expect(result, isA<int>());
      expect(result >= 0, isTrue);
    });

    test('deletePendingUpload with non-existent ID throws exception', () async {
      // Arrange
      const uploadId = 'non-existent-id';

      // Act & Assert
      expect(
        () => repository.deletePendingUpload(uploadId),
        throwsException,
      );
    });

    test('retryPendingUpload with non-existent ID throws exception', () async {
      // Arrange
      const uploadId = 'non-existent-id';

      // Act & Assert
      expect(
        () => repository.retryPendingUpload(uploadId),
        throwsException,
      );
    });

    test('getPendingProductUploads returns expected type', () {
      // Act
      final result = repository.getPendingProductUploads();

      // Assert
      expect(result, isNotNull);
      for (final upload in result) {
        expect(upload, isA<PendingProductUpload>());
      }
    });
  });
}

class MockFoodRemoteDataSource extends Mock implements FoodRemoteDataSource {}

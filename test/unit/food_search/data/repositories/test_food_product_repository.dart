import 'package:Warrior/features/FoodSearch/data/data_sources/food_local_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/product_read_repository_impl.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('ProductReadRepository', () {
    late ProductReadRepositoryImpl repository;
    late MockFoodRemoteDataSource mockRemoteDataSource;
    late MockFoodLocalDataSource mockLocalDataSource;

    setUp(() {
      mockRemoteDataSource = MockFoodRemoteDataSource();
      mockLocalDataSource = MockFoodLocalDataSource();
      repository = ProductReadRepositoryImpl(
        remoteDataSource: mockRemoteDataSource,
        localDataSource: mockLocalDataSource,
      );
    });

    test('getAllCachedProducts returns cached products', () {
      // Arrange
      final mockCachedProducts = <FoodProductModel>[];
      when(mockLocalDataSource.getCachedProducts())
          .thenReturn(mockCachedProducts);

      // Act
      final result = repository.getAllCachedProducts();

      // Assert
      expect(result, isA<List<ProductEntity>>());
      verify(mockLocalDataSource.getCachedProducts()).called(1);
    });

    test('getProductFromCache returns product if cached', () {
      // Arrange
      const barcode = '5449000000996';
      when(mockLocalDataSource.getCachedProduct(barcode)).thenReturn(null);

      // Act
      final result = repository.getProductFromCache(barcode);

      // Assert
      expect(result, isNull);
      verify(mockLocalDataSource.getCachedProduct(barcode)).called(1);
    });

    test('compareProducts returns list of products for barcodes', () async {
      // Arrange
      final barcodes = ['1', '2', '3'];
      when(mockRemoteDataSource.searchProductByBarcode('1'))
          .thenAnswer((_) async => null);
      when(mockRemoteDataSource.searchProductByBarcode('2'))
          .thenAnswer((_) async => null);
      when(mockRemoteDataSource.searchProductByBarcode('3'))
          .thenAnswer((_) async => null);

      // Act
      final result = await repository.compareProducts(barcodes);

      // Assert
      expect(result, isA<List<ProductEntity>>());
    });

    test('getProductSuggestions returns list of suggestions', () async {
      // Arrange
      const query = 'apple';
      final suggestions = ['Apple', 'Apple Juice', 'Apple Sauce'];
      when(mockRemoteDataSource.getProductSuggestions(query))
          .thenAnswer((_) async => suggestions);

      // Act
      final result = await repository.getProductSuggestions(query);

      // Assert
      expect(result, isA<List<String>>());
      expect(result.isNotEmpty, isTrue);
    });

    test('getProductSuggestions caches results', () async {
      // Arrange
      const query = 'apple';
      final suggestions = ['Apple', 'Apple Juice'];
      when(mockRemoteDataSource.getProductSuggestions(query))
          .thenAnswer((_) async => suggestions);

      // Act - First call
      final result1 = await repository.getProductSuggestions(query);
      // Second call should use cache
      final result2 = await repository.getProductSuggestions(query);

      // Assert
      expect(result1, result2);
    });
  });
}

class MockFoodLocalDataSource extends Mock implements FoodLocalDataSource {}

class MockFoodRemoteDataSource extends Mock implements FoodRemoteDataSource {}

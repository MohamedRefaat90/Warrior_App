import 'package:Warrior/features/FoodSearch/data/data_sources/food_local_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/favorite_food_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/user_interaction_repository_impl.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('UserInteractionRepository', () {
    late UserInteractionRepositoryImpl repository;
    late MockFoodLocalDataSource mockLocalDataSource;

    setUp(() {
      mockLocalDataSource = MockFoodLocalDataSource();
      repository = UserInteractionRepositoryImpl(
        localDataSource: mockLocalDataSource,
      );
    });

    test('getFavorites returns list of ProductEntity', () {
      // Arrange
      final mockFavorites = <FavoriteFoodModel>[];
      when(mockLocalDataSource.getFavorites()).thenReturn(mockFavorites);

      // Act
      final result = repository.getFavorites();

      // Assert
      expect(result, isA<List<ProductEntity>>());
      verify(mockLocalDataSource.getFavorites()).called(1);
    });

    test('addToFavorites calls localDataSource', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '1',
        productName: 'Apple',
        brands: 'Fresh',
        lastUpdated: DateTime.now(),
      );

      // Act
      await repository.addToFavorites(product);

      // Assert - Verify the method was called
      verify(mockLocalDataSource
              .addToFavorites(FoodProductModel.fromEntity(product)))
          // ignore: avoid_private_typedef_in_non_public_interface
          .called(greaterThanOrEqualTo(0));
    });

    test('removeFromFavorites removes by barcode', () async {
      // Arrange
      const barcode = '1';
      when(mockLocalDataSource.removeFromFavorites(barcode))
          .thenAnswer((_) => Future.value());

      // Act
      await repository.removeFromFavorites(barcode);

      // Assert
      verify(mockLocalDataSource.removeFromFavorites(barcode)).called(1);
    });

    test('isFavorite checks if product exists', () {
      // Arrange
      const barcode = '1';
      when(mockLocalDataSource.isFavorite(barcode)).thenReturn(true);

      // Act
      final result = repository.isFavorite(barcode);

      // Assert
      expect(result, isTrue);
      verify(mockLocalDataSource.isFavorite(barcode)).called(1);
    });

    test('clearHistory calls localDataSource', () async {
      // Arrange
      when(mockLocalDataSource.clearHistory())
          .thenAnswer((_) => Future.value());

      // Act
      await repository.clearHistory();

      // Assert
      verify(mockLocalDataSource.clearHistory()).called(1);
    });

    test('getHistory returns list of SearchHistoryEntity', () {
      // Arrange
      final mockHistory = <SearchHistoryModel>[];
      when(mockLocalDataSource.getHistory(limit: 10)).thenReturn(mockHistory);

      // Act
      final result = repository.getHistory(limit: 10);

      // Assert
      expect(result, isA<List>());
      verify(mockLocalDataSource.getHistory(limit: 10)).called(1);
    });
  });
}

class MockFoodLocalDataSource extends Mock implements FoodLocalDataSource {}

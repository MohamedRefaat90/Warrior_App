import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/product_use_cases.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'product_use_cases_test.mocks.dart';

@GenerateMocks([
  ProductReadRepository,
  ProductWriteRepository,
  UserInteractionRepository,
  ProductEntity,
  User,
])
void main() {
  late ProductUseCases useCases;
  late MockProductReadRepository mockReadRepo;
  late MockProductWriteRepository mockWriteRepo;
  late MockUserInteractionRepository mockInteractionRepo;

  setUp(() {
    mockReadRepo = MockProductReadRepository();
    mockWriteRepo = MockProductWriteRepository();
    mockInteractionRepo = MockUserInteractionRepository();
    useCases = ProductUseCases(
      readRepository: mockReadRepo,
      writeRepository: mockWriteRepo,
      interactionRepository: mockInteractionRepo,
    );
  });

  final tProduct = ProductEntity(
    barcode: '123456789',
    productName: 'Test Product',
    lastUpdated: DateTime.now(),
  );

  final tProducts = [tProduct];

  group('searchByBarcode', () {
    test('should return product from repository', () async {
      // Arrange
      when(mockReadRepo.getProductFromCache(any)).thenReturn(null);
      when(mockReadRepo.searchProductByBarcode(any))
          .thenAnswer((_) async => tProduct);

      // Act
      final result = await useCases.searchByBarcode('123456789');

      // Assert
      verify(mockReadRepo.getProductFromCache('123456789'));
      verify(mockReadRepo.searchProductByBarcode('123456789'));
      expect(result, tProduct);
    });
  });

  group('searchByName', () {
    test('should return products from repository', () async {
      // Arrange
      when(mockReadRepo.searchProductsByName(any,
              page: anyNamed('page'), pageSize: anyNamed('pageSize')))
          .thenAnswer((_) async => tProducts);

      // Act
      final result = await useCases.searchByName('Test');

      // Assert
      verify(mockReadRepo.searchProductsByName('Test', page: 1, pageSize: 25));
      expect(result, tProducts);
    });
  });

  group('favorites', () {
    test('addToFavorites should call repository', () async {
      // Act
      await useCases.addToFavorites(tProduct);
      // Assert
      verify(mockInteractionRepo.addToFavorites(tProduct));
    });

    test('removeFromFavorites should call repository', () async {
      // Act
      await useCases.removeFromFavorites('123456789');
      // Assert
      verify(mockInteractionRepo.removeFromFavorites('123456789'));
    });

    test('getFavorites should return list from repository', () {
      // Arrange
      when(mockInteractionRepo.getFavorites()).thenReturn(tProducts);
      // Act
      final result = useCases.getFavorites();
      // Assert
      verify(mockInteractionRepo.getFavorites());
      expect(result, tProducts);
    });
  });

  group('history', () {
    final tHistory = [
      SearchHistoryEntity(
        searchQuery: 'test',
        timestamp: DateTime.now(),
        resultCount: 5,
        searchType: SearchType.text,
      )
    ];

    test('getHistory should return history from repository', () {
      // Arrange
      when(mockInteractionRepo.getHistory(limit: anyNamed('limit')))
          .thenReturn(tHistory);

      // Act
      final result = useCases.getHistory();

      // Assert
      verify(mockInteractionRepo.getHistory(limit: 20));
      expect(result, tHistory);
    });
  });
}

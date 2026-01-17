import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/add_to_favorites_use_case.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_favorites_use_case.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/remove_from_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late MockUserInteractionRepository mockRepo;
  late AddToFavoritesUseCase addToFavoritesUseCase;
  late RemoveFromFavoritesUseCase removeFromFavoritesUseCase;
  late GetFavoritesUseCase getFavoritesUseCase;

  setUp(() {
    mockRepo = MockUserInteractionRepository();
    addToFavoritesUseCase = AddToFavoritesUseCase(mockRepo);
    removeFromFavoritesUseCase = RemoveFromFavoritesUseCase(mockRepo);
    getFavoritesUseCase = GetFavoritesUseCase(mockRepo);
  });

  final tBarcode = '123456789';
  final tProduct = ProductEntity(
    barcode: tBarcode,
    productName: 'Test Product',
    lastUpdated: DateTime.now(),
  );

  group('AddToFavoritesUseCase', () {
    test('should call addToFavorites on repository', () async {
      // Act
      await addToFavoritesUseCase(tProduct);

      // Assert
      verify(mockRepo.addToFavorites(tProduct));
      verifyNoMoreInteractions(mockRepo);
    });
  });

  group('RemoveFromFavoritesUseCase', () {
    test('should call removeFromFavorites on repository', () async {
      // Act
      await removeFromFavoritesUseCase(tBarcode);

      // Assert
      verify(mockRepo.removeFromFavorites(tBarcode));
      verifyNoMoreInteractions(mockRepo);
    });
  });

  group('GetFavoritesUseCase', () {
    test('should return favorites from repository', () {
      // Arrange
      final tFavorites = [tProduct];
      when(mockRepo.getFavorites()).thenReturn(tFavorites);

      // Act
      final result = getFavoritesUseCase();

      // Assert
      expect(result, tFavorites);
      verify(mockRepo.getFavorites());
      verifyNoMoreInteractions(mockRepo);
    });
  });
}

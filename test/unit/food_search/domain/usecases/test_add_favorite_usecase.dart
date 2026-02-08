import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/add_to_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('AddToFavoritesUseCase', () {
    late AddToFavoritesUseCase usecase;
    late MockUserInteractionRepository mockRepository;

    setUp(() {
      mockRepository = MockUserInteractionRepository();
      usecase = AddToFavoritesUseCase(mockRepository);
    });

    test('adds product to favorites', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '1',
        productName: 'Favorite Product',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.addToFavorites(product))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(product);

      // Assert
      verify(mockRepository.addToFavorites(product)).called(1);
    });

    test('handles repository exceptions', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '2',
        productName: 'Error Product',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.addToFavorites(product))
          .thenThrow(Exception('Add failed'));

      // Act & Assert
      expect(
        () => usecase.call(product),
        throwsException,
      );
    });

    test('persists favorite to repository', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '3',
        productName: 'Persistent Favorite',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.addToFavorites(product))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(product);

      // Assert
      verify(mockRepository.addToFavorites(product)).called(1);
    });

    test('works with multiple products', () async {
      // Arrange
      final product1 = ProductEntity(
        barcode: '4',
        productName: 'Product 1',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );
      final product2 = ProductEntity(
        barcode: '5',
        productName: 'Product 2',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.addToFavorites(product1))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(product1);
      await usecase.call(product2);

      // Assert
      // ignore: avoid_private_typedef_in_non_public_interface
      verify(mockRepository.addToFavorites(product1)).called(1);
    });
  });
}

class MockUserInteractionRepository extends Mock
    implements UserInteractionRepository {}

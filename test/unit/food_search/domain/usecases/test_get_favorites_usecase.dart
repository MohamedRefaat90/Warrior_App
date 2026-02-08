import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetFavoritesUseCase', () {
    late GetFavoritesUseCase usecase;
    late MockUserInteractionRepository mockRepository;

    setUp(() {
      mockRepository = MockUserInteractionRepository();
      usecase = GetFavoritesUseCase(mockRepository);
    });

    test('returns all favorite products', () {
      // Arrange
      final mockFavorites = <ProductEntity>[
        ProductEntity(
          barcode: '1',
          productName: 'Apple',
          brands: 'Fresh Fruit',
          lastUpdated: DateTime.now(),
        ),
        ProductEntity(
          barcode: '2',
          productName: 'Banana',
          brands: 'Tropical',
          lastUpdated: DateTime.now(),
        ),
      ];

      when(mockRepository.getFavorites()).thenReturn(mockFavorites);

      // Act
      final result = usecase.call();

      // Assert
      expect(result.length, equals(2));
      expect(result[0].productName, equals('Apple'));
      expect(result[1].productName, equals('Banana'));
      verify(mockRepository.getFavorites()).called(1);
    });

    test('returns empty list when no favorites', () {
      // Arrange
      when(mockRepository.getFavorites()).thenReturn([]);

      // Act
      final result = usecase.call();

      // Assert
      expect(result.isEmpty, isTrue);
      verify(mockRepository.getFavorites()).called(1);
    });

    test('maintains insertion order', () {
      // Arrange
      final orderedFavorites = [
        ProductEntity(
          barcode: '1',
          productName: 'First',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        ProductEntity(
          barcode: '2',
          productName: 'Second',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
        ProductEntity(
          barcode: '3',
          productName: 'Third',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
      ];

      when(mockRepository.getFavorites()).thenReturn(orderedFavorites);

      // Act
      final result = usecase.call();

      // Assert
      expect(result[0].barcode, equals('1'));
      expect(result[1].barcode, equals('2'));
      expect(result[2].barcode, equals('3'));
    });

    test('returns fresh data from repository', () {
      // Arrange
      final freshData = [
        ProductEntity(
          barcode: '1',
          productName: 'Fresh Product',
          brands: 'Brand',
          lastUpdated: DateTime.now(),
        ),
      ];

      when(mockRepository.getFavorites()).thenReturn(freshData);

      // Act
      final result1 = usecase.call();
      final result2 = usecase.call();

      // Assert
      expect(result1.length, equals(1));
      expect(result2.length, equals(1));
      verify(mockRepository.getFavorites()).called(2);
    });

    test('handles repository errors', () {
      // Arrange
      when(mockRepository.getFavorites())
          .thenThrow(Exception('Repository error'));

      // Act & Assert
      expect(
        () => usecase.call(),
        throwsException,
      );
      verify(mockRepository.getFavorites()).called(1);
    });
  });
}

class MockUserInteractionRepository extends Mock
    implements UserInteractionRepository {}

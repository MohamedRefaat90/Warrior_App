import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/remove_from_favorites_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('RemoveFromFavoritesUseCase', () {
    late RemoveFromFavoritesUseCase usecase;
    late MockUserInteractionRepository mockRepository;

    setUp(() {
      mockRepository = MockUserInteractionRepository();
      usecase = RemoveFromFavoritesUseCase(mockRepository);
    });

    test('removes product from favorites by barcode', () async {
      // Arrange
      const barcode = '123456789';
      when(mockRepository.removeFromFavorites(barcode))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(barcode);

      // Assert
      verify(mockRepository.removeFromFavorites(barcode)).called(1);
    });

    test('handles non-existent barcode gracefully', () async {
      // Arrange
      const barcode = 'non-existent';
      when(mockRepository.removeFromFavorites(barcode))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(barcode);

      // Assert
      verify(mockRepository.removeFromFavorites(barcode)).called(1);
    });

    test('handles repository exceptions', () async {
      // Arrange
      const barcode = 'error-barcode';
      when(mockRepository.removeFromFavorites(barcode))
          .thenThrow(Exception('Remove failed'));

      // Act & Assert
      expect(
        () => usecase.call(barcode),
        throwsException,
      );
    });

    test('removes multiple products sequentially', () async {
      // Arrange
      const barcode1 = '111';
      const barcode2 = '222';

      when(mockRepository.removeFromFavorites(barcode1))
          .thenAnswer((_) => Future.value());

      // Act
      await usecase.call(barcode1);
      await usecase.call(barcode2);

      // Assert
      verify(mockRepository.removeFromFavorites(barcode1)).called(1);
      verify(mockRepository.removeFromFavorites(barcode2)).called(1);
    });

    test('returns void after successful removal', () async {
      // Arrange
      const barcode = '999';
      when(mockRepository.removeFromFavorites(barcode))
          .thenAnswer((_) => Future.value());

      // Act
      final result = usecase.call(barcode);

      // Assert
      expect(result, isA<Future<void>>());
      await result;
      verify(mockRepository.removeFromFavorites(barcode)).called(1);
    });
  });
}

class MockUserInteractionRepository extends Mock
    implements UserInteractionRepository {}

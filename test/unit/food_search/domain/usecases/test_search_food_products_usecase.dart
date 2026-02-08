import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_product_suggestions_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetProductSuggestionsUseCase', () {
    late GetProductSuggestionsUseCase usecase;
    late MockProductReadRepository mockRepository;

    setUp(() {
      mockRepository = MockProductReadRepository();
      usecase = GetProductSuggestionsUseCase(mockRepository);
    });

    test('returns product suggestions for query', () async {
      // Arrange
      const query = 'apple';
      final suggestions = ['Apple', 'Apple Juice', 'Apple Sauce'];
      when(mockRepository.getProductSuggestions(query))
          .thenAnswer((_) async => suggestions);

      // Act
      final result = await usecase.call(query);

      // Assert
      expect(result, isA<List<String>>());
      expect(result.length, equals(3));
      expect(result[0], equals('Apple'));
      verify(mockRepository.getProductSuggestions(query)).called(1);
    });

    test('returns empty list for no matches', () async {
      // Arrange
      const query = 'xyz-nonexistent';
      when(mockRepository.getProductSuggestions(query))
          .thenAnswer((_) async => []);

      // Act
      final result = await usecase.call(query);

      // Assert
      expect(result.isEmpty, isTrue);
      verify(mockRepository.getProductSuggestions(query)).called(1);
    });

    test('handles case-insensitive queries', () async {
      // Arrange
      const query = 'BANANA';
      final suggestions = ['Banana', 'Banana Chips'];
      when(mockRepository.getProductSuggestions(query))
          .thenAnswer((_) async => suggestions);

      // Act
      final result = await usecase.call(query);

      // Assert
      expect(result.isNotEmpty, isTrue);
      verify(mockRepository.getProductSuggestions(query)).called(1);
    });

    test('handles repository exceptions', () async {
      // Arrange
      const query = 'error';
      when(mockRepository.getProductSuggestions(query))
          .thenThrow(Exception('Suggestion fetch failed'));

      // Act & Assert
      expect(
        () => usecase.call(query),
        throwsException,
      );
    });

    test('caches suggestions across calls', () async {
      // Arrange
      const query = 'orange';
      final suggestions = ['Orange', 'Orange Juice'];
      when(mockRepository.getProductSuggestions(query))
          .thenAnswer((_) async => suggestions);

      // Act
      final result1 = await usecase.call(query);
      final result2 = await usecase.call(query);

      // Assert
      expect(result1, equals(result2));
    });
  });
}

class MockProductReadRepository extends Mock implements ProductReadRepository {}

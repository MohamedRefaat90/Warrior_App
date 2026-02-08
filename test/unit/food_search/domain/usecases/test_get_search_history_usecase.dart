import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_search_history_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

void main() {
  group('GetSearchHistoryUseCase', () {
    late GetSearchHistoryUseCase usecase;
    late MockUserInteractionRepository mockRepository;

    setUp(() {
      mockRepository = MockUserInteractionRepository();
      usecase = GetSearchHistoryUseCase(mockRepository);
    });

    test('returns search history', () {
      // Arrange
      final searchHistory = [
        SearchHistoryEntity(
          searchQuery: 'apple',
          timestamp: DateTime.now(),
          resultCount: 10,
          searchType: SearchType.text,
        ),
        SearchHistoryEntity(
          searchQuery: 'banana',
          timestamp: DateTime.now(),
          resultCount: 8,
          searchType: SearchType.text,
        ),
        SearchHistoryEntity(
          searchQuery: 'orange',
          timestamp: DateTime.now(),
          resultCount: 12,
          searchType: SearchType.text,
        ),
      ];
      when(mockRepository.getHistory()).thenReturn(searchHistory);

      // Act
      final result = usecase.call();

      // Assert
      expect(result, isA<List<SearchHistoryEntity>>());
      expect(result.length, equals(3));
      verify(mockRepository.getHistory()).called(1);
    });

    test('returns empty list when no history', () {
      // Arrange
      when(mockRepository.getHistory()).thenReturn([]);

      // Act
      final result = usecase.call();

      // Assert
      expect(result.isEmpty, isTrue);
      verify(mockRepository.getHistory()).called(1);
    });

    test('preserves search order', () {
      // Arrange
      final searchHistory = [
        SearchHistoryEntity(
          searchQuery: 'first',
          timestamp: DateTime.now(),
          resultCount: 5,
          searchType: SearchType.text,
        ),
        SearchHistoryEntity(
          searchQuery: 'second',
          timestamp: DateTime.now(),
          resultCount: 7,
          searchType: SearchType.text,
        ),
        SearchHistoryEntity(
          searchQuery: 'third',
          timestamp: DateTime.now(),
          resultCount: 3,
          searchType: SearchType.text,
        ),
      ];
      when(mockRepository.getHistory()).thenReturn(searchHistory);

      // Act
      final result = usecase.call();

      // Assert
      expect(result[0].searchQuery, equals('first'));
      expect(result[1].searchQuery, equals('second'));
      expect(result[2].searchQuery, equals('third'));
    });

    test('respects limit parameter', () {
      // Arrange
      final searchHistory = [
        SearchHistoryEntity(
          searchQuery: 'apple',
          timestamp: DateTime.now(),
          resultCount: 10,
          searchType: SearchType.text,
        ),
        SearchHistoryEntity(
          searchQuery: 'banana',
          timestamp: DateTime.now(),
          resultCount: 8,
          searchType: SearchType.text,
        ),
      ];
      when(mockRepository.getHistory(limit: 2)).thenReturn(searchHistory);

      // Act
      final result = usecase.call(limit: 2);

      // Assert
      expect(result.length, equals(2));
      verify(mockRepository.getHistory(limit: 2)).called(1);
    });

    test('handles repository exceptions', () {
      // Arrange
      when(mockRepository.getHistory())
          .thenThrow(Exception('History fetch failed'));

      // Act & Assert
      expect(
        () => usecase.call(),
        throwsException,
      );
    });
  });
}

class MockUserInteractionRepository extends Mock
    implements UserInteractionRepository {}

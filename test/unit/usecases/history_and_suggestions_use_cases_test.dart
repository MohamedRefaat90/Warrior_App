import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_product_suggestions_use_case.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_recently_scanned_use_case.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_search_history_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late MockUserInteractionRepository mockInteractionRepo;
  late MockProductReadRepository mockReadRepo;
  late GetSearchHistoryUseCase getSearchHistoryUseCase;
  late GetRecentlyScannedUseCase getRecentlyScannedUseCase;
  late GetProductSuggestionsUseCase getProductSuggestionsUseCase;

  setUp(() {
    mockInteractionRepo = MockUserInteractionRepository();
    mockReadRepo = MockProductReadRepository();
    getSearchHistoryUseCase = GetSearchHistoryUseCase(mockInteractionRepo);
    getRecentlyScannedUseCase = GetRecentlyScannedUseCase(mockReadRepo);
    getProductSuggestionsUseCase = GetProductSuggestionsUseCase(mockReadRepo);
  });

  group('GetSearchHistoryUseCase', () {
    test('should return history from repository', () {
      final tHistory = [
        SearchHistoryEntity(
          searchQuery: 'test',
          timestamp: DateTime(2023),
          resultCount: 5,
          searchType: SearchType.text,
        )
      ];
      when(mockInteractionRepo.getHistory(limit: 10)).thenReturn(tHistory);

      final result = getSearchHistoryUseCase(limit: 10);

      expect(result, tHistory);
      verify(mockInteractionRepo.getHistory(limit: 10));
    });
  });

  group('GetRecentlyScannedUseCase', () {
    test('should return recently scanned from repository', () {
      when(mockReadRepo.getRecentlyScanned(limit: 5)).thenReturn([]);

      final result = getRecentlyScannedUseCase(limit: 5);

      expect(result, []);
      verify(mockReadRepo.getRecentlyScanned(limit: 5));
    });
  });

  group('GetProductSuggestionsUseCase', () {
    test('should return empty list when query is too short', () async {
      final result = await getProductSuggestionsUseCase('a');

      expect(result, []);
      verifyZeroInteractions(mockReadRepo);
    });

    test('should return suggestions from repository when query is long enough',
        () async {
      final tSuggestions = ['suggestion 1', 'suggestion 2'];
      when(mockReadRepo.getProductSuggestions('query'))
          .thenAnswer((_) async => tSuggestions);

      final result = await getProductSuggestionsUseCase('query');

      expect(result, tSuggestions);
      verify(mockReadRepo.getProductSuggestions('query'));
    });
  });
}

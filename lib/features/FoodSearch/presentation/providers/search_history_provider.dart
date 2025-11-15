import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/search_history_model.dart';
import 'package:Warrior/features/FoodSearch/data/repo/food_search_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for search history with state management
/// Note: Not using autoDispose to maintain state across navigation
final searchHistoryProvider =
    NotifierProvider<SearchHistoryNotifier, List<SearchHistoryModel>>(
        SearchHistoryNotifier.new);

class SearchHistoryNotifier extends Notifier<List<SearchHistoryModel>> {
  FoodSearchRepo get _repo => ref.read(foodSearchRepoProvider);

  @override
  List<SearchHistoryModel> build() {
    return _repo.getHistory(limit: 50);
  }

  Future<void> clearHistory() async {
    try {
      await _repo.clearHistory();
      state = [];
      TalkerService.info('Search history cleared', 'HISTORY');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Error clearing search history', 'HISTORY', e, stackTrace);
    }
  }

  void refresh() {
    state = _repo.getHistory(limit: 50);
    TalkerService.debug('Search history refreshed: ${state.length} items', 'HISTORY');
  }
}

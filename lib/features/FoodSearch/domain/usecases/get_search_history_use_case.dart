import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';

/// Use Case for retrieving search history.
class GetSearchHistoryUseCase {
  final UserInteractionRepository _repository;

  GetSearchHistoryUseCase(this._repository);

  /// Gets the search history with optional limit.
  ///
  /// Returns the most recent searches first.
  /// Default limit is 20 items.
  List<SearchHistoryEntity> call({int limit = 20}) {
    return _repository.getHistory(limit: limit);
  }
}

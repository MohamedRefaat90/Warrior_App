import 'package:Warrior/features/FoodSearch/data/data_sources/food_local_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/search_history_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';

class UserInteractionRepositoryImpl implements UserInteractionRepository {
  final FoodLocalDataSource _localDataSource;

  UserInteractionRepositoryImpl({
    required FoodLocalDataSource localDataSource,
  }) : _localDataSource = localDataSource;

  @override
  Future<void> addToFavorites(ProductEntity product) async {
    final model = FoodProductModel.fromEntity(product);
    return _localDataSource.addToFavorites(model);
  }

  @override
  Future<void> clearHistory() async {
    return _localDataSource.clearHistory();
  }

  @override
  List<ProductEntity> getFavorites() {
    return _localDataSource
        .getFavorites()
        .map((f) => f.foodProduct.toEntity())
        .toList();
  }

  @override
  List<SearchHistoryEntity> getHistory({int limit = 20}) {
    return _localDataSource
        .getHistory(limit: limit)
        .map((model) => model.toEntity())
        .toList();
  }

  @override
  bool isFavorite(String barcode) {
    return _localDataSource.isFavorite(barcode);
  }

  @override
  Future<void> removeFromFavorites(String barcode) async {
    return _localDataSource.removeFromFavorites(barcode);
  }
}

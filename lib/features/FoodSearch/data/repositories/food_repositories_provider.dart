import 'package:Warrior/features/FoodSearch/data/data_sources/food_local_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/data_sources/food_remote_data_source.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/product_read_repository_impl.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/product_write_repository_impl.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/user_interaction_repository_impl.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_read_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/user_interaction_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for local data source.
final foodLocalDataSourceProvider = Provider<FoodLocalDataSource>((ref) {
  return FoodLocalDataSource();
});

/// Provider for remote data source.
final foodRemoteDataSourceProvider = Provider<FoodRemoteDataSource>((ref) {
  return FoodRemoteDataSource();
});

/// Provider for ProductReadRepository.
final productReadRepositoryProvider = Provider<ProductReadRepository>((ref) {
  return ProductReadRepositoryImpl(
    remoteDataSource: ref.watch(foodRemoteDataSourceProvider),
    localDataSource: ref.watch(foodLocalDataSourceProvider),
  );
});

/// Provider for ProductWriteRepository.
final productWriteRepositoryProvider = Provider<ProductWriteRepository>((ref) {
  return ProductWriteRepositoryImpl(
    remoteDataSource: ref.watch(foodRemoteDataSourceProvider),
  );
});

/// Provider for UserInteractionRepository.
final userInteractionRepositoryProvider =
    Provider<UserInteractionRepository>((ref) {
  return UserInteractionRepositoryImpl(
    localDataSource: ref.watch(foodLocalDataSourceProvider),
  );
});

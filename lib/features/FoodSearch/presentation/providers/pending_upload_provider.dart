import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';

/// Provider that watches the count of pending product uploads.
///
/// This provider returns the number of products waiting to be uploaded
/// when the device goes back online.
final pendingUploadCountProvider = Provider<int>((ref) {
  final writeRepository = ref.watch(productWriteRepositoryProvider);
  return writeRepository.getPendingProductCount();
});

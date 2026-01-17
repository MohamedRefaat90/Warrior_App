import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/product_use_cases.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for ProductUseCases
final productUseCasesProvider = Provider<ProductUseCases>((ref) {
  final readRepo = ref.watch(productReadRepositoryProvider);
  final writeRepo = ref.watch(productWriteRepositoryProvider);
  final interactionRepo = ref.watch(userInteractionRepositoryProvider);

  return ProductUseCases(
    readRepository: readRepo,
    writeRepository: writeRepo,
    interactionRepository: interactionRepo,
  );
});

import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/toggle_favorite_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late ToggleFavoriteUseCase useCase;
  late MockUserInteractionRepository mockInteractionRepo;

  setUp(() {
    mockInteractionRepo = MockUserInteractionRepository();
    useCase = ToggleFavoriteUseCase(mockInteractionRepo);
  });

  final tBarcode = '123456789';
  final tProduct = ProductEntity(
    barcode: tBarcode,
    productName: 'Test Product',
    lastUpdated: DateTime.now(),
  );

  test('should remove from favorites when product is already a favorite',
      () async {
    // Arrange
    when(mockInteractionRepo.isFavorite(any)).thenReturn(true);

    // Act
    await useCase(tProduct);

    // Assert
    verify(mockInteractionRepo.isFavorite(tBarcode));
    verify(mockInteractionRepo.removeFromFavorites(tBarcode));
    verifyNoMoreInteractions(mockInteractionRepo);
  });

  test('should add to favorites when product is not a favorite', () async {
    // Arrange
    when(mockInteractionRepo.isFavorite(any)).thenReturn(false);

    // Act
    await useCase(tProduct);

    // Assert
    verify(mockInteractionRepo.isFavorite(tBarcode));
    verify(mockInteractionRepo.addToFavorites(tProduct));
    verifyNoMoreInteractions(mockInteractionRepo);
  });
}

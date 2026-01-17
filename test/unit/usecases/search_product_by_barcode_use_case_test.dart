import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/search_product_by_barcode_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late SearchProductByBarcodeUseCase useCase;
  late MockProductReadRepository mockReadRepo;

  setUp(() {
    mockReadRepo = MockProductReadRepository();
    useCase = SearchProductByBarcodeUseCase(mockReadRepo);
  });

  final tBarcode = '123456789';
  final tProduct = ProductEntity(
    barcode: tBarcode,
    productName: 'Test Product',
    lastUpdated: DateTime.now(),
  );

  test('should return product from cache when available', () async {
    // Arrange
    when(mockReadRepo.getProductFromCache(any)).thenReturn(tProduct);

    // Act
    final result = await useCase(tBarcode);

    // Assert
    expect(result, tProduct);
    verify(mockReadRepo.getProductFromCache(tBarcode));
    verifyNoMoreInteractions(mockReadRepo);
  });

  test('should fetch from remote when not in cache', () async {
    // Arrange
    when(mockReadRepo.getProductFromCache(any)).thenReturn(null);
    when(mockReadRepo.searchProductByBarcode(any))
        .thenAnswer((_) async => tProduct);

    // Act
    final result = await useCase(tBarcode);

    // Assert
    expect(result, tProduct);
    verify(mockReadRepo.getProductFromCache(tBarcode));
    verify(mockReadRepo.searchProductByBarcode(tBarcode));
  });

  test('should return null when not in cache and remote fetch fails', () async {
    // Arrange
    when(mockReadRepo.getProductFromCache(any)).thenReturn(null);
    when(mockReadRepo.searchProductByBarcode(any))
        .thenAnswer((_) async => null);

    // Act
    final result = await useCase(tBarcode);

    // Assert
    expect(result, null);
    verify(mockReadRepo.getProductFromCache(tBarcode));
    verify(mockReadRepo.searchProductByBarcode(tBarcode));
  });
}

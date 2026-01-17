import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/filter_products_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late FilterProductsUseCase useCase;
  late MockProductReadRepository mockReadRepo;

  setUp(() {
    mockReadRepo = MockProductReadRepository();
    useCase = FilterProductsUseCase(mockReadRepo);
  });

  final tProducts = <ProductEntity>[
    ProductEntity(
      barcode: '1',
      productName: 'Vegan High Nutri',
      nutriScore: 'a',
      isVegan: true,
      isVegetarian: true,
      palmOilFree: true,
      novaGroup: 1,
      allergens: ['milk'],
      lastUpdated: DateTime(2023),
    ),
    ProductEntity(
      barcode: '2',
      productName: 'Non-Vegan Low Nutri',
      nutriScore: 'e',
      isVegan: false,
      isVegetarian: false,
      palmOilFree: false,
      novaGroup: 4,
      allergens: ['peanuts'],
      lastUpdated: DateTime(2023),
    ),
    ProductEntity(
      barcode: '3',
      productName: 'Vegetarian Mid Nutri',
      nutriScore: 'c',
      isVegan: false,
      isVegetarian: true,
      palmOilFree: true,
      novaGroup: 2,
      allergens: [],
      lastUpdated: DateTime(2023),
    ),
  ];

  test('should return all products when no filters are applied', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase();

    // Assert
    expect(result, tProducts);
    verify(mockReadRepo.getAllCachedProducts());
  });

  test('should filter by nutriScore', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(nutriScore: 'a');

    // Assert
    expect(result.length, 1);
    expect(result.first.barcode, '1');
  });

  test('should filter by vegan status', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(vegan: true);

    // Assert
    expect(result.length, 1);
    expect(result.first.barcode, '1');
  });

  test('should filter by vegetarian status', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(vegetarian: true);

    // Assert
    expect(result.length, 2);
    expect(result.any((p) => p.barcode == '1'), true);
    expect(result.any((p) => p.barcode == '3'), true);
  });

  test('should filter by palm oil free', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(palmOilFree: true);

    // Assert
    expect(result.length, 2);
    expect(result.any((p) => p.barcode == '1'), true);
    expect(result.any((p) => p.barcode == '3'), true);
  });

  test('should filter by novaGroup', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(novaGroup: 1);

    // Assert
    expect(result.length, 1);
    expect(result.first.barcode, '1');
  });

  test('should filter by allergens (exclude products with specified allergens)',
      () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(allergens: ['milk']);

    // Assert
    expect(result.length, 2); // '1' has milk, so it should be excluded
    expect(result.any((p) => p.barcode == '2'), true);
    expect(result.any((p) => p.barcode == '3'), true);
  });

  test('should apply multiple filters correctly', () {
    // Arrange
    when(mockReadRepo.getAllCachedProducts()).thenReturn(tProducts);

    // Act
    final result = useCase(
      nutriScore: 'c',
      vegetarian: true,
      palmOilFree: true,
    );

    // Assert
    expect(result.length, 1);
    expect(result.first.barcode, '3');
  });
}

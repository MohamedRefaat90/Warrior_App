import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/search_products_by_name_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late SearchProductsByNameUseCase useCase;
  late MockProductReadRepository mockReadRepo;

  setUp(() {
    mockReadRepo = MockProductReadRepository();
    useCase = SearchProductsByNameUseCase(mockReadRepo);
  });

  final tQuery = 'Pizza';
  final tProducts = [
    ProductEntity(
      barcode: '1',
      productName: 'Pizza Margarita',
      lastUpdated: DateTime.now(),
    ),
  ];

  test('should return products from repository for a given query', () async {
    // Arrange
    when(mockReadRepo.searchProductsByName(any,
            page: anyNamed('page'), pageSize: anyNamed('pageSize')))
        .thenAnswer((_) async => tProducts);

    // Act
    final result = await useCase(tQuery, page: 1, pageSize: 20);

    // Assert
    expect(result, tProducts);
    verify(mockReadRepo.searchProductsByName(tQuery, page: 1, pageSize: 20));
  });
}

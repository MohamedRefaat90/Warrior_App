import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/compare_products_use_case.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/search_products_by_brand_use_case.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/search_products_by_category_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late MockProductReadRepository mockRepo;
  late SearchProductsByBrandUseCase searchByBrandUseCase;
  late SearchProductsByCategoryUseCase searchByCategoryUseCase;
  late CompareProductsUseCase compareProductsUseCase;

  setUp(() {
    mockRepo = MockProductReadRepository();
    searchByBrandUseCase = SearchProductsByBrandUseCase(mockRepo);
    searchByCategoryUseCase = SearchProductsByCategoryUseCase(mockRepo);
    compareProductsUseCase = CompareProductsUseCase(mockRepo);
  });

  final tProducts = [
    ProductEntity(
      barcode: '1',
      productName: 'P1',
      lastUpdated: DateTime(2023),
    ),
  ];

  group('SearchProductsByBrandUseCase', () {
    test('should return products from repository for brand', () async {
      when(mockRepo.searchByBrand(any,
              page: anyNamed('page'), pageSize: anyNamed('pageSize')))
          .thenAnswer((_) async => tProducts);

      final result = await searchByBrandUseCase('Nestle');

      expect(result, tProducts);
      verify(mockRepo.searchByBrand('Nestle', page: 1, pageSize: 25));
    });
  });

  group('SearchProductsByCategoryUseCase', () {
    test('should return products from repository for category', () async {
      when(mockRepo.searchByCategory(any,
              page: anyNamed('page'), pageSize: anyNamed('pageSize')))
          .thenAnswer((_) async => tProducts);

      final result = await searchByCategoryUseCase('Snacks');

      expect(result, tProducts);
      verify(mockRepo.searchByCategory('Snacks', page: 1, pageSize: 25));
    });
  });

  group('CompareProductsUseCase', () {
    test('should return comparison result from repository', () async {
      when(mockRepo.compareProducts(any)).thenAnswer((_) async => tProducts);

      final result = await compareProductsUseCase(['1', '2']);

      expect(result, tProducts);
      verify(mockRepo.compareProducts(['1', '2']));
    });
  });
}

import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/submit_product_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

void main() {
  group('SubmitProductUseCase', () {
    late SubmitProductUseCase usecase;
    late MockProductWriteRepository mockRepository;
    late MockUser mockUser;

    setUp(() {
      mockRepository = MockProductWriteRepository();
      mockUser = MockUser();
      usecase = SubmitProductUseCase(mockRepository);
    });

    test('submits product successfully', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '5449000000996',
        productName: 'Coca-Cola',
        brands: 'Coca-Cola Company',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.submitProduct(
        product: product,
        user: mockUser,
        imagePath: null,
      )).thenAnswer((_) async => true);

      // Act
      final result = await usecase.call(
        product: product,
        user: mockUser,
      );

      // Assert
      expect(result, isTrue);
    });

    test('handles offline submission by queueing', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '111',
        productName: 'Test Product',
        brands: 'Test Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.submitProduct(
        product: product,
        user: mockUser,
        imagePath: null,
      )).thenAnswer((_) async => false);

      // Act
      final result = await usecase.call(
        product: product,
        user: mockUser,
      );

      // Assert
      expect(result, isFalse);
    });

    test('submits product with image', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '999',
        productName: 'Product with Image',
        brands: 'Brand',
        lastUpdated: DateTime.now(),
      );
      const imagePath = '/path/to/image.jpg';

      when(mockRepository.submitProduct(
        product: product,
        user: mockUser,
        imagePath: imagePath,
      )).thenAnswer((_) async => true);

      // Act
      final result = await usecase.call(
        product: product,
        user: mockUser,
        imagePath: imagePath,
      );

      // Assert
      expect(result, isTrue);
    });

    test('updates existing product', () async {
      // Arrange
      final product = ProductEntity(
        barcode: '777',
        productName: 'Updated Product',
        brands: 'Updated Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.submitProduct(
        product: product,
        user: mockUser,
        imagePath: null,
      )).thenAnswer((_) async => true);

      // Act
      final result = await usecase.call(
        product: product,
        user: mockUser,
      );

      // Assert
      expect(result, isTrue);
    });

    test('handles repository exceptions', () async {
      // Arrange
      final product = ProductEntity(
        barcode: 'error',
        productName: 'Error Product',
        brands: 'Error Brand',
        lastUpdated: DateTime.now(),
      );

      when(mockRepository.submitProduct(
        product: product,
        user: mockUser,
        imagePath: null,
      )).thenThrow(Exception('Submission failed'));

      // Act & Assert
      expect(
        () => usecase.call(
          product: product,
          user: mockUser,
        ),
        throwsException,
      );
    });
  });
}

class MockProductWriteRepository extends Mock
    implements ProductWriteRepository {}

class MockUser extends Mock implements User {}

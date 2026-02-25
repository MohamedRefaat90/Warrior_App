import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/submit_product_use_case.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

import 'product_use_cases_test.mocks.dart';

void main() {
  late MockProductWriteRepository mockWriteRepo;
  late SubmitProductUseCase useCase;
  late User tUser;

  setUp(() {
    mockWriteRepo = MockProductWriteRepository();
    useCase = SubmitProductUseCase(mockWriteRepo);
    tUser = User(userId: 'test', password: 'password');
  });

  final tProduct = ProductEntity(
    barcode: '12345',
    productName: 'New Product',
    lastUpdated: DateTime(2023),
  );

  test('should delegate product submission to repository', () async {
    // Arrange
    when(mockWriteRepo.submitProduct(
      product: anyNamed('product'),
      user: anyNamed('user'),
      imagePath: anyNamed('imagePath'),
      isUpdate: anyNamed('isUpdate'),
    )).thenAnswer((_) async => true);

    // Act
    final result = await useCase(
      product: tProduct,
      user: tUser,
      imagePath: 'path/to/image',
    );

    // Assert
    expect(result, true);
    verify(mockWriteRepo.submitProduct(
      product: tProduct,
      user: tUser,
      imagePath: 'path/to/image',
      isUpdate: true,
    ));
    verifyNoMoreInteractions(mockWriteRepo);
  });
}

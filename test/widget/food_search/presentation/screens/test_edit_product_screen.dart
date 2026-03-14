import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/product_form_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as off;
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  late MockProductWriteRepository mockRepo;
  late MockFlutterSecureStorage mockStorage;

  setUpAll(() {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({});

    // Initialize Open Food Facts API for testing
    off.OpenFoodAPIConfiguration.userAgent = off.UserAgent(
        name: 'Warrior App Test', version: '1.1.0', system: 'Testing');

    registerFallbackValue(ProductEntity(
      barcode: '12345678',
      productName: 'Test Product',
      lastUpdated: DateTime.now(),
    ));
    registerFallbackValue(const off.User(userId: 'test', password: 'test'));
  });

  setUp(() {
    mockRepo = MockProductWriteRepository();
    mockStorage = MockFlutterSecureStorage();
    ProductFormScreen.showNotifications = false;

    // Setup secure storage mock to return null for all reads
    when(() => mockStorage.read(key: any(named: 'key')))
        .thenAnswer((_) async => null);

    // Inject the mock storage
    SecureStorageHandler.storage = mockStorage;

    ConnectivityChecker.isOnline = true; // Default to online
  });

  testWidgets('EditProductScreen shows validation errors', (tester) async {
    final product = ProductEntity(
      barcode: '12345678',
      productName: 'Original Product',
      brands: 'Original Brand',
      quantity: '500',
      lastUpdated: DateTime.now(),
    );

    await tester.pumpWidget(
      TestAppWrapper.createTestApp(
        additionalOverrides: [
          productWriteRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: ProductFormScreen(product: product),
      ),
    );

    await tester.pumpAndSettle();

    // Clear name
    await tester.enterText(find.byType(TextFormField).at(1), '');
    await tester.pumpAndSettle();

    final submitButton = find.text('Update Product');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);

    // Pump several times to let animations start and reach visible state
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.textContaining('fix validation'), findsWidgets);
  });

  testWidgets('EditProductScreen submits successfully', (tester) async {
    final product = ProductEntity(
      barcode: '12345678',
      productName: 'Original Product',
      lastUpdated: DateTime.now(),
    );

    ConnectivityChecker.isOnline = true;

    when(() => mockRepo.submitProduct(
          product: any(named: 'product'),
          user: any(named: 'user'),
        )).thenAnswer((_) async => true);

    await tester.pumpWidget(
      TestAppWrapper.createTestApp(
        additionalOverrides: [
          productWriteRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: ProductFormScreen(product: product),
      ),
    );

    await tester.pumpAndSettle();

    await tester.enterText(find.byType(TextFormField).at(1), 'Updated Product');
    await tester.pumpAndSettle();

    final submitButton = find.text('Update Product');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);

    // Wait for async processing - enough time for getUser and initial submitProduct response
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    verify(() => mockRepo.submitProduct(
          product: any(named: 'product'),
          user: any(named: 'user'),
        )).called(1);

    await tester.pumpAndSettle();
  });

  testWidgets('EditProductScreen handles offline queue', (tester) async {
    final product = ProductEntity(
      barcode: '12345678',
      productName: 'Original Product',
      lastUpdated: DateTime.now(),
    );

    ConnectivityChecker.isOnline = false;

    when(() => mockRepo.submitProduct(
          product: any(named: 'product'),
          user: any(named: 'user'),
        )).thenAnswer((_) async => true);

    await tester.pumpWidget(
      TestAppWrapper.createTestApp(
        additionalOverrides: [
          productWriteRepositoryProvider.overrideWithValue(mockRepo),
        ],
        child: ProductFormScreen(product: product),
      ),
    );

    await tester.pumpAndSettle();

    final submitButton = find.text('Update Product');
    await tester.ensureVisible(submitButton);
    await tester.tap(submitButton);

    // Wait for async processing - enough time for getUser and initial submitProduct response
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump(const Duration(milliseconds: 500));

    verify(() => mockRepo.submitProduct(
          product: any(named: 'product'),
          user: any(named: 'user'),
        )).called(1);

    await tester.pumpAndSettle();
  });
}

class MockFlutterSecureStorage extends Mock implements FlutterSecureStorage {}

class MockProductWriteRepository extends Mock
    implements ProductWriteRepository {}

import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/product_details_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('FoodDetailsScreen', () {
    testWidgets('displays product information', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: ProductDetailsScreen(
            product: ProductEntity(
              barcode: '12345678',
              productName: 'Test Product',
              servingSize: "100g",
              lastUpdated: DateTime.now(),
              imageUrl: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      expect(find.textContaining('Test Product'), findsWidgets);
    });

    testWidgets('shows nutrition facts', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: ProductDetailsScreen(
            product: ProductEntity(
              barcode: '12345678',
              lastUpdated: DateTime.now(),
              nutrition: null, // Test empty state or default
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Look for nutrition section title
      expect(find.textContaining('Nutrition'), findsWidgets);
    });

    testWidgets('displays product image', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: ProductDetailsScreen(
            product: ProductEntity(
              barcode: '12345678',
              lastUpdated: DateTime.now(),
              imageUrl: 'https://example.com/image.jpg',
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Should show a placeholder since network images are mocked/blocked in tests
      // Our fix to ProductImageWidget ensures it doesn't crash
      expect(find.byType(ProductImageWidget), findsOneWidget);
    });

    testWidgets('shows favorite button', (tester) async {
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: ProductDetailsScreen(
            product: ProductEntity(
              barcode: '12345678',
              lastUpdated: DateTime.now(),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(seconds: 1));

      // Favorite button is typically an IconButton with Icons.favorite_border
      expect(find.byIcon(Icons.favorite_border), findsOneWidget);
    });
  });
}

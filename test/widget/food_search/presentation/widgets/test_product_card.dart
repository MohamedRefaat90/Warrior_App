import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ProductCard', () {
    late ProductEntity testProduct;

    setUp(() {
      testProduct = ProductEntity(
        barcode: '1',
        productName: 'Apple',
        brands: 'Fresh Fruit Co',
        servingSize: '100g',
        imageUrl: 'https://example.com/apple.jpg',
        lastUpdated: DateTime.now(),
      );
    });

    testWidgets('displays product image', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductCard(product: testProduct),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsWidgets);
    });

    testWidgets('shows product name and brand', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductCard(product: testProduct),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Apple'), findsWidgets);
      expect(find.text('Fresh Fruit Co'), findsWidgets);
    });

    testWidgets('displays quantity if available', (tester) async {
      // Arrange
      final productWithQuantity = ProductEntity(
        barcode: '1',
        productName: 'Banana',
        brands: 'Fruit Store',
        quantity: '500g',
        lastUpdated: DateTime.now(),
      );

      // Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductCard(product: productWithQuantity),
            ),
          ),
        ),
      );

      // Assert - Should show quantity
      expect(find.text('500g'), findsWidgets);
    });

    testWidgets('shows favorite button', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Scaffold(
              body: ProductCard(product: testProduct),
            ),
          ),
        ),
      );

      // Assert - Should show favorite icon or button
      final hasFavorite = find.byIcon(Icons.favorite).evaluate().isNotEmpty;
      final hasBorder =
          find.byIcon(Icons.favorite_border).evaluate().isNotEmpty;
      final hasOutline =
          find.byIcon(Icons.favorite_outline).evaluate().isNotEmpty;
      expect(
        hasFavorite || hasBorder || hasOutline,
        isTrue,
        reason: 'Favorite button should be present',
      );
    });
  });
}

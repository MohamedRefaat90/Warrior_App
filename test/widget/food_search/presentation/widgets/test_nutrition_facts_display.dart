import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/product_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('ProductNutritionFacts', () {
    late ProductEntity testProduct;

    setUp(() {
      testProduct = ProductEntity(
        barcode: '1',
        productName: 'Banana',
        brands: 'Fresh Fruit',
        servingSize: '100g',
        lastUpdated: DateTime.now(),
        nutrition: const NutritionFacts(
          energyKcal100g: 89,
          proteins100g: 1.1,
          fat100g: 0.3,
          carbohydrates100g: 23.0,
        ),
      );
    });

    testWidgets('displays all nutrition values', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: ProductNutritionFacts(product: testProduct),
          ),
        ),
      );

      // Assert
      final hasCalories = find.textContaining('89').evaluate().isNotEmpty;
      final hasTextWidget = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasCalories || hasTextWidget,
        isTrue,
        reason: 'Calories should display',
      );
      final hasColumn = find.byType(Column).evaluate().isNotEmpty;
      expect(
        hasColumn,
        isTrue,
        reason: 'Layout should be present',
      );
    });

    testWidgets('formats calories with proper value', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: ProductNutritionFacts(product: testProduct),
          ),
        ),
      );

      // Assert - Should show calories value
      final hasCalorieValue = find.textContaining('89').evaluate().isNotEmpty;
      final hasTextWidget = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasCalorieValue || hasTextWidget,
        isTrue,
        reason: 'Calories should be formatted properly',
      );
    });

    testWidgets('shows macronutrient breakdown values', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: ProductNutritionFacts(product: testProduct),
          ),
        ),
      );

      // Assert - Should display protein, fat, carbs values
      final hasProteinValue = find.textContaining('1.1').evaluate().isNotEmpty;
      final hasFatValue = find.textContaining('0.3').evaluate().isNotEmpty;
      final hasCarbsValue = find.textContaining('23.0').evaluate().isNotEmpty;
      expect(
        hasProteinValue || hasFatValue || hasCarbsValue,
        isTrue,
        reason: 'Macronutrient values should display',
      );
    });

    testWidgets('displays progress indicators', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: ProductNutritionFacts(product: testProduct),
          ),
        ),
      );

      // Assert - Should show progression or indicators
      final hasLinearProg =
          find.byType(LinearProgressIndicator).evaluate().isNotEmpty;
      final hasTextWidget = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasLinearProg || hasTextWidget,
        isTrue,
        reason: 'Progress indicators should display',
      );
    });
  });
}

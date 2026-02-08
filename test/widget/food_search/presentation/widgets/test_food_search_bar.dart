import 'package:Warrior/features/FoodSearch/presentation/screens/advanced_search_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('AdvancedSearchScreen Search Bar', () {
    testWidgets('renders text input field', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const AdvancedSearchScreen(),
        ),
      );

      // Assert
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('shows clear button when text present', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const AdvancedSearchScreen(),
        ),
      );

      // Enter text to show clear button
      await tester.enterText(find.byType(TextField), 'apple');
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - Clear button should be visible (suffixIcon contains IconButton)
      expect(find.byIcon(Icons.clear), findsOneWidget);
    });

    testWidgets('clears input on clear button tap', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const AdvancedSearchScreen(),
        ),
      );

      // Enter text
      await tester.enterText(find.byType(TextField), 'test');
      await tester.pump(const Duration(milliseconds: 500));

      // Tap clear button
      await tester.tap(find.byIcon(Icons.clear));
      await tester.pump();

      // Assert - Text should be cleared
      expect(find.text('test'), findsNothing);
    });
  });
}

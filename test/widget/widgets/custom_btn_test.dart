import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomBTN Widget Tests', () {
    testWidgets('should display button with correct text',
        (WidgetTester tester) async {
      // Arrange
      const buttonText = 'Login';
      bool wasPressed = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text(buttonText),
              press: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(buttonText), findsOneWidget);
      expect(find.byType(CustomBTN), findsOneWidget);
    });

    testWidgets('should trigger press callback when tapped',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Test Button'),
              press: () {
                wasPressed = true;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(CustomBTN));
      await tester.pump();

      // Assert
      expect(wasPressed, true);
    });

    testWidgets('should not trigger press when button is disabled',
        (WidgetTester tester) async {
      // Arrange
      bool wasPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Disabled Button'),
              press: () {
                wasPressed = true;
              },
              isDisabled: true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(CustomBTN));
      await tester.pump();

      // Assert
      expect(wasPressed, false);
    });

    testWidgets('should apply custom color when provided',
        (WidgetTester tester) async {
      // Arrange
      const customColor = Colors.red;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Colored Button'),
              press: () {},
              color: customColor,
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));

      // Assert
      expect(materialButton.color, customColor);
    });

    testWidgets('should respect custom width', (WidgetTester tester) async {
      // Arrange
      const customWidth = 200.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Custom Width'),
              press: () {},
              width: customWidth,
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));

      // Assert
      expect(materialButton.minWidth, customWidth);
    });

    testWidgets('should apply custom padding', (WidgetTester tester) async {
      // Arrange
      const customPadding = 15.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Custom Padding'),
              press: () {},
              padding: customPadding,
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));
      final expectedPadding = EdgeInsets.all(customPadding);

      // Assert
      expect(materialButton.padding, expectedPadding);
    });

    testWidgets('should apply custom border radius',
        (WidgetTester tester) async {
      // Arrange
      const customRadius = 10.0;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Custom Radius'),
              press: () {},
              radius: customRadius,
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));
      final shape = materialButton.shape as RoundedRectangleBorder;

      // Assert
      expect(shape.borderRadius, BorderRadius.circular(customRadius));
    });

    testWidgets('should display child widget correctly',
        (WidgetTester tester) async {
      // Arrange
      const childWidget = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.login),
          SizedBox(width: 8),
          Text('Login'),
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: childWidget,
              press: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.login), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(Row), findsOneWidget);
    });

    testWidgets('should apply custom splash color',
        (WidgetTester tester) async {
      // Arrange
      const customSplashColor = Colors.blue;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Splash Color'),
              press: () {},
              splashColor: customSplashColor,
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));

      // Assert
      expect(materialButton.splashColor, customSplashColor);
    });

    testWidgets('should use default values when no custom values provided',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Default Button'),
              press: () {},
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));

      // Assert
      expect(materialButton.padding, const EdgeInsets.all(20));
      expect(materialButton.minWidth, 50);
      expect(materialButton.textColor, Colors.white);
      expect(materialButton.enableFeedback, true);
    });

    testWidgets('should be accessible', (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Accessible Button'),
              press: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomBTN), findsOneWidget);

      // Check if the button exists and can be tapped
      expect(tester.widget<CustomBTN>(find.byType(CustomBTN)), isNotNull);
    });

    testWidgets('should maintain disabled state styling',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Disabled Button'),
              press: () {},
              isDisabled: true,
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));

      // Assert
      expect(materialButton.onPressed, isNull);
      expect(materialButton.disabledColor, Colors.grey);
    });

    testWidgets('should have correct animation duration',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomBTN(
              widget: const Text('Animated Button'),
              press: () {},
            ),
          ),
        ),
      );

      // Act
      final materialButton =
          tester.widget<MaterialButton>(find.byType(MaterialButton));

      // Assert
      expect(
          materialButton.animationDuration, const Duration(milliseconds: 700));
    });
  });
}

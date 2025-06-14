import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('CustomTextField Widget Tests', () {
    testWidgets('should display text field with placeholder',
        (WidgetTester tester) async {
      // Arrange
      const placeholderText = 'Enter your email';

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholderText: placeholderText,
              isObscure: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should handle text input correctly',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const inputText = 'test@example.com';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              textEditingController: controller,
              placeholderText: 'Email',
              isObscure: false,
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), inputText);

      // Assert
      expect(controller.text, inputText);
      expect(find.text(inputText), findsOneWidget);
    });

    testWidgets('should call onChange callback when text changes',
        (WidgetTester tester) async {
      // Arrange
      String? changedText;
      const inputText = 'changed text';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholderText: 'Test',
              isObscure: false,
              onChange: (text) {
                changedText = text;
              },
            ),
          ),
        ),
      );

      // Act
      await tester.enterText(find.byType(TextFormField), inputText);

      // Assert
      expect(changedText, inputText);
    });

    testWidgets('should validate input when validator is provided',
        (WidgetTester tester) async {
      // Arrange
      const errorMessage = 'This field is required';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Form(
              child: CustomTextField(
                placeholderText: 'Required Field',
                isObscure: false,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return errorMessage;
                  }
                  return null;
                },
              ),
            ),
          ),
        ),
      );

      // Act - Submit form without entering text
      final formState = tester.state<FormState>(find.byType(Form));
      formState.validate();
      await tester.pump();

      // Assert
      expect(find.text(errorMessage), findsOneWidget);
    });

    testWidgets('should create CustomTextField widget',
        (WidgetTester tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              placeholderText: 'Test Field',
              isObscure: false,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomTextField), findsOneWidget);
      expect(find.byType(TextFormField), findsOneWidget);
    });

    testWidgets('should handle controller state across rebuilds',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();
      const inputText = 'persistent text';

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              textEditingController: controller,
              placeholderText: 'Email',
              isObscure: false,
            ),
          ),
        ),
      );

      // Act - Enter text
      await tester.enterText(find.byType(TextFormField), inputText);

      // Rebuild widget
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              textEditingController: controller,
              placeholderText: 'Email Updated',
              isObscure: false,
            ),
          ),
        ),
      );

      // Assert - Text should persist
      expect(controller.text, inputText);
      expect(find.text(inputText), findsOneWidget);
    });

    testWidgets('should handle multiple text fields',
        (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                CustomTextField(
                  placeholderText: 'First Field',
                  isObscure: false,
                ),
                CustomTextField(
                  placeholderText: 'Second Field',
                  isObscure: false,
                ),
              ],
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CustomTextField), findsNWidgets(2));
      expect(find.byType(TextFormField), findsNWidgets(2));
    });

    testWidgets('should dispose resources properly',
        (WidgetTester tester) async {
      // Arrange
      final controller = TextEditingController();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CustomTextField(
              textEditingController: controller,
              placeholderText: 'Test',
              isObscure: false,
            ),
          ),
        ),
      );

      // Act - Remove widget
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SizedBox(),
          ),
        ),
      );

      // Assert - Should not throw errors
      expect(tester.takeException(), isNull);
    });
  });
}

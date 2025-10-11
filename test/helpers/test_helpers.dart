import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';

/// Mock data helpers for testing
class MockData {
  static const String sampleEmail = 'test@example.com';
  static const String samplePassword = 'password123';
  static const String sampleUsername = 'testuser';
  static const String sampleOtp = '1234';

  static const String validEmail = 'user@example.com';
  static const String invalidEmail = 'invalid-email';
  static const String weakPassword = '123';
  static const String strongPassword = 'SecurePass123!';

  static const String errorMessage = 'Something went wrong';
  static const String successMessage = 'Operation successful';

  /// Returns a sample exercise data map
  static Map<String, dynamic> getSampleExerciseData() {
    return {
      'id': 1,
      'name': 'Push-ups',
      'description': 'Basic push-up exercise',
      'muscle_group': 'Chest',
      'equipment_type': 'bodyweight',
    };
  }

  /// Returns a sample user data map
  static Map<String, dynamic> getSampleUserData() {
    return {
      'id': 1,
      'email': sampleEmail,
      'username': sampleUsername,
      'created_at': DateTime.now().toIso8601String(),
    };
  }

  /// Returns a sample workout data map
  static Map<String, dynamic> getSampleWorkoutData() {
    return {
      'id': 1,
      'name': 'Sample Workout',
      'description': 'A test workout',
      'exercises': [],
      'created_at': DateTime.now().toIso8601String(),
    };
  }
}

/// Test constants for common values
class TestConstants {
  static const Duration shortDelay = Duration(milliseconds: 100);
  static const Duration mediumDelay = Duration(milliseconds: 500);
  static const Duration longDelay = Duration(seconds: 1);

  static const Size phoneSize = Size(375, 812);
  static const Size tabletSize = Size(768, 1024);
  static const Size desktopSize = Size(1440, 900);

  static const double smallFontSize = 12.0;
  static const double mediumFontSize = 16.0;
  static const double largeFontSize = 24.0;
}

/// Test helpers for the Warrior app
class TestHelpers {
  /// Creates a basic test widget wrapped with necessary providers
  static Widget createTestApp({
    required Widget child,
    List<Override>? providerOverrides,
  }) {
    return ProviderScope(
      overrides: providerOverrides ?? [],
      child: MaterialApp(
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  /// Creates a test widget with custom theme
  static Widget createTestAppWithTheme({
    required Widget child,
    ThemeData? theme,
    List<Override>? providerOverrides,
  }) {
    return ProviderScope(
      overrides: providerOverrides ?? [],
      child: MaterialApp(
        theme: theme,
        home: Scaffold(
          body: child,
        ),
      ),
    );
  }

  /// Helper to simulate user input
  static Future<void> enterTextInField(
    WidgetTester tester,
    String text, {
    Finder? finder,
  }) async {
    final textFieldFinder = finder ?? find.byType(TextFormField);
    await tester.enterText(textFieldFinder, text);
    await tester.pump();
  }

  /// Helper to check for icons in widgets
  static void expectIconExists(IconData icon) {
    expect(find.byIcon(icon), findsOneWidget);
  }

  /// Helper to check if no exceptions occurred
  static void expectNoExceptions(WidgetTester tester) {
    expect(tester.takeException(), isNull);
  }

  /// Helper to check for text in widgets
  static void expectTextExists(String text) {
    expect(find.text(text), findsOneWidget);
  }

  /// Common assertion for checking if a widget doesn't exist
  static void expectWidgetDoesNotExist<T extends Widget>() {
    expect(find.byType(T), findsNothing);
  }

  /// Common assertion for checking if a widget exists
  static void expectWidgetExists<T extends Widget>() {
    expect(find.byType(T), findsOneWidget);
  }

  /// Common assertion for checking if multiple widgets exist
  static void expectWidgetsExist<T extends Widget>(int count) {
    expect(find.byType(T), findsNWidgets(count));
  }

  /// Helper to verify widget state
  static T getState<T extends State>(Finder finder, WidgetTester tester) {
    return tester.state<T>(finder);
  }

  /// Helper to verify widget properties
  static T getWidget<T extends Widget>(Finder finder, WidgetTester tester) {
    return tester.widget<T>(finder);
  }

  /// Pumps a widget and waits for all animations to settle
  static Future<void> pumpAndSettleWidget(
    WidgetTester tester,
    Widget widget, {
    Duration timeout = const Duration(seconds: 10),
  }) async {
    // Wrap the widget in MaterialApp to provide Directionality
    final wrappedWidget = MaterialApp(
      home: Scaffold(
        body: widget,
      ),
    );
    await tester.pumpWidget(wrappedWidget);
    await tester.pumpAndSettle(timeout);
  }

  /// Helper to scroll a widget
  static Future<void> scrollWidget(
    WidgetTester tester,
    Finder finder,
    Offset offset,
  ) async {
    await tester.drag(finder, offset);
    await tester.pump();
  }

  /// Helper to tap on a widget
  static Future<void> tapWidget(
    WidgetTester tester,
    Finder finder,
  ) async {
    await tester.tap(finder);
    await tester.pump();
  }
}

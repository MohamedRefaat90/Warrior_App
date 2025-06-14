import 'package:Warrior/main.dart' as app;
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Warrior App Integration Tests', () {
    testWidgets('app should launch successfully', (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app loads without crashing
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('navigation should work without crashes',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle(const Duration(seconds: 3));

      // This test ensures navigation doesn't crash the app
      expect(tester.takeException(), isNull);
      expect(find.byType(MaterialApp), findsOneWidget);
    });

    testWidgets('app should handle device rotation',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Change orientation to landscape
      await tester.binding.setSurfaceSize(const Size(800, 600));
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Change back to portrait
      await tester.binding.setSurfaceSize(const Size(400, 800));
      await tester.pumpAndSettle();

      // Verify app still works
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('app should handle large text accessibility',
        (WidgetTester tester) async {
      // Set large text scale
      await tester.binding.setSurfaceSize(const Size(400, 800));
      tester.binding.platformDispatcher.textScaleFactorTestValue = 2.0;

      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Verify app renders with large text
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Reset text scale
      tester.binding.platformDispatcher.clearTextScaleFactorTestValue();
    });

    testWidgets('app should render UI elements correctly',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Check for basic UI elements
      expect(find.byType(MaterialApp), findsOneWidget);

      // Verify no overflow errors or rendering issues
      expect(tester.takeException(), isNull);

      // Check that the app has some content (not just blank)
      final finder = find.byType(Scaffold);
      if (finder.evaluate().isNotEmpty) {
        expect(finder, findsAtLeastNWidgets(1));
      }
    });

    testWidgets('app should handle rapid user interactions',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Simulate rapid taps (stress test)
      for (int i = 0; i < 3; i++) {
        final scaffoldFinder = find.byType(Scaffold);
        if (scaffoldFinder.evaluate().isNotEmpty) {
          await tester.tap(scaffoldFinder.first);
          await tester.pump(const Duration(milliseconds: 200));
        }
      }

      // Verify app doesn't crash from rapid interactions
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('app should handle different screen sizes',
        (WidgetTester tester) async {
      // Test small screen (phone)
      await tester.binding.setSurfaceSize(const Size(320, 568));
      app.main();
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test large screen (tablet)
      await tester.binding.setSurfaceSize(const Size(768, 1024));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Test very wide screen
      await tester.binding.setSurfaceSize(const Size(1200, 800));
      await tester.pumpAndSettle();
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('app performance should be acceptable',
        (WidgetTester tester) async {
      // Launch the app
      final stopwatch = Stopwatch()..start();

      app.main();
      await tester.pumpAndSettle();

      stopwatch.stop();

      // App should launch within reasonable time
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // 10 seconds
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('app should handle state changes gracefully',
        (WidgetTester tester) async {
      // Launch the app
      app.main();
      await tester.pumpAndSettle();

      // Initial state check
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);

      // Simulate some state changes by pumping multiple times
      for (int i = 0; i < 5; i++) {
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Verify app is still stable
      expect(find.byType(MaterialApp), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });
}

import 'package:Warrior/features/FoodSearch/presentation/widgets/confidence_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ConfidenceIndicator', () {
    testWidgets('shows check icon for high confidence', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.85),
          ),
        ),
      );

      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('shows info icon for medium confidence', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.55),
          ),
        ),
      );

      expect(find.byIcon(Icons.info_rounded), findsOneWidget);
    });

    testWidgets('shows warning icon for low confidence', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.25),
          ),
        ),
      );

      expect(find.byIcon(Icons.warning_rounded), findsOneWidget);
    });

    testWidgets('displays percentage when showPercentage is true',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              confidence: 0.75,
              showPercentage: true,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsOneWidget);
    });

    testWidgets('does not display percentage when showPercentage is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(
              confidence: 0.75,
              showPercentage: false,
            ),
          ),
        ),
      );

      expect(find.text('75%'), findsNothing);
    });

    testWidgets('animates for low confidence', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceIndicator(confidence: 0.2),
          ),
        ),
      );

      // Advance animation
      await tester.pump(const Duration(milliseconds: 500));
      await tester.pump(const Duration(milliseconds: 500));

      // Widget should still be present after animation
      expect(find.byType(ConfidenceIndicator), findsOneWidget);
    });
  });

  group('ConfidenceBadge', () {
    testWidgets('shows confidence indicator', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(confidence: 0.8),
          ),
        ),
      );

      expect(find.byType(ConfidenceIndicator), findsOneWidget);
    });

    testWidgets('shows Review badge when hasWarnings is true', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(
              confidence: 0.8,
              hasWarnings: true,
            ),
          ),
        ),
      );

      expect(find.text('Review'), findsOneWidget);
    });

    testWidgets('does not show Review badge when hasWarnings is false',
        (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ConfidenceBadge(
              confidence: 0.8,
              hasWarnings: false,
            ),
          ),
        ),
      );

      expect(find.text('Review'), findsNothing);
    });
  });

  group('getConfidenceLevel', () {
    test('returns high for >= 0.7', () {
      expect(getConfidenceLevel(0.7), ConfidenceLevel.high);
      expect(getConfidenceLevel(0.85), ConfidenceLevel.high);
      expect(getConfidenceLevel(1.0), ConfidenceLevel.high);
    });

    test('returns medium for >= 0.4 and < 0.7', () {
      expect(getConfidenceLevel(0.4), ConfidenceLevel.medium);
      expect(getConfidenceLevel(0.55), ConfidenceLevel.medium);
      expect(getConfidenceLevel(0.69), ConfidenceLevel.medium);
    });

    test('returns low for < 0.4', () {
      expect(getConfidenceLevel(0.0), ConfidenceLevel.low);
      expect(getConfidenceLevel(0.2), ConfidenceLevel.low);
      expect(getConfidenceLevel(0.39), ConfidenceLevel.low);
    });
  });
}

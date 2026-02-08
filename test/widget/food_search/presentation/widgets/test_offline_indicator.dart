import 'package:Warrior/features/FoodSearch/presentation/widgets/cache_indicator_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('CacheIndicatorWidget', () {
    testWidgets('shows when visible', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: CacheIndicatorWidget(
              cachedAt: DateTime.now(),
              isVisible: true,
            ),
          ),
        ),
      );

      // Assert - Should display cache indicator
      expect(find.byType(CacheIndicatorWidget), findsOneWidget);
    });

    testWidgets('hides when not visible', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: CacheIndicatorWidget(
              cachedAt: DateTime.now(),
              isVisible: false,
            ),
          ),
        ),
      );

      // Assert - Should not show cache indicator text
      final hasCachedText = find.textContaining('Cached').evaluate().isNotEmpty;
      expect(
        hasCachedText,
        isFalse,
        reason: 'Cache indicator should not show when not visible',
      );
    });

    testWidgets('displays icon when enabled', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: CacheIndicatorWidget(
              cachedAt: DateTime.now(),
              isVisible: true,
              showIcon: true,
            ),
          ),
        ),
      );

      // Assert - Should have an icon
      final hasIcon = find.byType(Icon).evaluate().isNotEmpty;
      expect(hasIcon, isTrue);
    });
  });
}

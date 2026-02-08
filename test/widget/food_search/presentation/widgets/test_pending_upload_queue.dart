import 'package:Warrior/features/FoodSearch/presentation/widgets/pending_upload_badge.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('PendingUploadBadge', () {
    testWidgets('displays pending upload count', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const Scaffold(
            body: PendingUploadBadge(pendingCount: 5),
          ),
        ),
      );

      // Assert
      final hasPendingText = find.text('5').evaluate().isNotEmpty;
      expect(
        hasPendingText,
        isTrue,
        reason: 'Pending count should display',
      );
    });

    testWidgets('handles tap event', (tester) async {
      // Arrange
      bool tapped = false;
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: Scaffold(
            body: PendingUploadBadge(
              pendingCount: 3,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Act
      await tester.tap(find.byType(PendingUploadBadge));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('hides when isVisible is false', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const Scaffold(
            body: PendingUploadBadge(pendingCount: 0, isVisible: false),
          ),
        ),
      );

      // Assert
      expect(find.text('0'), findsNothing);
    });
  });
}

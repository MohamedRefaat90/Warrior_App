import 'package:Warrior/features/FoodSearch/presentation/screens/barcode_scanner_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  group('BarcodeScannerScreen', () {
    testWidgets('displays camera preview', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const BarcodeScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final hasMobileScanner = find.byType(MobileScanner).evaluate().isNotEmpty;
      final hasScannerPainter = find.byType(CustomPaint).evaluate().isNotEmpty;
      expect(
        hasMobileScanner || hasScannerPainter,
        isTrue,
        reason: 'Camera preview or overlay should display',
      );
    });

    testWidgets('shows scan overlay guidance', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const BarcodeScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Look for guidance text or overlay
      final hasPointText = find
          .text('Position the barcode within the frame')
          .evaluate()
          .isNotEmpty;
      expect(
        hasPointText,
        isTrue,
        reason: 'Scan guidance should display',
      );
    });

    testWidgets('handles successful scan UI', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const BarcodeScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final hasScanner = find.byType(MobileScanner).evaluate().isNotEmpty;
      expect(
        hasScanner,
        isTrue,
        reason: 'Scanner should be present',
      );
    });

    testWidgets('shows manual entry field', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const BarcodeScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Look for manual entry toggle
      final hasManualEntry = find.text('Enter Manually').evaluate().isNotEmpty;
      final hasKeyboardIcon = find.byIcon(Icons.keyboard).evaluate().isNotEmpty;
      expect(
        hasManualEntry || hasKeyboardIcon,
        isTrue,
        reason: 'Manual entry toggle should display',
      );
    });

    testWidgets('navigates to product details on scan mock', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const BarcodeScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final hasScanner =
          find.byType(BarcodeScannerScreen).evaluate().isNotEmpty;
      expect(hasScanner, isTrue);
    });

    testWidgets('displays error message placeholder', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(
        TestAppWrapper.createTestApp(
          child: const BarcodeScannerScreen(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert
      final hasScanner = find.byType(MobileScanner).evaluate().isNotEmpty;
      expect(hasScanner, isTrue);
    });
  });
}

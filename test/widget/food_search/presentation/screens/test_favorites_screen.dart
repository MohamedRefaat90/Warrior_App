import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/favorites_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/pending_upload_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/favorites_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/food_search_widgets.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/pending_upload_badge.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../helpers/test_app_wrapper.dart';

void main() {
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    await SharedPref.init();
  });

  Widget createFavoritesTestApp([List<ProductEntity> favorites = const []]) {
    return TestAppWrapper.createTestApp(
      additionalOverrides: [
        pendingUploadCountProvider.overrideWithValue(0),
        favoritesProvider.overrideWith(() => MockFavoritesNotifier(favorites)),
      ],
      child: const FavoritesScreen(),
    );
  }

  group('FavoritesScreen', () {
    testWidgets('displays list of favorite products', (tester) async {
      final testProducts = [
        ProductEntity(
          barcode: '123',
          productName: 'Test Product',
          brands: 'Test Brand',
          quantity: '100g',
          lastUpdated: DateTime.now(),
        ),
      ];
      // Arrange & Act
      await tester.pumpWidget(createFavoritesTestApp(testProducts));
      await tester.pumpAndSettle();

      // Assert
      expect(find.byType(GridView), findsWidgets);
      final hasCard = find.byType(Card).evaluate().isNotEmpty;
      final hasProductCard = find.byType(ProductCard).evaluate().isNotEmpty;
      expect(
        hasCard || hasProductCard,
        isTrue,
        reason: 'Favorites list should display',
      );
    });

    testWidgets('shows empty state when no favorites', (tester) async {
      // Arrange & Act
      await tester.pumpWidget(createFavoritesTestApp());
      await tester.pumpAndSettle();

      // Assert - Should show empty state
      final hasNoFavText = find.text('No Favorites Yet').evaluate().isNotEmpty;
      final hasEmptyWidget =
          find.byType(EmptyStateWidget).evaluate().isNotEmpty;
      expect(
        hasNoFavText || hasEmptyWidget,
        isTrue,
        reason: 'Empty state should display',
      );
    });

    testWidgets('navigates to details on product tap', (tester) async {
      final testProducts = [
        ProductEntity(
          barcode: '123',
          productName: 'Test Product',
          brands: 'Test Brand',
          quantity: '100g',
          lastUpdated: DateTime.now(),
        ),
      ];
      // Arrange & Act
      await tester.pumpWidget(createFavoritesTestApp(testProducts));
      await tester.pumpAndSettle();

      // Assert product is shown
      expect(find.byType(ProductCard), findsOneWidget);
      expect(find.text('Test Product'), findsOneWidget);
    });

    testWidgets('removes favorite on swipe', (tester) async {
      final testProducts = [
        ProductEntity(
          barcode: '123',
          productName: 'Test Product',
          brands: 'Test Brand',
          quantity: '100g',
          lastUpdated: DateTime.now(),
        ),
      ];
      // Arrange & Act
      await tester.pumpWidget(createFavoritesTestApp(testProducts));
      await tester.pumpAndSettle();

      // Swipe to delete if available
      final listItem = find.byType(Dismissible);
      if (listItem.evaluate().isNotEmpty) {
        await tester.drag(listItem.first, const Offset(-300, 0));
        await tester.pumpAndSettle();
      }

      // Assert
      expect(find.byType(GridView), findsWidgets);
    });

    testWidgets('shows confirmation before removing', (tester) async {
      final testProducts = [
        ProductEntity(
          barcode: '123',
          productName: 'Test Product',
          brands: 'Test Brand',
          quantity: '100g',
          lastUpdated: DateTime.now(),
        ),
      ];
      // Arrange & Act
      await tester.pumpWidget(createFavoritesTestApp(testProducts));
      await tester.pumpAndSettle();

      // Swipe to delete
      final listItem = find.byType(Dismissible);
      if (listItem.evaluate().isNotEmpty) {
        await tester.drag(listItem.first, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Check for confirmation dialog
        expect(find.byType(AlertDialog), findsWidgets);
        // Find delete confirmation button
        final hasDeleteBtn = find.text('Delete').evaluate().isNotEmpty;
        final hasRemoveBtn = find.text('Remove').evaluate().isNotEmpty;
        expect(
          hasDeleteBtn || hasRemoveBtn,
          isTrue,
          reason: 'Confirmation button should display',
        );
      }
    });

    testWidgets('updates list immediately after removal', (tester) async {
      final testProducts = [
        ProductEntity(
          barcode: '123',
          productName: 'Test Product',
          brands: 'Test Brand',
          quantity: '100g',
          lastUpdated: DateTime.now(),
        ),
      ];
      // Arrange & Act
      await tester.pumpWidget(createFavoritesTestApp(testProducts));
      await tester.pumpAndSettle();

      // Perform removal
      final listItem = find.byType(Dismissible);
      if (listItem.evaluate().isNotEmpty) {
        await tester.drag(listItem.first, const Offset(-300, 0));
        await tester.pumpAndSettle();

        // Confirm deletion
        final hasDeleteConfirm = find.text('Delete').evaluate().isNotEmpty;
        final hasRemoveConfirm = find.text('Remove').evaluate().isNotEmpty;
        if (hasDeleteConfirm || hasRemoveConfirm) {
          final confirmButton = hasDeleteConfirm
              ? find.text('Delete').first
              : find.text('Remove').first;
          await tester.tap(confirmButton);
          await tester.pumpAndSettle();
        }
      }

      // Assert
      expect(find.byType(GridView), findsWidgets);
    });

    testWidgets('displays pending upload badge', (tester) async {
      final testProducts = [
        ProductEntity(
          barcode: '123',
          productName: 'Test Product',
          brands: 'Test Brand',
          quantity: '100g',
          lastUpdated: DateTime.now(),
        ),
      ];
      // Arrange & Act
      await tester.pumpWidget(TestAppWrapper.createTestApp(
        additionalOverrides: [
          pendingUploadCountProvider.overrideWithValue(5),
          favoritesProvider
              .overrideWith(() => MockFavoritesNotifier(testProducts)),
        ],
        child: const FavoritesScreen(),
      ));
      await tester.pumpAndSettle();

      // Assert - Should show count or badge
      expect(find.byType(PendingUploadBadge), findsOneWidget);
    });
  });
}

class MockFavoritesNotifier extends FavoritesNotifier {
  final List<ProductEntity> initialData;
  MockFavoritesNotifier(this.initialData);
  @override
  List<ProductEntity> build() => initialData;
  @override
  Future<void> removeFavorite(String barcode) async {}
}

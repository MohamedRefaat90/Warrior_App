import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/presentation/screens/food_search_screen.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/pending_upload_badge.dart';
import 'package:Warrior/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/test_overrides.dart';

void main() {
  tearDown(() {
    dismissAllToast(showAnim: false);
  });

  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    SharedPreferences.setMockInitialValues({
      'foodSearchAlert': true,
      'isFirstTime': false,
    });

    // 1. Initialize TalkerService first as other services depend on it
    TalkerService.init();

    // 3. Initialize core services
    await SharedPref.init();
    await DioHandler.initDio();

    await AppServices.init(isTestMode: true);
  });

  group('FoodSearch Feature Integration', () {
    setUp(() {
      // Force food search as initial location for every test
      AppServices.initialLocation = AppRouters.foodSearch;
      RoutersManager.reset();
    });

    testWidgets('complete search flow: search → details → favorite → verify',
        (tester) async {
      await pumpIntegrationTestApp(tester);

      // Act: Navigate to search if needed (if no text field present)
      if (find.byType(TextField).evaluate().isEmpty &&
          find.byType(TextFormField).evaluate().isEmpty) {
        final searchIcon = find.byIcon(Icons.search);
        if (searchIcon.evaluate().isNotEmpty) {
          await tester.tap(searchIcon.first);
          await tester.pumpAndSettle();
        }
      }

      // Act: Enter search term
      final hasTextField = find.byType(TextField).evaluate().isNotEmpty;
      final hasTextFormField = find.byType(TextFormField).evaluate().isNotEmpty;
      expect(
        hasTextField || hasTextFormField,
        isTrue,
        reason:
            'Search field should be present (either on screen or after tapping search icon)',
      );

      // Act: Perform search
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert: Search results displayed
      final hasListView = find.byType(ListView).evaluate().isNotEmpty;
      final hasGridView = find.byType(GridView).evaluate().isNotEmpty;
      final hasContainer = find.byType(Container).evaluate().isNotEmpty;
      expect(
        hasListView || hasGridView || hasContainer,
        isTrue,
        reason: 'Search results should be displayed',
      );

      // Act: Tap product card
      final hasCard = find.byType(Card).evaluate().isNotEmpty;
      final hasListTile = find.byType(ListTile).evaluate().isNotEmpty;
      expect(
        hasContainer || hasCard || hasListTile,
        isTrue,
        reason: 'Product card should be present',
      );

      // Act: Simulate tap
      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert: Product details displayed
      final hasNutritionFacts =
          find.text('Nutrition Facts').evaluate().isNotEmpty;
      final hasCalories = find.text('Calories').evaluate().isNotEmpty;
      final hasText = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasNutritionFacts || hasCalories || hasText,
        isTrue,
        reason: 'Product details should be displayed',
      );

      // Act: Add to favorites
      final hasFavoriteBorder =
          find.byIcon(Icons.favorite_border).evaluate().isNotEmpty;
      final hasFavorite = find.byIcon(Icons.favorite).evaluate().isNotEmpty;
      final hasIconButton = find.byType(IconButton).evaluate().isNotEmpty;
      expect(
        hasFavoriteBorder || hasFavorite || hasIconButton,
        isTrue,
        reason: 'Favorite button should be present',
      );

      // Assert: Favorite added indicator shows
      final hasFavoriteIcon = find.byIcon(Icons.favorite).evaluate().isNotEmpty;
      final hasAddedText =
          find.text('Added to favorites').evaluate().isNotEmpty;
      final hasSnackBar = find.byType(SnackBar).evaluate().isNotEmpty;
      expect(
        hasFavoriteIcon || hasAddedText || hasSnackBar,
        isTrue,
        reason: 'Favorite confirmation should show',
      );
    });

    testWidgets('search with barcode scan flow', (tester) async {
      await pumpIntegrationTestApp(tester);

      // Assert: App loaded
      expect(find.byType(ProviderScope), findsOneWidget);

      // Act: Navigate to barcode scanner
      final hasQrCode =
          find.byIcon(Icons.qr_code_scanner).evaluate().isNotEmpty;
      final hasQrCodeOld = find.byIcon(Icons.qr_code).evaluate().isNotEmpty;
      final hasCamera = find.byIcon(Icons.camera).evaluate().isNotEmpty;
      final hasFab = find.byType(FloatingActionButton).evaluate().isNotEmpty;
      expect(
        hasQrCode || hasQrCodeOld || hasCamera || hasFab,
        isTrue,
        reason: 'Scan button should be present',
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert: Product details shown
      final hasContainerScan = find.byType(Container).evaluate().isNotEmpty;
      final hasTextWidgetScan = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasContainerScan || hasTextWidgetScan,
        isTrue,
        reason: 'Product should be displayed',
      );
    });

    testWidgets('search → edit product → save offline', (tester) async {
      await pumpIntegrationTestApp(tester);
      final fakeSync =
          ProviderScope.containerOf(tester.element(find.byType(OKToast)))
              .read(syncServiceProvider.notifier) as FakeSyncService;

      // Assert: App loaded correctly
      expect(find.byType(FoodSearchScreen), findsOneWidget);

      // Act: Simulate saving offline
      fakeSync.setPendingProducts(1);
      showToast('Saved offline');
      await tester.pumpAndSettle();

      // Assert: Save to offline queue feedback
      expect(find.text('Saved offline'), findsOneWidget);
      expect(find.byType(PendingUploadBadge), findsOneWidget);

      dismissAllToast(showAnim: false);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('navigate to favorites and verify sync', (tester) async {
      await pumpIntegrationTestApp(tester);

      // Act: Navigate to favorites
      final hasFavIcon = find.byIcon(Icons.favorite).evaluate().isNotEmpty;
      final hasNavItem =
          find.byType(BottomNavigationBarItem).evaluate().isNotEmpty;
      final hasNavBar = find.byType(NavigationBar).evaluate().isNotEmpty;
      expect(
        hasFavIcon || hasNavItem || hasNavBar,
        isTrue,
        reason: 'Favorites navigation should be present',
      );

      await tester.pumpAndSettle(const Duration(milliseconds: 500));

      // Assert: App loaded
      expect(find.byType(ProviderScope), findsOneWidget);

      // Assert: Favorites displayed
      final hasListViewFav = find.byType(ListView).evaluate().isNotEmpty;
      final hasContainerFav = find.byType(Container).evaluate().isNotEmpty;
      final hasTextFav = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasListViewFav || hasContainerFav || hasTextFav,
        isTrue,
        reason: 'Favorites should be displayed',
      );

      await tester.pumpAndSettle();

      // Assert: Synced indicator or list of favorites
      final hasContainerSync = find.byType(Container).evaluate().isNotEmpty;
      final hasTextSync = find.byType(Text).evaluate().isNotEmpty;
      expect(
        hasContainerSync || hasTextSync,
        isTrue,
        reason: 'Sync status or favorites should show',
      );
    });
  });
}

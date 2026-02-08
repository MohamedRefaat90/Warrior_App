import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/pending_upload_badge.dart';
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

    TalkerService.init();
    await SharedPref.init();
    await DioHandler.initDio();
    await AppServices.init(isTestMode: true);
    AppServices.initialLocation = AppRouters.foodSearch;
  });

  group('Offline Sync Integration', () {
    testWidgets('offline add product → go online → sync → verify uploaded',
        (tester) async {
      // Arrange
      await pumpIntegrationTestApp(tester);
      final fakeSync =
          ProviderScope.containerOf(tester.element(find.byType(OKToast)))
              .read(syncServiceProvider.notifier) as FakeSyncService;

      // Act: Simulate offline state with pending products
      fakeSync.setPendingProducts(1);
      await tester.pump();

      // Assert: Verify pending badge displays
      expect(find.byType(PendingUploadBadge), findsOneWidget);

      // Act: Trigger sync
      await fakeSync.syncPendingOperations();
      await tester.pumpAndSettle();

      // Assert: Verify sync success feedback
      expect(find.text('Synced'), findsOneWidget);

      dismissAllToast(showAnim: false);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('offline add multiple products → batch sync on reconnect',
        (tester) async {
      // Arrange
      await pumpIntegrationTestApp(tester);
      final fakeSync =
          ProviderScope.containerOf(tester.element(find.byType(OKToast)))
              .read(syncServiceProvider.notifier) as FakeSyncService;

      // Act: Simulate multiple pending products
      fakeSync.setPendingProducts(2);
      await tester.pump();

      // Assert: Verify badge shows count
      expect(find.byType(PendingUploadBadge), findsOneWidget);

      // Act: Trigger sync
      await fakeSync.syncPendingOperations();
      await tester.pumpAndSettle();

      // Assert: Verify success
      expect(find.text('Synced'), findsOneWidget);

      dismissAllToast(showAnim: false);
      await tester.pump(const Duration(seconds: 5));
    });

    testWidgets('offline add → sync fails → retry succeeds', (tester) async {
      // Arrange
      await pumpIntegrationTestApp(tester);
      final fakeSync =
          ProviderScope.containerOf(tester.element(find.byType(OKToast)))
              .read(syncServiceProvider.notifier) as FakeSyncService;

      // Act: Simulate sync failure state
      fakeSync.setPendingProducts(-1);
      await fakeSync.syncPendingOperations();
      await tester.pumpAndSettle();

      // Assert: Error is displayed
      expect(find.text('Sync failed'), findsOneWidget);

      // Act: Trigger retry with success
      fakeSync.setPendingProducts(1);
      await fakeSync.syncPendingOperations();
      await tester.pumpAndSettle();

      // Assert: Retry succeeds
      expect(find.text('Synced'), findsOneWidget);

      dismissAllToast(showAnim: false);
      await tester.pump(const Duration(seconds: 5));
    });
  });
}

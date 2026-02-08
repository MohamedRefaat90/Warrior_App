import 'package:Warrior/core/localization/arb/app_localizations.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/favorites_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/food_search_provider.dart';
import 'package:Warrior/routing.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:oktoast/oktoast.dart';

List<Override> getIntegrationTestOverrides() {
  return [
    syncServiceProvider.overrideWith(() => FakeSyncService()),
    favoritesProvider.overrideWith(() => FakeFavoritesNotifier()),
    recentlyScannedProvider.overrideWith((ref) => [
          ProductEntity(
            barcode: '123456789',
            productName: 'Test Product',
            brands: 'Test Brand',
            lastUpdated: DateTime.now(),
          ),
        ]),
  ];
}

Future<void> pumpIntegrationTestApp(
  WidgetTester tester, {
  List<Override> overrides = const [],
}) async {
  // Use a unique key for each ProviderScope to avoid "Tried to override a provider twice"
  // which can happen in fast-running tests or when pumpWidget is called multiple times.
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        ...getIntegrationTestOverrides(),
        ...overrides,
      ],
      child: OKToast(
        child: MaterialApp.router(
          title: 'Warrior Test',
          debugShowCheckedModeBanner: false,
          routerConfig: RoutersManager.router,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

class FakeFavoritesNotifier extends FavoritesNotifier {
  final List<ProductEntity> _favorites = [];

  @override
  Future<void> addFavorite(ProductEntity product) async {
    if (!_favorites.any((p) => p.barcode == product.barcode)) {
      _favorites.add(product);
      ref.notifyListeners();
      showToast('Saved to favorites');
    }
  }

  @override
  List<ProductEntity> build() => _favorites;

  @override
  Future<void> removeFavorite(String barcode) async {
    _favorites.removeWhere((p) => p.barcode == barcode);
    ref.notifyListeners();
    showToast('Removed from favorites');
  }
}

class FakeSyncService extends SyncService {
  @override
  SyncState build() {
    return const SyncState(
      isLoading: false,
      pendingWorkouts: 0,
      pendingProducts: 0,
    );
  }

  @override
  void refreshPendingCounts() {}

  void setPendingProducts(int count) {
    state = state.copyWith(pendingProducts: count);
  }

  @override
  Future<void> syncAll() async {
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, pendingProducts: 0);
    showToast('Upload successful');
  }

  @override
  Future<void> syncPendingOperations() async {
    if (state.pendingProducts == -1) {
      showToast('Sync failed');
      return;
    }
    state = state.copyWith(isLoading: true);
    state = state.copyWith(isLoading: false, pendingProducts: 0);
    showToast('Synced');
  }
}

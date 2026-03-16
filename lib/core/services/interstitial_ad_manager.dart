import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manager for interstitial ads with automatic loading and retry logic.
///
/// This class manages interstitial ads throughout the app with support for:
/// - Multiple unique ad unit IDs
/// - Automatic ad loading and retry on failure
/// - Instance caching (same ad unit ID returns same instance)
/// - Automatic test/production ad switching based on debug mode
///
/// ## Basic Usage (Default Instance):
/// ```dart
/// // Load ad early (e.g., in initState)
/// InterstitialAdManager.instance.loadAd();
///
/// // Show ad when needed
/// InterstitialAdManager.instance.showAd(
///   onAdDismissed: () {
///     // Navigate or perform action after ad closes
///     context.pushNamed(AppRouters.details);
///   },
/// );
/// ```
///
/// ## Multiple Ad Units (Different Features):
/// ```dart
/// // Create separate instances for different app sections
/// final workoutAd = InterstitialAdManager.forAdUnit('ca-app-pub-xxxxx/11111');
/// final nutritionAd = InterstitialAdManager.forAdUnit('ca-app-pub-xxxxx/22222');
/// final exerciseAd = InterstitialAdManager.forAdUnit('ca-app-pub-xxxxx/33333');
///
/// // Load ads early
/// workoutAd.loadAd();
/// nutritionAd.loadAd();
/// exerciseAd.loadAd();
///
/// // Show specific ad when needed
/// workoutAd.showAd(onAdDismissed: () { /* ... */ });
/// ```
///
/// ## Best Practices:
/// ```dart
/// // 1. Load ads early (in initState or app startup)
/// @override
/// void initState() {
///   super.initState();
///   InterstitialAdManager.instance.loadAd();
/// }
///
/// // 2. Check if ad is ready before showing (optional)
/// if (InterstitialAdManager.instance.isReady) {
///   InterstitialAdManager.instance.showAd(onAdDismissed: () { /* ... */ });
/// } else {
///   // Ad not ready, proceed without showing
///   navigateToNextScreen();
/// }
///
/// // 3. Clean up all instances when app closes
/// @override
/// void dispose() {
///   InterstitialAdManager.disposeAll();
///   super.dispose();
/// }
/// ```
///
/// ## Important Notes:
/// - Ads auto-reload after being shown or failed
/// - Failed loads retry automatically after 30 seconds
/// - In debug mode, test ads are shown automatically
/// - If ad not ready, `onAdDismissed` callback is called immediately
/// - Same ad unit ID returns the cached instance (singleton per ad unit)
class InterstitialAdManager {
  /// Cache of ad manager instances keyed by ad unit ID
  static final Map<String, InterstitialAdManager> _instances = {};

  /// Global kill-switch set from [systemSettingsProvider].
  /// When false, all load and show calls are no-ops.
  static bool showAds = true;

  static const _testAdUnitId = 'ca-app-pub-3940256099942544/1033173712';

  static const _retryDelay = Duration(seconds: 30);

  static const _logTag = 'INTERSTITIAL_AD';

  /// Default instance (uses test ad in debug mode)
  static InterstitialAdManager get instance => forAdUnit('');
  final String adUnitId;

  InterstitialAd? _ad;

  bool _isLoaded = false;
  bool _isLoading = false;
  InterstitialAdManager._({required this.adUnitId});

  /// Returns true if an ad is loaded and ready to show
  bool get isReady => _isLoaded && _ad != null;

  /// Ad unit ID - automatically switches between test and production
  String get _adUnitId => kDebugMode ? _testAdUnitId : adUnitId;

  /// Disposes the current ad and resets state
  void dispose() {
    _ad?.dispose();
    _ad = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Loads an interstitial ad if not already loaded or loading
  Future<void> loadAd() async {
    if (!InterstitialAdManager.showAds) return;
    if (_isLoaded || _isLoading) return;

    _isLoading = true;
    TalkerService.info('Loading interstitial ad', _logTag);

    try {
      await MobileAds.instance.updateRequestConfiguration(config);
      await MobileAds.instance.initialize();

      await InterstitialAd.load(
        adUnitId: _adUnitId,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            _ad = ad;
            _isLoaded = true;
            _isLoading = false;
            TalkerService.info('Interstitial ad loaded', _logTag);
          },
          onAdFailedToLoad: (error) {
            _isLoading = false;
            TalkerService.error('Failed to load ad: ${error.message}', _logTag);
            Future.delayed(_retryDelay, loadAd);
          },
        ),
      );
    } catch (e) {
      _isLoading = false;
      TalkerService.error('Failed to load ad: $e', _logTag);
      Future.delayed(_retryDelay, loadAd);
    }
  }

  /// Shows the interstitial ad if available
  ///
  /// [onAdDismissed] - Callback executed after ad dismissal or if no ad available
  void showAd({required VoidCallback onAdDismissed}) {
    if (!InterstitialAdManager.showAds) {
      onAdDismissed();
      return;
    }
    if (!isReady) {
      TalkerService.warning('No ad ready to show', _logTag);
      onAdDismissed();
      loadAd();
      return;
    }

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        TalkerService.info('Ad dismissed', _logTag);
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        onAdDismissed();
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        TalkerService.error('Failed to show ad: ${error.message}', _logTag);
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        onAdDismissed();
        loadAd();
      },
    );

    _ad!.show();
    TalkerService.info('Showing ad', _logTag);
  }

  /// Disposes all ad manager instances
  static void disposeAll() {
    for (final manager in _instances.values) {
      manager.dispose();
    }
    _instances.clear();
  }

  /// Gets or creates an ad manager instance for a specific ad unit ID
  ///
  /// [adUnitId] - Your unique ad unit ID from AdMob
  static InterstitialAdManager forAdUnit(String adUnitId) {
    return _instances.putIfAbsent(
      adUnitId,
      () => InterstitialAdManager._(adUnitId: adUnitId),
    );
  }
}

import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A singleton service that manages interstitial ads throughout the app.
///
/// Usage:
/// ```dart
/// InterstitialAdManager.instance.showAd(
///   onAdDismissed: () {
///     // Your action after ad dismissal
///   },
/// );
/// ```
class InterstitialAdManager {
  static final instance = InterstitialAdManager._();
  InterstitialAd? _ad;

  bool _isLoaded = false;
  bool _isLoading = false;
  InterstitialAdManager._();

  /// Returns true if an ad is ready to show
  bool get isReady => _isLoaded && _ad != null;

  /// Ad unit ID - automatically switches between test and production
  String get _adUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // Test
      : 'ca-app-pub-7417773148722475/2407422168'; // Production

  /// Dispose the ad manager
  void dispose() {
    _ad?.dispose();
    _ad = null;
    _isLoaded = false;
    _isLoading = false;
  }

  /// Load an interstitial ad
  Future<void> loadAd() async {
    if (_isLoaded || _isLoading) return;

    _isLoading = true;
    await MobileAds.instance.updateRequestConfiguration(config);
    await MobileAds.instance.initialize();
    TalkerService.info('Loading interstitial ad', 'INTERSTITIAL_AD');

    await InterstitialAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          _isLoading = false;
          TalkerService.info('Interstitial ad loaded', 'INTERSTITIAL_AD');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          TalkerService.error(
            'Failed to load ad: ${error.message}',
            'INTERSTITIAL_AD',
          );
          // Retry after delay
          Future.delayed(const Duration(seconds: 30), loadAd);
        },
      ),
    );
  }

  /// Preload ad on app start
  void preloadAd() {
    TalkerService.info('Preloading ad', 'INTERSTITIAL_AD');
    loadAd();
  }

  /// Show the interstitial ad
  ///
  /// [onAdDismissed] - Called after ad is dismissed or if no ad is available
  void showAd({required VoidCallback onAdDismissed}) {
    if (_ad == null || !_isLoaded) {
      TalkerService.warning('No ad ready to show', 'INTERSTITIAL_AD');
      onAdDismissed();
      loadAd();
      return;
    }

    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        TalkerService.info('Ad dismissed', 'INTERSTITIAL_AD');
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        onAdDismissed();
        loadAd(); // Preload next ad
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        TalkerService.error(
            'Failed to show ad: ${error.message}', 'INTERSTITIAL_AD');
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        onAdDismissed();
        loadAd();
      },
    );

    _ad!.show();
    TalkerService.info('Showing ad', 'INTERSTITIAL_AD');
  }
}

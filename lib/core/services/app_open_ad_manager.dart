import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppOpenAdManager {
  static final instance = AppOpenAdManager._();
  static const _minTimeBetweenAds = Duration(minutes: 3);

  AppOpenAd? _ad;

  bool _isLoaded = false;
  bool _isLoading = false;
  bool _isShowingAd = false;
  DateTime? _lastAdShownTime;
  AppOpenAdManager._();

  String get _adUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/9257395921'
      : 'ca-app-pub-7417773148722475/1584778167';

  Future<void> initialize({bool showAds = true}) async {
    if (!showAds) return;
    await MobileAds.instance.updateRequestConfiguration(config);
    await MobileAds.instance.initialize();
    loadAd();
  }

  Future<void> loadAd() async {
    if (_isLoaded || _isLoading) return;

    _isLoading = true;
    TalkerService.info('Loading app open ad', 'APP_OPEN_AD');

    await AppOpenAd.load(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          _ad = ad;
          _isLoaded = true;
          _isLoading = false;
          TalkerService.info('App open ad loaded', 'APP_OPEN_AD');
        },
        onAdFailedToLoad: (error) {
          _isLoading = false;
          TalkerService.error(
              'Failed to load: ${error.message}', 'APP_OPEN_AD');
          Future.delayed(const Duration(seconds: 30), loadAd);
        },
      ),
    );
  }

  void showAdIfAvailable({bool showAds = true}) {
    if (!showAds) return;
    if (_isShowingAd) return;

    if (_lastAdShownTime != null) {
      final timeSince = DateTime.now().difference(_lastAdShownTime!);
      if (timeSince < _minTimeBetweenAds) return;
    }

    if (_ad == null || !_isLoaded) {
      loadAd();
      return;
    }

    _isShowingAd = true;
    _ad!.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) {
        _lastAdShownTime = DateTime.now();
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        _isShowingAd = false;
        loadAd();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        TalkerService.error('Failed to show: ${error.message}', 'APP_OPEN_AD');
        ad.dispose();
        _ad = null;
        _isLoaded = false;
        _isShowingAd = false;
        loadAd();
      },
    );

    _ad!.show();
  }
}

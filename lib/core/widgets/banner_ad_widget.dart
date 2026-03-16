import 'package:Warrior/features/Home/presentation/provider/system_settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A reusable banner ad widget that handles loading and displaying AdMob banners.
///
/// This widget manages its own ad lifecycle and provides consistent
/// ad placement across the app. Respects the global [systemSettingsProvider]
/// showAds flag — returns [SizedBox.shrink] when ads are disabled.
class BannerAdWidget extends ConsumerStatefulWidget {
  final String adUnitId;

  const BannerAdWidget({super.key, required this.adUnitId});

  @override
  ConsumerState<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends ConsumerState<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
    if (!ref.watch(systemSettingsProvider).showAds) {
      return const SizedBox.shrink();
    }
    if (!_isLoaded || _bannerAd == null) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    final adUnitId =
        kDebugMode ? 'ca-app-pub-3940256099942544/9214589741' : widget.adUnitId;

    _bannerAd = BannerAd(
      size: AdSize.banner,
      request: const AdRequest(),
      adUnitId: adUnitId,
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
          }
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
        },
      ),
    )..load();
  }
}

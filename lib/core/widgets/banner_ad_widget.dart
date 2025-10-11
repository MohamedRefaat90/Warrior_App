import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A reusable banner ad widget that handles loading and displaying AdMob banners.
///
/// This widget manages its own ad lifecycle and provides consistent
/// ad placement across the app.
class BannerAdWidget extends StatefulWidget {
  /// Optional custom ad unit ID. If not provided, uses default banner IDs.
  final String? adUnitId;

  const BannerAdWidget({
    super.key,
    this.adUnitId,
  });

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  Widget build(BuildContext context) {
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
    final adUnitId = widget.adUnitId ??
        (kDebugMode
            ? 'ca-app-pub-3940256099942544/6300978111' // Test ID
            : 'ca-app-pub-7417773148722475/3352321251'); // Production ID

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

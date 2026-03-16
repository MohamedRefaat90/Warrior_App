import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Home/presentation/provider/system_settings_provider.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Reusable native ad widget that matches app design.
/// Respects the global [systemSettingsProvider] showAds flag —
/// returns [SizedBox.shrink] when ads are disabled.
class NativeAdWidget extends ConsumerStatefulWidget {
  const NativeAdWidget({super.key});

  @override
  ConsumerState<NativeAdWidget> createState() => _NativeAdWidgetState();
}

class _NativeAdWidgetState extends ConsumerState<NativeAdWidget> {
  NativeAd? _ad;
  bool _isLoaded = false;

  String get _adUnitId => kDebugMode
      ? 'ca-app-pub-3940256099942544/2247696110' // Test Native
      : 'ca-app-pub-7417773148722475/6053548353'; // Production Native

  @override
  Widget build(BuildContext context) {
    // if (!ref.watch(systemSettingsProvider).showAds) {
    //   return const SizedBox.shrink();
    // }
    if (!_isLoaded || _ad == null) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Use the available width from parent constraints
        final availableWidth = constraints.maxWidth;
        final availableHeight = constraints.maxHeight.isFinite
            ? constraints.maxHeight
            : 300.0; // Default height if infinite

        return Container(
          width: availableWidth,
          height: availableHeight,
          clipBehavior: Clip.hardEdge,
          decoration: const BoxDecoration(),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: availableWidth,
              maxHeight: availableHeight,
            ),
            child: AdWidget(ad: _ad!),
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _ad?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    _ad = NativeAd(
      adUnitId: _adUnitId,
      request: const AdRequest(),
      listener: NativeAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() => _isLoaded = true);
            TalkerService.info('Native ad loaded', 'NATIVE_AD');
          }
        },
        onAdFailedToLoad: (ad, error) {
          TalkerService.error('Failed to load: ${error.message}', 'NATIVE_AD');
          ad.dispose();
        },
      ),
      nativeTemplateStyle: NativeTemplateStyle(
        templateType: TemplateType.medium,
        mainBackgroundColor: Colors.white,
        cornerRadius: 12.0,
        callToActionTextStyle: NativeTemplateTextStyle(
          textColor: Colors.white,
          backgroundColor: const Color(0xFF1976D2),
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        primaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black87,
          style: NativeTemplateFontStyle.bold,
          size: 16.0,
        ),
        secondaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black54,
          style: NativeTemplateFontStyle.normal,
          size: 14.0,
        ),
        tertiaryTextStyle: NativeTemplateTextStyle(
          textColor: Colors.black45,
          style: NativeTemplateFontStyle.normal,
          size: 12.0,
        ),
      ),
    )..load();
  }
}

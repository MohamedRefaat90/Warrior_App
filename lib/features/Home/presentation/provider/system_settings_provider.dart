import 'package:Warrior/core/services/interstitial_ad_manager.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Home/data/models/system_settings.dart';
import 'package:Warrior/features/Home/data/repo/home_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _kShowAdsKey = 'system_settings_show_ads';

final systemSettingsProvider =
    NotifierProvider.autoDispose<SystemSettingsNotifier, SystemSettings>(
  SystemSettingsNotifier.new,
);

class SystemSettingsNotifier extends Notifier<SystemSettings> {
  @override
  SystemSettings build() {
    ref.keepAlive();
    _loadSettings();
    return SystemSettings.defaultSettings();
  }

  Future<void> _loadSettings() async {
    final cached = await _readCache();
    final fetched = await ref.read(homeRepo).getSystemSettings();

    if (fetched != null) {
      await _writeCache(fetched);
      TalkerService.info(
        'SystemSettings fetched: showAds=${fetched.showAds}',
        'SYSTEM-SETTINGS',
      );
      InterstitialAdManager.showAds = fetched.showAds;
      state = fetched;
      return;
    }

    if (cached != null) {
      TalkerService.info(
        'SystemSettings using cache: showAds=${cached.showAds}',
        'SYSTEM-SETTINGS',
      );
      InterstitialAdManager.showAds = cached.showAds;
      state = cached;
      return;
    }

    TalkerService.error(
      'SystemSettings unavailable — using safe default (showAds=false)',
      'SYSTEM-SETTINGS',
    );
    // state already set to defaultSettings() in build()
  }

  Future<SystemSettings?> _readCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (!prefs.containsKey(_kShowAdsKey)) return null;
      return SystemSettings(showAds: prefs.getBool(_kShowAdsKey) ?? false);
    } catch (e) {
      TalkerService.error(
        'Error reading settings cache: $e',
        'SYSTEM-SETTINGS',
      );
      return null;
    }
  }

  Future<void> _writeCache(SystemSettings settings) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_kShowAdsKey, settings.showAds);
    } catch (e) {
      TalkerService.error(
        'Error writing settings cache: $e',
        'SYSTEM-SETTINGS',
      );
    }
  }
}

import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for unified app settings (theme + locale)
final appSettingsProvider = NotifierProvider<AppSettingsNotifier, AppSettings>(
  AppSettingsNotifier.new,
);

/// Unified app settings state containing theme and locale preferences
@immutable
class AppSettings {
  final ThemeMode themeMode;
  final Locale locale;

  const AppSettings({required this.themeMode, required this.locale});

  @override
  int get hashCode => Object.hash(themeMode, locale);

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AppSettings &&
        other.themeMode == themeMode &&
        other.locale == locale;
  }

  AppSettings copyWith({
    ThemeMode? themeMode,
    Locale? locale,
  }) {
    return AppSettings(
      themeMode: themeMode ?? this.themeMode,
      locale: locale ?? this.locale,
    );
  }
}

/// App settings notifier using Riverpod 3 best practices
/// Manages theme mode and locale state with persistence
class AppSettingsNotifier extends Notifier<AppSettings> {
  @override
  AppSettings build() {
    // Load and return persisted settings on initialization
    return _loadSettings();
  }

  String fontFamily() {
    return state.locale.languageCode == 'ar' ? 'Cairo' : 'Poppins';
  }

  /// Set dark mode
  Future<void> setDarkMode() async {
    state = state.copyWith(themeMode: ThemeMode.dark);
    await _persistTheme(ThemeMode.dark);
    TalkerService.info('Theme changed to dark mode', 'SETTINGS');
  }

  /// Set app language/locale
  Future<void> setLanguage(Locale locale) async {
    state = state.copyWith(locale: locale);
    await _persistLocale(locale);
    TalkerService.info(
      'Language changed to ${locale.languageCode}',
      'SETTINGS',
    );
  }

  /// Set light mode
  Future<void> setLightMode() async {
    state = state.copyWith(themeMode: ThemeMode.light);
    await _persistTheme(ThemeMode.light);
    TalkerService.info('Theme changed to light mode', 'SETTINGS');
  }

  /// Set system mode (follows device settings)
  Future<void> setSystemMode() async {
    state = state.copyWith(themeMode: ThemeMode.system);
    await _persistTheme(ThemeMode.system);
    TalkerService.info('Theme changed to system mode', 'SETTINGS');
  }

  /// Load locale from SharedPreferences
  Locale _loadLocale() {
    try {
      final savedLocale = SharedPref.getString(StorageKeys.locale);
      if (savedLocale != null) {
        switch (savedLocale) {
          case 'en':
            return const Locale('en');
          case 'ar':
            return const Locale('ar');
          default:
            return const Locale('en');
        }
      } else {
        // First time launch, use English as default
        _persistLocale(const Locale('en'));
        return const Locale('en');
      }
    } catch (e) {
      TalkerService.error('Failed to load locale', 'SETTINGS', e);
      return const Locale('en');
    }
  }

  /// Load settings from SharedPreferences
  AppSettings _loadSettings() {
    try {
      final themeMode = _loadThemeMode();
      final locale = _loadLocale();

      TalkerService.info(
        'Settings loaded: theme=${themeMode.name}, locale=${locale.languageCode}',
        'SETTINGS',
      );

      return AppSettings(
        themeMode: themeMode,
        locale: locale,
      );
    } catch (e) {
      TalkerService.error('Failed to load settings', 'SETTINGS', e);
      return const AppSettings(
        themeMode: ThemeMode.system,
        locale: Locale('en'),
      );
    }
  }

  /// Load theme mode from SharedPreferences
  ThemeMode _loadThemeMode() {
    try {
      final savedTheme = SharedPref.getString(StorageKeys.themeMode);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            return ThemeMode.light;
          case 'dark':
            return ThemeMode.dark;
          case 'system':
            return ThemeMode.system;
          default:
            return ThemeMode.system;
        }
      } else {
        // First time launch, use system theme
        _persistTheme(ThemeMode.system);
        return ThemeMode.system;
      }
    } catch (e) {
      TalkerService.error('Failed to load theme mode', 'SETTINGS', e);
      return ThemeMode.system;
    }
  }

  /// Persist locale to SharedPreferences
  Future<void> _persistLocale(Locale locale) async {
    try {
      await SharedPref.setString(StorageKeys.locale, locale.languageCode);
      TalkerService.info(
        'Locale persisted: ${locale.languageCode}',
        'SETTINGS',
      );
    } catch (e) {
      TalkerService.error('Failed to persist locale', 'SETTINGS', e);
    }
  }

  /// Persist theme mode to SharedPreferences
  Future<void> _persistTheme(ThemeMode mode) async {
    try {
      String themeString;
      switch (mode) {
        case ThemeMode.light:
          themeString = 'light';
          break;
        case ThemeMode.dark:
          themeString = 'dark';
          break;
        case ThemeMode.system:
          themeString = 'system';
          break;
      }
      await SharedPref.setString(StorageKeys.themeMode, themeString);
      TalkerService.info('Theme mode persisted: $themeString', 'SETTINGS');
    } catch (e) {
      TalkerService.error('Failed to persist theme mode', 'SETTINGS', e);
    }
  }
}

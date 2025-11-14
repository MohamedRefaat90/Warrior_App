import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);

/// Theme mode notifier using Riverpod 3 best practices
/// Manages theme state and persistence
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load and return persisted theme mode on initialization
    return _loadThemeMode();
  }

  /// Set dark mode
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _persistThemeMode(ThemeMode.dark);
    TalkerService.info('Theme changed to dark mode', 'THEME');
  }

  /// Set light mode
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _persistThemeMode(ThemeMode.light);
    TalkerService.info('Theme changed to light mode', 'THEME');
  }

  /// Set system mode (follows device settings)
  Future<void> setSystemMode() async {
    state = ThemeMode.system;
    await _persistThemeMode(ThemeMode.system);
    TalkerService.info('Theme changed to system mode', 'THEME');
  }

  /// Toggle between light and dark mode (ignores system)
  Future<void> toggleTheme() async {
    if (state == ThemeMode.light) {
      await setDarkMode();
    } else {
      await setLightMode();
    }
  }

  /// Load theme mode from SharedPreferences
  ThemeMode _loadThemeMode() {
    try {
      final savedTheme = SharedPref.getString(StorageKeys.themeMode);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            TalkerService.info('Loaded light theme from storage', 'THEME');
            return ThemeMode.light;
          case 'dark':
            TalkerService.info('Loaded dark theme from storage', 'THEME');
            return ThemeMode.dark;
          case 'system':
            TalkerService.info('Loaded system theme from storage', 'THEME');
            return ThemeMode.system;
          default:
            TalkerService.info('Invalid theme value, using system', 'THEME');
            return ThemeMode.system;
        }
      } else {
        // First time launch, use system theme
        _persistThemeMode(ThemeMode.system);
        TalkerService.info('First launch, using system theme', 'THEME');
        return ThemeMode.system;
      }
    } catch (e) {
      TalkerService.error('Failed to load theme mode', 'THEME', e);
      return ThemeMode.system;
    }
  }

  /// Persist theme mode to SharedPreferences
  Future<void> _persistThemeMode(ThemeMode mode) async {
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
      TalkerService.info('Theme mode persisted: $themeString', 'THEME');
    } catch (e) {
      TalkerService.error('Failed to persist theme mode', 'THEME', e);
    }
  }
}

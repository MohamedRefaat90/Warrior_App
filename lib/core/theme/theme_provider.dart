import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Theme mode notifier using Riverpod 3 best practices
/// Manages theme state and persistence
class ThemeModeNotifier extends Notifier<ThemeMode> {
  @override
  ThemeMode build() {
    // Load persisted theme mode on initialization
    _loadThemeMode();
    return ThemeMode.system; // Default until loaded
  }

  /// Load theme mode from SharedPreferences
  void _loadThemeMode() {
    try {
      final savedTheme = SharedPref.getString(StorageKeys.themeMode);
      if (savedTheme != null) {
        switch (savedTheme) {
          case 'light':
            state = ThemeMode.light;
            TalkerService.info('Loaded light theme from storage', 'THEME');
            break;
          case 'dark':
            state = ThemeMode.dark;
            TalkerService.info('Loaded dark theme from storage', 'THEME');
            break;
          case 'system':
            state = ThemeMode.system;
            TalkerService.info('Loaded system theme from storage', 'THEME');
            break;
          default:
            state = ThemeMode.system;
            TalkerService.info('Invalid theme value, using system', 'THEME');
        }
      } else {
        // First time launch, use system theme
        state = ThemeMode.system;
        _persistThemeMode(ThemeMode.system);
        TalkerService.info('First launch, using system theme', 'THEME');
      }
    } catch (e) {
      TalkerService.error('Failed to load theme mode', 'THEME', e);
      state = ThemeMode.system;
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

  /// Set light mode
  Future<void> setLightMode() async {
    state = ThemeMode.light;
    await _persistThemeMode(ThemeMode.light);
    TalkerService.info('Theme changed to light mode', 'THEME');
  }

  /// Set dark mode
  Future<void> setDarkMode() async {
    state = ThemeMode.dark;
    await _persistThemeMode(ThemeMode.dark);
    TalkerService.info('Theme changed to dark mode', 'THEME');
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
}

/// Provider for theme mode
final themeModeProvider = NotifierProvider<ThemeModeNotifier, ThemeMode>(
  ThemeModeNotifier.new,
);




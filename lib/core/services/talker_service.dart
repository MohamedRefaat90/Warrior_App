import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:talker_flutter/talker_flutter.dart';

/// Global Talker instance for logging throughout the app
class TalkerService {
  static late Talker _talker;
  static bool _isInitialized = false;

  /// Get the Talker instance
  static Talker get instance {
    if (!_isInitialized) {
      throw StateError(
        'TalkerService must be initialized before use. '
        'Call TalkerService.init() first.',
      );
    }
    return _talker;
  }

  /// Check if Talker is initialized
  static bool get isInitialized => _isInitialized;

  // Convenience methods for common log levels

  static void debug(String message, [String? tag]) {
    if (!_isInitialized) return;
    final logMessage = tag != null ? '[$tag] $message' : message;
    _talker.debug(logMessage);
  }

  static void error(
    String message, [
    String? tag,
    dynamic error,
    StackTrace? stackTrace,
  ]) {
    if (!_isInitialized) return;

    final logMessage = tag != null ? '[$tag] $message' : message;
    _talker.error(logMessage, error, stackTrace);

    // Send to Crashlytics in production
    if (!kDebugMode && error != null) {
      FirebaseCrashlytics.instance.recordError(
        error,
        stackTrace,
        reason: message,
        fatal: false,
      );
    }
  }

  static void info(String message, [String? tag]) {
    if (!_isInitialized) return;
    final logMessage = tag != null ? '[$tag] $message' : message;
    _talker.info(logMessage);
  }

  /// Initialize Talker with custom settings
  static void init() {
    _talker = TalkerFlutter.init(
        settings: TalkerSettings(
            enabled: true,
            useConsoleLogs: kDebugMode,
            useHistory: true,
            maxHistoryItems: 1000,
            colors: {"info": AnsiPen()..cyan()}));

    _isInitialized = true;
    _talker.info('Talker initialized successfully');
  }

  static void warning(String message, [String? tag, dynamic error]) {
    if (!_isInitialized) return;
    final logMessage = tag != null ? '[$tag] $message' : message;
    _talker.warning(logMessage, error);
  }
}

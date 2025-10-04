import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';

class AppLogger {
  static bool _isInitialized = false;

  static void authEvent(String event, [String? userId]) {
    info('Auth event: $event ${userId != null ? 'for user $userId' : ''}',
        'AUTH');
  }

  static void cacheOperation(String operation, String key,
      [bool success = true]) {
    if (success) {
      debug('Cache $operation: $key', 'CACHE');
    } else {
      warning('Cache $operation failed: $key', 'CACHE');
    }
  }

  static void debug(String message, [String? tag]) {
    _log(LogLevel.debug, message, tag);
  }

  static void error(String message,
      [String? tag, dynamic error, StackTrace? stackTrace]) {
    _log(LogLevel.error, message, tag, error, stackTrace);

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
    _log(LogLevel.info, message, tag);
  }

  static void init() {
    _isInitialized = true;
  }

  // Helper methods for common scenarios
  static void networkRequest(String url, String method) {
    debug('$method request to: $url', 'NETWORK');
  }

  static void networkResponse(String url, int statusCode, [String? response]) {
    info('Response from $url: $statusCode', 'NETWORK');
    if (response != null && kDebugMode) {
      debug('Response body: $response', 'NETWORK');
    }
  }

  static void userAction(String action, [Map<String, dynamic>? data]) {
    info('User action: $action', 'USER');
    if (data != null && kDebugMode) {
      debug('Action data: $data', 'USER');
    }
  }

  static void warning(String message, [String? tag, dynamic error]) {
    _log(LogLevel.warning, message, tag, error);
  }

  static String _getLevelPrefix(LogLevel level) {
    switch (level) {
      case LogLevel.debug:
        return '[DEBUG]';
      case LogLevel.info:
        return '[INFO]';
      case LogLevel.warning:
        return '[WARNING]';
      case LogLevel.error:
        return '[ERROR]';
    }
  }

  static void _log(LogLevel level, String message,
      [String? tag, dynamic error, StackTrace? stackTrace]) {
    if (!_isInitialized) return;

    final timestamp = DateTime.now().toIso8601String();
    final tagStr = tag != null ? '[$tag] ' : '';
    final prefix = _getLevelPrefix(level);

    // final logMessage = '$timestamp $prefix $tagStr$message';
    final logMessage = '$prefix $tagStr$message';

    // Only show logs in debug mode
    if (kDebugMode) {
      debugPrint(logMessage);
      if (error != null) {
        debugPrint('Error details: $error');
      }
      if (stackTrace != null) {
        debugPrint('Stack trace: $stackTrace');
      }
    }
  }
}

enum LogLevel { debug, info, warning, error }

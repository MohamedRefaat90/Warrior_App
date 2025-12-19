import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:talker_dio_logger/talker_dio_logger.dart';

// Provider for Dio instance - can be easily overridden in tests
final dioProvider = Provider<Dio>((ref) {
  if (!DioHandler._isInitialized) {
    throw StateError(
        'DioHandler must be initialized before use. Call DioHandler.initDio() first.');
  }
  return DioHandler.dio;
});

class DioHandler {
  static late Dio dio;
  static bool _isInitialized = false;

  // Getter to check if Dio is initialized
  static bool get isInitialized => _isInitialized;

  // Method to create a test Dio instance
  static Dio createTestDio() {
    return Dio()
      ..options.baseUrl = 'https://test.api.com'
      ..options.connectTimeout = const Duration(seconds: 5)
      ..options.receiveTimeout = const Duration(seconds: 5)
      ..options.headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      };
  }

  static Future<void> initDio() async {
    try {
      const Duration timeout = Duration(seconds: 30);

      dio = Dio()
        ..options.baseUrl = ApisUrl.baseurl
        ..options.connectTimeout = timeout
        ..options.receiveTimeout = timeout
        ..options.headers = {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        };

      // Add Talker Dio Logger with Talker instance
      if (kDebugMode) {
        // Debug mode: Log everything
        dio.interceptors.add(TalkerDioLogger(
          talker: TalkerService.instance,
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseHeaders: false,
            printResponseMessage: false,
            printResponseData: false,
            printErrorData: false,
            printErrorHeaders: false,
            printErrorMessage: false,
            printRequestData: false,
          ),
        ));
      } else {
        // Production: Only log errors, not detailed requests/responses
        dio.interceptors.add(TalkerDioLogger(
          talker: TalkerService.instance,
          settings: const TalkerDioLoggerSettings(
            printRequestHeaders: false,
            printResponseHeaders: false,
            printResponseMessage: false,
            printResponseData: false,
            printErrorData: true,
            printErrorHeaders: false,
            printErrorMessage: true,
            printRequestData: false,
          ),
        ));
      }

      // Add authorization and request/response interceptor
      dio.interceptors.add(InterceptorsWrapper(
        onRequest: (options, handler) async {
          try {
            final String? token =
                await SecureStorageHandler.read(key: StorageKeys.token);
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = "Token $token";
            }

            return handler.next(options);
          } catch (e) {
            TalkerService.error('Error in request interceptor', 'DIO', e);
            return handler.next(options);
          }
        },
        onResponse: (response, handler) {
          try {
            return handler.next(response);
          } catch (e) {
            TalkerService.error('Error in response interceptor', 'DIO', e);
            return handler.next(response);
          }
        },
        onError: (error, handler) {
          try {
            TalkerService.error(
              'Network request failed: ${error.requestOptions.uri}',
              'DIO',
              error,
            );
            return handler.next(error);
          } catch (e) {
            TalkerService.error('Error in error interceptor', 'DIO', e);
            return handler.next(error);
          }
        },
      ));

      _isInitialized = true;
      TalkerService.info('Dio initialized successfully', 'DIO');
    } catch (e, stackTrace) {
      TalkerService.error('Failed to initialize Dio', 'DIO', e, stackTrace);
      rethrow;
    }
  }

  // Method to reset for testing
  static void resetForTesting() {
    _isInitialized = false;
  }
}

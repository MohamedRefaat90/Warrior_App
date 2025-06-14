import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:Warrior/routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class AppServices {
  static String? initialLocation;

  static Future<void> init() async {
    try {
      AppLogger.info('Starting app services initialization', 'SERVICES');

      // Set preferred orientations
      await _setPreferredOrientations();

      // Initialize Firebase first (for Crashlytics)
      await _initializeFirebase();

      // Setup error handlers
      _setupErrorHandlers();

      // Initialize other services
      await _initializeServices();

      AppLogger.info(
          'App services initialization completed successfully', 'SERVICES');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to initialize app services', 'SERVICES', e, stackTrace);

      // Send to Crashlytics if available
      try {
        await FirebaseCrashlytics.instance.recordError(
          e,
          stackTrace,
          fatal: true,
          information: ['App Services Initialization Failed'],
        );
      } catch (_) {
        // Ignore Crashlytics errors during initialization
      }

      rethrow;
    }
  }

  static Future<void> _initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      AppLogger.info('Firebase initialized', 'SERVICES');

      // Set Crashlytics collection based on release mode
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      AppLogger.info('Crashlytics collection configured', 'SERVICES');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to initialize Firebase', 'SERVICES', e, stackTrace);
      throw Exception('Critical service initialization failed: Firebase');
    }
  }

  static Future<void> _initializeServices() async {
    const List<String> criticalServices = ['SharedPref', 'Dio', 'Hive'];
    const List<String> nonCriticalServices = ['Connectivity', 'Routing'];

    // Initialize critical services first
    for (final serviceName in criticalServices) {
      try {
        switch (serviceName) {
          case 'SharedPref':
            await SharedPref.init();
            break;
          case 'Dio':
            await DioHandler.initDio();
            break;
          case 'Hive':
            await HiveManager.init();
            break;
        }
        AppLogger.info('$serviceName initialized successfully', 'SERVICES');
      } catch (e, stackTrace) {
        AppLogger.error(
            'Failed to initialize $serviceName', 'SERVICES', e, stackTrace);
        throw Exception('Critical service initialization failed: $serviceName');
      }
    }

    // Initialize non-critical services (don't fail if these fail)
    for (final serviceName in nonCriticalServices) {
      try {
        switch (serviceName) {
          case 'Connectivity':
            await ConnectivityChecker.checkConnectivity();
            break;
          case 'Routing':
            initialLocation = await RoutersManager.routingChecker();
            break;
        }
        AppLogger.info('$serviceName initialized successfully', 'SERVICES');
      } catch (e, stackTrace) {
        AppLogger.warning('Failed to initialize $serviceName', 'SERVICES', e);
        // Continue execution - these are not critical

        if (serviceName == 'Routing') {
          // Provide fallback for routing
          initialLocation = '/home';
          AppLogger.info('Using fallback route: /home', 'SERVICES');
        }
      }
    }
  }

  static Future<void> _setPreferredOrientations() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      AppLogger.info('Orientation preferences set', 'SERVICES');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to set orientation preferences', 'SERVICES', e, stackTrace);
      // Don't throw - this is not critical
    }
  }

  static void _setupErrorHandlers() {
    try {
      // Catch Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails errorDetails) {
        AppLogger.error(
          'Flutter framework error: ${errorDetails.exception}',
          'FLUTTER_ERROR',
          errorDetails.exception,
          errorDetails.stack,
        );

        // Only send to Crashlytics in production
        if (!kDebugMode) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
        }
      };

      // Catch async errors not handled by Flutter
      PlatformDispatcher.instance.onError = (Object error, StackTrace stack) {
        AppLogger.error(
          'Unhandled async error: $error',
          'ASYNC_ERROR',
          error,
          stack,
        );

        // Only send to Crashlytics in production
        if (!kDebugMode) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }

        return true;
      };

      AppLogger.info('Error handlers configured', 'SERVICES');
    } catch (e, stackTrace) {
      AppLogger.error(
          'Failed to setup error handlers', 'SERVICES', e, stackTrace);
      // Don't throw - app can still work without error handlers
    }
  }
}

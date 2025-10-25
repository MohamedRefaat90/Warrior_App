import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:Warrior/routing.dart';
import 'package:cached_video_player_plus/util/migration_utils.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:in_app_review/in_app_review.dart';

/// Firebase background message handler
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {}

abstract class AppServices {
  static String? initialLocation;
  static String? fcmToken;
  static FlutterLocalNotificationsPlugin? _localNotifications;
  static final InAppReview inAppReview = InAppReview.instance;
  // static late AppVersion appVersion;

  /// Initialize app services
  ///
  /// Set [isTestMode] to true when running tests to skip platform-specific
  /// initialization (Firebase, FCM, notifications, etc.)
  static Future<void> init({bool isTestMode = false}) async {
    try {
      TalkerService.init();

      TalkerService.info('Starting app services initialization', 'SERVICES');

      if (!isTestMode) {
        // Set preferred orientations
        await _setPreferredOrientations();

        // Initialize Firebase first (for Crashlytics)
        await _initializeFirebase();

        // Setup error handlers
        _setupErrorHandlers();
      } else {
        TalkerService.info(
            'Running in test mode - skipping native initialization',
            'SERVICES');
        // Set a test FCM token to avoid null reference errors
        fcmToken = 'test_fcm_token_12345';
      }

      // Initialize other services
      await _initializeServices(isTestMode: isTestMode);

      if (!isTestMode) {
        await migrateCachedVideoDataToSharedPreferences();
      }

      TalkerService.info(
          'App services initialization completed successfully', 'SERVICES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to initialize app services', 'SERVICES', e, stackTrace);

      // Send to Crashlytics if available (not in test mode)
      if (!isTestMode) {
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
      }

      rethrow;
    }
  }

  /// Create the notification channel that matches AndroidManifest.xml configuration
  static Future<void> _createNotificationChannel() async {
    try {
      if (_localNotifications == null) return;

      // Create the notification channel
      const AndroidNotificationChannel channel = AndroidNotificationChannel(
        'warrior_notification_channel', // Same ID as in AndroidManifest.xml
        'Warrior Notifications', // Channel name
        description: 'Notifications for Warrior app', // Channel description
        importance: Importance.high,
        enableLights: true,
        enableVibration: true,
        ledColor: Color(0xFFA80B0B), // Red color matching your app theme
        showBadge: true,
        playSound: true,
      );

      await _localNotifications!
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(channel);

      TalkerService.info(
          'Notification channel "warrior_notification_channel" created successfully',
          'FCM');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to create notification channel', 'FCM', e, stackTrace);
      // Don't throw - Firebase will use default channel
    }
  }

  static Future<void> _initializeFirebase() async {
    try {
      FirebaseMessaging.onBackgroundMessage(
          _firebaseMessagingBackgroundHandler);
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      TalkerService.info('Firebase initialized', 'SERVICES');

      // Set Crashlytics collection based on release mode
      await FirebaseCrashlytics.instance
          .setCrashlyticsCollectionEnabled(!kDebugMode);

      TalkerService.info('Crashlytics collection configured', 'SERVICES');

      // Configure Firebase Messaging
      await _setupFirebaseMessaging();

      TalkerService.info('Firebase Messaging configured', 'SERVICES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to initialize Firebase', 'SERVICES', e, stackTrace);
      throw Exception('Critical service initialization failed: Firebase');
    }
  }

  /// Initialize local notifications and create the notification channel
  static Future<void> _initializeLocalNotifications() async {
    try {
      _localNotifications = FlutterLocalNotificationsPlugin();

      // Android initialization settings
      const AndroidInitializationSettings initializationSettingsAndroid =
          AndroidInitializationSettings('@drawable/ic_notification');

      // iOS initialization settings
      const DarwinInitializationSettings initializationSettingsIOS =
          DarwinInitializationSettings(
        requestAlertPermission: false,
        requestBadgePermission: false,
        requestSoundPermission: false,
      );

      // Combined initialization settings
      const InitializationSettings initializationSettings =
          InitializationSettings(
        android: initializationSettingsAndroid,
        iOS: initializationSettingsIOS,
      );

      // Initialize the plugin
      await _localNotifications!.initialize(initializationSettings);

      // Create the notification channel for Android
      await _createNotificationChannel();

      TalkerService.info('Local notifications initialized successfully', 'FCM');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to initialize local notifications', 'FCM', e, stackTrace);
      // Don't throw - notifications can still work without local notifications
    }
  }

  static Future<void> _initializeServices({bool isTestMode = false}) async {
    // In test mode, skip services that require platform channels
    final List<String> criticalServices = isTestMode
        ? [] // Skip all critical services in test mode
        : ['SharedPref', 'Dio', 'Hive'];

    final List<String> nonCriticalServices = isTestMode
        ? [] // Skip all non-critical services in test mode
        : [
            'Connectivity',
            'Routing',
          ];

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
        TalkerService.info('$serviceName initialized successfully', 'SERVICES');
      } catch (e, stackTrace) {
        TalkerService.error(
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
        TalkerService.info('$serviceName initialized successfully', 'SERVICES');
      } catch (e, _) {
        TalkerService.warning(
            'Failed to initialize $serviceName', 'SERVICES', e);
        // Continue execution - these are not critical

        if (serviceName == 'Routing') {
          // Provide fallback for routing
          initialLocation = '/home';
          TalkerService.info('Using fallback route: /home', 'SERVICES');
        }
      }
    }

    // Set fallback route in test mode
    if (isTestMode) {
      initialLocation = '/home';
      TalkerService.info('Test mode: Using fallback route /home', 'SERVICES');
    }
  }

  static Future<void> _setPreferredOrientations() async {
    try {
      await SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
      ]);
      TalkerService.info('Orientation preferences set', 'SERVICES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to set orientation preferences', 'SERVICES', e, stackTrace);
      // Don't throw - this is not critical
    }
  }

  static void _setupErrorHandlers() {
    try {
      // Catch Flutter framework errors
      FlutterError.onError = (FlutterErrorDetails errorDetails) {
        TalkerService.error(
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
        TalkerService.error(
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

      TalkerService.info('Error handlers configured', 'SERVICES');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to setup error handlers', 'SERVICES', e, stackTrace);
      // Don't throw - app can still work without error handlers
    }
  }

  static Future<void> _setupFirebaseMessaging() async {
    try {
      final fcm = FirebaseMessaging.instance;

      // Initialize local notifications and create channel
      await _initializeLocalNotifications();

      // Request notification permissions
      final NotificationSettings settings = await fcm.requestPermission(
        alert: true,
        badge: true,
        sound: true,
        provisional: false,
        announcement: false,
        carPlay: false,
        criticalAlert: false,
      );

      TalkerService.info(
          'Notification permission status: ${settings.authorizationStatus}',
          'FCM');

      // Get FCM token
      fcmToken = await fcm.getToken();

      TalkerService.warning('FCM token: $fcmToken', 'FCM');

      // Handle foreground messages
      FirebaseMessaging.onMessage.listen((RemoteMessage message) {
        TalkerService.info(
            'Received foreground message: ${message.messageId}', 'FCM');

        if (kDebugMode) {
          TalkerService.debug('Message data: ${message.data}', 'FCM');
          if (message.notification != null) {
            TalkerService.debug(
                'Notification: ${message.notification?.title} - ${message.notification?.body}',
                'FCM');
          }
        }

        // Handle foreground message here
        // You can show in-app notifications, update UI, etc.
      });

      // Handle notification taps when app is in background but not terminated
      FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
        TalkerService.info(
            'Notification tapped (background): ${message.messageId}', 'FCM');

        // Handle notification tap here
        // Navigate to specific screen, etc.
      });

      // Check if app was opened from a notification (when app was terminated)
      final RemoteMessage? initialMessage = await fcm.getInitialMessage();
      if (initialMessage != null) {
        TalkerService.info(
            'App opened from notification: ${initialMessage.messageId}', 'FCM');

        // Handle initial message here
        // Navigate to specific screen, etc.
      }

      TalkerService.info('Firebase Messaging setup completed', 'FCM');
    } catch (e, stackTrace) {
      TalkerService.error(
          'Failed to setup Firebase Messaging', 'FCM', e, stackTrace);
      // Don't throw - FCM is not critical for app functionality
    }
  }
}

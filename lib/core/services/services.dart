import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:Warrior/routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

abstract class AppServices {
  static late String? initialLocation;
  static Future<void> init() async {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    await SharedPref.init();
    await DioHandler.initDio();
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };
    // Pass all uncaught asynchronous errors that aren't handled by the Flutter framework to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };
    await HiveManager.init();
    await ConnectivityChecker.checkConnectivity();
    initialLocation = await RoutersManager.routingChecker();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}

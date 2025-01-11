import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:Warrior/routing.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:go_router/go_router.dart';

abstract class AppServices {
  static late GoRouter router;
  static Future<void> init() async {
    await DioHandler.initDio();
    await ConnectivityChecker.init();
    await HiveManager.init();
    router = await routerConfig();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}

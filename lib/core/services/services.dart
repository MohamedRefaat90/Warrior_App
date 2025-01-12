import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:Warrior/routing.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class AppServices {
  static late String? initialLocation;
  static Future<void> init() async {
    await DioHandler.initDio();
    await ConnectivityChecker.init();
    await HiveManager.init();
    initialLocation = await RoutersManager.routingChecker();
    await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform);
  }
}

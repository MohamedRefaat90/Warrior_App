import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class AppServices {
  static Future<void> init() async {
    await DioHandler.initDio();
    await ConnectivityChecker.init();
    await HiveBoxes.init();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class AppServices {
  static Future<void> init() async {
    await DioHandler.initDio();
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

import 'package:Warrior/firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

abstract class AppServices {
  static Future<void> init() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
}

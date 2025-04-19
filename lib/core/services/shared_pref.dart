import 'package:shared_preferences/shared_preferences.dart';

class SharedPref {
  static SharedPreferences? prefs;
  static Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
  }

  static Future<void> setString(String key, String value) async {
    await prefs!.setString(key, value);
  }

  static String? getString(String key) {
    return prefs!.getString(key);
  }

  static Future<void> setBool(String key, bool value) async {
    await prefs!.setBool(key, value);
  }

  static bool? getBool(String key) {
    return prefs!.getBool(key);
  }

  static Future<void> setInt(String key, int value) async {
    await prefs!.setInt(key, value);
  }

  static int? getInt(String key) {
    return prefs!.getInt(key);
  }
}

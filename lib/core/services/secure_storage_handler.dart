import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHandler {
  static const storage = FlutterSecureStorage();

  static Future<void> delete({required String key}) async {
    await storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await storage.deleteAll();
  }

  static Future<String?> read({required String key}) async {
    return await storage.read(key: key);
  }

  static Future<void> write(
      {required String key, required String value}) async {
    await storage.write(key: key, value: value);
  }
}

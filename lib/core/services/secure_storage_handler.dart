import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorageHandler {
  static FlutterSecureStorage _storage = const FlutterSecureStorage();

  @visibleForTesting
  static set storage(FlutterSecureStorage mockStorage) {
    _storage = mockStorage;
  }

  static Future<void> delete({required String key}) async {
    await _storage.delete(key: key);
  }

  static Future<void> deleteAll() async {
    await _storage.deleteAll();
  }

  static Future<String?> read({required String key}) async {
    return await _storage.read(key: key);
  }

  static Future<void> write(
      {required String key, required String value}) async {
    await _storage.write(key: key, value: value);
  }
}

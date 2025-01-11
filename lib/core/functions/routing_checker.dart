import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:flutter/material.dart';

Future<String?> routingChecker() async {
  String? token = await SecureStorageHandler.read(key: 'Token');
  String? isFirstTime = await SecureStorageHandler.read(key: 'isFirstTime');
  try {
    // Handle first-time user
    if (isFirstTime == null) {
      debugPrint('First-time user, redirecting to welcome');
      return AppRouters.welcome;
    }

    // Handle logged-in user
    if (token != null && isFirstTime.isNotEmpty) {
      return AppRouters.home;
    }

    // Handle logged-out user
    if (token == null && isFirstTime.isNotEmpty) {
      return AppRouters.login;
    }

    // Default case
    return null;
  } catch (e) {
    debugPrint('Error in redirect logic: $e');
    return AppRouters.login; // Fallback to login on error
  }
}

import 'dart:io';

import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/data/models/user_model.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider =
    NotifierProvider.autoDispose<LoginNotifier, ProviderStates>(
        LoginNotifier.new);

class LoginNotifier extends Notifier<ProviderStates> {
  late AuthRepo _authRepo;
  UserModel? user;

  @override
  ProviderStates build() {
    _authRepo = ref.read(authRepo);
    ref.keepAlive();
    return ProviderStates();
  }

  void clearError() {
    if (state.errorMessage != null) {
      state = ProviderStates();
    }
  }

  Future<void> googleLogin(String? token) async {
    if (token == null || token.isEmpty) {
      state = ProviderStates(errorMessage: 'Google sign-in was cancelled');
      TalkerService.warning(
          'Google login cancelled - no token provided', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      user = await _authRepo.googleSignIn(token);

      // Save device token if available
      if (AppServices.fcmToken != null && AppServices.fcmToken!.isNotEmpty) {
        await SecureStorageHandler.write(
            key: StorageKeys.deviceToken, value: AppServices.fcmToken!);
        TalkerService.info(
            'Device token saved: ${AppServices.fcmToken}', 'AUTH');
      } else {
        TalkerService.warning(
            'FCM token is null or empty, skipping device token save', 'AUTH');
      }

      state = ProviderStates(isSuccess: true);
      TalkerService.info('Google login successful', 'AUTH');
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = ProviderStates(errorMessage: errorMsg);
      TalkerService.error('Google login failed', 'AUTH', e);
    }
  }

  Future<void> login(String email, String password) async {
    // Validate inputs
    if (email.trim().isEmpty || password.isEmpty) {
      state = ProviderStates(errorMessage: 'Email and password are required');
      TalkerService.warning('Login attempt with empty credentials', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);

    try {
      user = await _authRepo.login(
        email.toLowerCase().trim(),
        password,
        AppServices.fcmToken ?? '',
        Platform.isAndroid ? 'android' : 'ios',
      );

      // Save device token if available
      if (AppServices.fcmToken != null && AppServices.fcmToken!.isNotEmpty) {
        await SecureStorageHandler.write(
            key: StorageKeys.deviceToken, value: AppServices.fcmToken!);
        TalkerService.warning(
            'Device token saved: ${AppServices.fcmToken}', 'AUTH');
      } else {
        TalkerService.error(
            'FCM token is null or empty, skipping device token save', 'AUTH');
      }

      state = ProviderStates(isSuccess: true);
      TalkerService.info(
          'Login successful for user: ${email.toLowerCase().trim()}', 'AUTH');
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = ProviderStates(errorMessage: errorMsg);
      TalkerService.error(
          'Login failed for user: ${email.toLowerCase().trim()}', 'AUTH', e);
    }
  }

  Future<void> logout() async {
    try {
      final String deviceToken =
          await SecureStorageHandler.read(key: StorageKeys.deviceToken) ?? '';

      if (deviceToken.isNotEmpty) {
        await _authRepo.logout(deviceToken);
        TalkerService.info('User logged out from server', 'AUTH');
      } else {
        TalkerService.warning('No device token found during logout', 'AUTH');
      }

      // Clear all auth-related data from secure storage
      await SecureStorageHandler.delete(key: StorageKeys.token);
      await SecureStorageHandler.delete(key: StorageKeys.deviceToken);
      TalkerService.info('Auth tokens cleared from secure storage', 'AUTH');

      user = null;
      state = ProviderStates();
    } catch (e) {
      TalkerService.error('Error during logout', 'AUTH', e);
    }
  }
}

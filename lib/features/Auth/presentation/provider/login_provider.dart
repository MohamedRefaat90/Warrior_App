import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/features/Auth/data/models/user_model.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
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
      AppLogger.warning('Google login cancelled - no token provided', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      user = await _authRepo.googleSignIn(token);
      state = ProviderStates(isSuccess: true);
      AppLogger.info('Google login successful', 'AUTH');
    } on DioException catch (e) {
      // Safely extract error message from response
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Network error occurred';
      state = ProviderStates(errorMessage: errorMsg);
      AppLogger.error('Google login failed', 'AUTH', e);
    } catch (e) {
      final errorMessage = 'Sign-in failed: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      AppLogger.error('Google login unexpected error', 'AUTH', e);
    }
  }

  Future<void> login(String email, String password) async {
    // Validate inputs
    if (email.trim().isEmpty || password.isEmpty) {
      state = ProviderStates(errorMessage: 'Email and password are required');
      AppLogger.warning('Login attempt with empty credentials', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      user = await _authRepo.login(email.toLowerCase().trim(), password);
      state = ProviderStates(isSuccess: true);
      AppLogger.info(
          'Login successful for user: ${email.toLowerCase().trim()}', 'AUTH');
    } on DioException catch (e) {
      // Safely extract error message from response
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Network error occurred';
      state = ProviderStates(errorMessage: errorMsg);
      AppLogger.error(
          'Login failed for user: ${email.toLowerCase().trim()}', 'AUTH', e);
    } catch (e) {
      final errorMessage = 'Sign-in failed: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      AppLogger.error('Login unexpected error', 'AUTH', e);
    }
  }

  void logout() {
    user = null;
    state = ProviderStates();
    AppLogger.info('User logged out', 'AUTH');
  }
}

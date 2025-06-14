import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signupProvider =
    StateNotifierProvider.autoDispose<SignupNotifier, ProviderStates>((ref) {
  return SignupNotifier(ref.read(authRepo));
});

class SignupNotifier extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  SignupNotifier(this._authRepo) : super(ProviderStates());

  void clearError() {
    if (state.errorMessage != null) {
      state = ProviderStates();
    }
  }

  void passwordValidator(String password) {
    try {
      checkLengthOfPassword(password);
      checkPasswordContainUpperChar(password);
      checkPasswordContainLowerChar(password);
      checkPasswordContainSpecialChar(password);
      checkPasswordContainNum(password);
      state = ProviderStates();
    } catch (e) {
      AppLogger.warning('Password validation failed', 'AUTH', e);
      state = ProviderStates(errorMessage: 'Password validation failed');
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    // Validate inputs
    if (email.trim().isEmpty || password.isEmpty || username.trim().isEmpty) {
      state = ProviderStates(errorMessage: 'All fields are required');
      AppLogger.warning('Signup attempted with missing fields', 'AUTH');
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      state = ProviderStates(errorMessage: 'Please enter a valid email');
      AppLogger.warning('Signup attempted with invalid email format', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.signup(
        email: email.toLowerCase().trim(),
        password: password,
        username: username.trim(),
      );
      state = ProviderStates(isSuccess: true);
      AppLogger.info(
          'Signup successful for user: ${email.toLowerCase().trim()}', 'AUTH');
    } on DioException catch (e) {
      // Safely extract error message
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Registration failed';
      state = ProviderStates(errorMessage: errorMsg);
      AppLogger.error(
          'Signup failed for user: ${email.toLowerCase().trim()}', 'AUTH', e);
    } catch (e) {
      final errorMessage = 'Registration failed: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      AppLogger.error('Signup unexpected error', 'AUTH', e);
    }
  }
}

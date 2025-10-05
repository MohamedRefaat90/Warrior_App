import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/functions/validators.dart';

final resetPasswordProvider =
    NotifierProvider<ResetPasswordNotifier, ProviderStates>(
        ResetPasswordNotifier.new);

class ResetPasswordNotifier extends Notifier<ProviderStates> {
  late AuthRepo _authRepo;

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

  void passwordValidator(String password) {
    try {
      checkLengthOfPassword(password);
      checkPasswordContainUpperChar(password);
      checkPasswordContainLowerChar(password);
      checkPasswordContainSpecialChar(password);
      checkPasswordContainNum(password);
      state = ProviderStates();
    } catch (e) {
      TalkerService.warning('Password validation failed in reset', 'AUTH', e);
      state = ProviderStates(errorMessage: 'Password validation failed');
    }
  }

  Future<void> resendOTP(String email) async {
    // Validate input
    if (email.trim().isEmpty) {
      state = ProviderStates(errorMessage: 'Email is required');
      TalkerService.warning('OTP resend attempted with empty email', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = ProviderStates(isSuccess: true);
      TalkerService.info(
          'OTP resent for password reset: ${email.toLowerCase().trim()}',
          'AUTH');
    } on DioException catch (e) {
      // Safely extract error message
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Failed to resend OTP';
      state = ProviderStates(errorMessage: errorMsg);
      TalkerService.error(
          'OTP resend failed for: ${email.toLowerCase().trim()}', 'AUTH', e);
    } catch (e) {
      final errorMessage = 'Failed to resend OTP: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      TalkerService.error('OTP resend unexpected error', 'AUTH', e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    // Validate inputs
    if (email.trim().isEmpty || password.isEmpty) {
      state = ProviderStates(errorMessage: 'Email and password are required');
      TalkerService.warning(
          'Password reset attempted with missing fields', 'AUTH');
      return;
    }

    // Basic password validation
    if (password.length < 6) {
      state = ProviderStates(
          errorMessage: 'Password must be at least 6 characters');
      TalkerService.warning(
          'Password reset attempted with weak password', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.resetPassword(
        email: email.toLowerCase().trim(),
        password: password,
      );
      state = ProviderStates(isSuccess: true);
      TalkerService.info(
          'Password reset successful for: ${email.toLowerCase().trim()}',
          'AUTH');
    } on DioException catch (e) {
      // Safely extract error message
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Password reset failed';
      state = ProviderStates(errorMessage: errorMsg);
      TalkerService.error(
          'Password reset failed for: ${email.toLowerCase().trim()}',
          'AUTH',
          e);
    } catch (e) {
      final errorMessage = 'Password reset failed: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      TalkerService.error('Password reset unexpected error', 'AUTH', e);
    }
  }

  bool validateAllFields() {
    if (isPassMatchConfirmPass && isVaildEmail && validatePassword()) {
      return true;
    } else {
      return false;
    }
  }

  bool validatePassword() {
    if (isPassLengthLargerThan8 &&
        isContainUpperChar &&
        isContainLowerChar &&
        isContainNum &&
        isContainSpecailChar) {
      return true;
    } else {
      return false;
    }
  }
}

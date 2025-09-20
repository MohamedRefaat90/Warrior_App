import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

final otpProvider =
    StateNotifierProvider.autoDispose<VerifyOTPProvider, ProviderStates>((ref) {
  return VerifyOTPProvider(ref.read(authRepo));
});

class VerifyOTPProvider extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  VerifyOTPProvider(this._authRepo) : super(ProviderStates());

  void clearError() {
    if (state.errorMessage != null) {
      state = ProviderStates();
    }
  }

  Future<void> resendOTP(String email) async {
    // Validate input
    if (email.trim().isEmpty) {
      state = ProviderStates(errorMessage: 'Email is required');
      AppLogger.warning('OTP resend attempted with empty email', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = ProviderStates(isSuccess: true);
      AppLogger.info('OTP resent for: ${email.toLowerCase().trim()}', 'AUTH');
    } on DioException catch (e) {
      // Safely extract error message
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Failed to resend OTP';
      state = ProviderStates(errorMessage: errorMsg);
      AppLogger.error(
          'OTP resend failed for: ${email.toLowerCase().trim()}', 'AUTH', e);
    } catch (e) {
      final errorMessage = 'Failed to resend OTP: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      AppLogger.error('OTP resend unexpected error', 'AUTH', e);
    }
  }

  Future<void> verifyOTP({required String email, required String otp}) async {
    // Validate inputs
    if (email.trim().isEmpty || otp.trim().isEmpty) {
      state = ProviderStates(errorMessage: 'Email and OTP are required');
      AppLogger.warning(
          'OTP verification attempted with missing fields', 'AUTH');
      return;
    }

    // Basic OTP validation (assuming 4-6 digit OTP)
    if (otp.trim().length < 4 || otp.trim().length > 6) {
      state = ProviderStates(errorMessage: 'OTP must be 4-6 digits');
      AppLogger.warning(
          'OTP verification attempted with invalid OTP length', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.verifyOTP(
        email: email.toLowerCase().trim(),
        otp: otp.trim(),
      );
      state = ProviderStates(isSuccess: true);
      AppLogger.info(
          'OTP verification successful for: ${email.toLowerCase().trim()}',
          'AUTH');
    } on DioException catch (e) {
      // Safely extract error message
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'OTP verification failed';
      state = ProviderStates(errorMessage: errorMsg);
      AppLogger.error(
          'OTP verification failed for: ${email.toLowerCase().trim()}',
          'AUTH',
          e);
    } catch (e) {
      final errorMessage = 'OTP verification failed: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      AppLogger.error('OTP verification unexpected error', 'AUTH', e);
    }
  }
}

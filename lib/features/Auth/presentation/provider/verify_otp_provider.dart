import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final otpProvider =
    NotifierProvider<VerifyOTPProvider, ProviderStates>(VerifyOTPProvider.new);

class VerifyOTPProvider extends Notifier<ProviderStates> {
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
          'OTP resent for: ${email.toLowerCase().trim()}', 'AUTH');
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = ProviderStates(errorMessage: errorMsg);
      TalkerService.error(
          'OTP resend failed for: ${email.toLowerCase().trim()}', 'AUTH', e);
    }
  }

  Future<void> verifyOTP({required String email, required String otp}) async {
    // Validate inputs
    if (email.trim().isEmpty || otp.trim().isEmpty) {
      state = ProviderStates(errorMessage: 'Email and OTP are required');
      TalkerService.warning(
          'OTP verification attempted with missing fields', 'AUTH');
      return;
    }

    // Basic OTP validation (assuming 4-6 digit OTP)
    if (otp.trim().length < 4 || otp.trim().length > 6) {
      state = ProviderStates(errorMessage: 'OTP must be 4-6 digits');
      TalkerService.warning(
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
      TalkerService.info(
          'OTP verification successful for: ${email.toLowerCase().trim()}',
          'AUTH');
    } catch (e) {
      final errorMsg = e.toString().replaceFirst('Exception: ', '');
      state = ProviderStates(errorMessage: errorMsg);
      TalkerService.error(
          'OTP verification failed for: ${email.toLowerCase().trim()}',
          'AUTH',
          e);
    }
  }
}

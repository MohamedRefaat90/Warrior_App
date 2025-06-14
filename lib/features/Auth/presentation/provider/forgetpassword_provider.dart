import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgetPasswordProvider =
    StateNotifierProvider.autoDispose<ForgetPasswordNotifier, ProviderStates>(
        (ref) {
  return ForgetPasswordNotifier(ref.read(authRepo));
});

class ForgetPasswordNotifier extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  ForgetPasswordNotifier(this._authRepo) : super(ProviderStates());

  Future<void> forgetPassword(String email) async {
    // Validate input
    if (email.trim().isEmpty) {
      state = ProviderStates(errorMessage: 'Email is required');
      AppLogger.warning('Forget password attempted with empty email', 'AUTH');
      return;
    }

    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = ProviderStates(isSuccess: true);
      AppLogger.info(
          'Password reset request sent for: ${email.toLowerCase().trim()}',
          'AUTH');
    } on DioException catch (e) {
      // Safely extract error message
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Failed to send password reset email';
      state = ProviderStates(errorMessage: errorMsg);
      AppLogger.error(
          'Forget password failed for: ${email.toLowerCase().trim()}',
          'AUTH',
          e);
    } catch (e) {
      final errorMessage = 'Password reset failed: ${e.toString()}';
      state = ProviderStates(errorMessage: errorMessage);
      AppLogger.error('Forget password unexpected error', 'AUTH', e);
    }
  }

  void resetState() {
    state = ProviderStates();
  }
}

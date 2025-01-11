import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final otpProvider =
    StateNotifierProvider.autoDispose<VerifyOTPProvider, ProviderStates>((ref) {
  return VerifyOTPProvider(ref.read(authRepo));
});

class VerifyOTPProvider extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  VerifyOTPProvider(this._authRepo) : super(ProviderStates());

  Future<void> verifyOTP({required String email, required String otp}) async {
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.verifyOTP(email: email.toLowerCase().trim(), otp: otp);
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      state = ProviderStates(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> resendOTP(String email) async {
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = ProviderStates();
    } on DioException catch (e) {
      state = ProviderStates(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }
}

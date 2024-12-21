import 'package:Warrior/features/Auth/presentation/provider/auth_states.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';

final otpProvider =
    StateNotifierProvider.autoDispose<VerifyOTPProvider, AuthState>((ref) {
  return VerifyOTPProvider(ref.read(authRepo));
});

class VerifyOTPProvider extends StateNotifier<AuthState> {
  final AuthRepo _authRepo;

  VerifyOTPProvider(this._authRepo) : super(AuthState());

  Future<void> verifyOTP({required String email, required String otp}) async {
    state = AuthState(isLoading: true);
    try {
      await _authRepo.verifyOTP(email: email.toLowerCase().trim(), otp: otp);
      state = AuthState(isSuccess: true);
    } on DioException catch (e) {
      state = AuthState(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  Future<void> resendOTP(String email) async {
    state = AuthState(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = AuthState();
    } on DioException catch (e) {
      state = AuthState(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }
}

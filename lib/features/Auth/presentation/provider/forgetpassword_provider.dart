import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/Auth/presentation/provider/auth_states.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final forgetPasswordProvider =
    StateNotifierProvider.autoDispose<ForgetPasswordNotifier, AuthState>((ref) {
  return ForgetPasswordNotifier(ref.read(authRepo));
});

class ForgetPasswordNotifier extends StateNotifier<AuthState> {
  final AuthRepo _authRepo;

  ForgetPasswordNotifier(this._authRepo) : super(AuthState());
  Future<void> forgetPassword(String email) async {
    state = AuthState(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = AuthState(isSuccess: true);
    } on DioException catch (e) {
      state = AuthState(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  void resetState() {
    state = AuthState();
  }
}

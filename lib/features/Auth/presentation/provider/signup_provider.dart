import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/features/Auth/presentation/provider/auth_states.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';

final signupProvider =
    StateNotifierProvider.autoDispose<SignupNotifier, AuthState>((ref) {
  return SignupNotifier(ref.read(authRepo));
});

class SignupNotifier extends StateNotifier<AuthState> {
  final AuthRepo _authRepo;

  SignupNotifier(this._authRepo) : super(AuthState());

  Future<void> signup(
      {required String email,
      required String password,
      required String username}) async {
    state = AuthState(isLoading: true);
    try {
      await _authRepo.signup(
          email: email.toLowerCase().trim(),
          password: password,
          username: username);
      state = AuthState(isSuccess: true);
    } on DioException catch (e) {
      state = AuthState(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }

  passwordValidator(String password) {
    checkLengthOfPassword(password);
    checkPasswordContainUpperChar(password);
    checkPasswordContainLowerChar(password);
    checkPasswordContainSpecialChar(password);
    checkPasswordContainNum(password);
    state = AuthState();
  }
}

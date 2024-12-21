import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/Auth/presentation/provider/auth_states.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/functions/validators.dart';

final resetPasswordProvider =
    StateNotifierProvider.autoDispose<ResetPasswordNotifier, AuthState>((ref) {
  return ResetPasswordNotifier(ref.read(authRepo));
});

class ResetPasswordNotifier extends StateNotifier<AuthState> {
  final AuthRepo _authRepo;

  ResetPasswordNotifier(this._authRepo) : super(AuthState());

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

  Future<void> resetPassword(
      {required String email, required String password}) async {
    state = AuthState(isLoading: true);
    try {
      await _authRepo.resetPassword(
          email: email.toLowerCase().trim(), password: password);
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

  bool validateAllFields() {
    if (isPassMatchConfirmPass && isVaildEmail && validatePassword()) {
      return true;
    } else {
      return false;
    }
  }
}

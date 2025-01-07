import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/functions/validators.dart';

final resetPasswordProvider =
    StateNotifierProvider.autoDispose<ResetPasswordNotifier, ProviderStates>(
        (ref) {
  return ResetPasswordNotifier(ref.read(authRepo));
});

class ResetPasswordNotifier extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  ResetPasswordNotifier(this._authRepo) : super(ProviderStates());

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

  Future<void> resetPassword(
      {required String email, required String password}) async {
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.resetPassword(
          email: email.toLowerCase().trim(), password: password);
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      state = ProviderStates(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  passwordValidator(String password) {
    checkLengthOfPassword(password);
    checkPasswordContainUpperChar(password);
    checkPasswordContainLowerChar(password);
    checkPasswordContainSpecialChar(password);
    checkPasswordContainNum(password);
    state = ProviderStates();
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

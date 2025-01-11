import 'package:Warrior/core/functions/validators.dart';
import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final signupProvider =
    StateNotifierProvider.autoDispose<SignupNotifier, ProviderStates>((ref) {
  return SignupNotifier(ref.read(authRepo));
});

class SignupNotifier extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  SignupNotifier(this._authRepo) : super(ProviderStates());

  Future<void> signup(
      {required String email,
      required String password,
      required String username}) async {
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.signup(
          email: email.toLowerCase().trim(),
          password: password,
          username: username);
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
}

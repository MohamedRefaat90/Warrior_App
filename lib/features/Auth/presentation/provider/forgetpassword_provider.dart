import 'package:Warrior/core/network/provider_states.dart';
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
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.forgetPassword(email.toLowerCase().trim());
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      state = ProviderStates(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  void resetState() {
    state = ProviderStates();
  }
}

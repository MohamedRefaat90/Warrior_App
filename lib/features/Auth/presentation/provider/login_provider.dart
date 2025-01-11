import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, ProviderStates>((ref) {
  return LoginNotifier(ref.read(authRepo));
});

class LoginNotifier extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;

  LoginNotifier(this._authRepo) : super(ProviderStates());

  Future<void> googleLogin(String token) async {
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.googleSignIn(token);
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      state = ProviderStates(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> login(String email, String password) async {
    state = ProviderStates(isLoading: true);
    try {
      await _authRepo.login(email.toLowerCase().trim(), password);
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      state = ProviderStates(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }
}

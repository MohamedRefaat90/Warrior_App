import 'package:Warrior/features/Auth/presentation/provider/auth_states.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, AuthState>((ref) {
  return LoginNotifier(ref.read(authRepo));
});

class LoginNotifier extends StateNotifier<AuthState> {
  final AuthRepo _authRepo;

  LoginNotifier(this._authRepo) : super(AuthState());

  Future<void> login(String email, String password) async {
    state = AuthState(isLoading: true);
    try {
      await _authRepo.login(email.toLowerCase().trim(), password);
      state = AuthState(isSuccess: true);
    } on DioException catch (e) {
      state = AuthState(errorMessage: e.response!.data["message"]);
    } catch (e) {
      state = AuthState(errorMessage: e.toString());
    }
  }
}

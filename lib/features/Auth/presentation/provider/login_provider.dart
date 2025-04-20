import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Auth/data/models/user_model.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginProvider =
    StateNotifierProvider.autoDispose<LoginNotifier, ProviderStates>((ref) {
  return LoginNotifier(ref.read(authRepo));
});

class LoginNotifier extends StateNotifier<ProviderStates> {
  final AuthRepo _authRepo;
  UserModel? user;
  LoginNotifier(this._authRepo) : super(ProviderStates());

  Future<void> googleLogin(String? token) async {
    state = ProviderStates(isLoading: true);
    try {
      user = await _authRepo.googleSignIn(token);
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      // Safely extract error message from response
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Network error occurred';
      state = ProviderStates(errorMessage: errorMsg);
      print('Error: $errorMsg');
    } catch (e) {
      state = ProviderStates(errorMessage: 'Sign-in failed: ${e.toString()}');
    }
  }

  Future<void> login(String email, String password) async {
    state = ProviderStates(isLoading: true);
    try {
      user = await _authRepo.login(email.toLowerCase().trim(), password);
      state = ProviderStates(isSuccess: true);
    } on DioException catch (e) {
      // Safely extract error message from response
      final errorMsg = e.response?.data?["message"] as String? ??
          e.message ??
          'Network error occurred';
      state = ProviderStates(errorMessage: errorMsg);
      print('Error: $errorMsg');
    } catch (e) {
      state = ProviderStates(errorMessage: 'Sign-in failed: ${e.toString()}');
    }
  }
}

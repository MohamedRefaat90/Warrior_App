import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/features/Auth/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepo = Provider((ref) {
  return AuthRepo(DioHandler.dio);
});

class AuthRepo {
  final Dio _dio;

  AuthRepo(this._dio);

  Future<void> forgetPassword(String email) async {
    try {
      await _dio.post(ApisUrl.forgetPassword, data: {'email': email});
    } on DioException {
      rethrow;
    }
  }

  Future<UserModel> googleSignIn(String token) async {
    try {
      Response response =
          await _dio.post(ApisUrl.googleLogin, data: {'token': token});
      SecureStorageHandler.write(
          key: "Token", value: response.data['data']['token']);
      return UserModel.fromMap(
          response.data['data']['user'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  Future<UserModel?> login(String email, String password) async {
    try {
      final Response response = await _dio
          .post(ApisUrl.login, data: {'email': email, 'password': password});
      SecureStorageHandler.write(
          key: "Token", value: response.data['data']['token']);
      return UserModel.fromMap(
          response.data['data']['user'] as Map<String, dynamic>);
    } on DioException {
      rethrow;
    }
  }

  Future<void> resetPassword(
      {required String email, required String password}) async {
    try {
      await _dio.post(ApisUrl.resetPassword,
          data: {'email': email, 'new_password': password});
    } on DioException {
      rethrow;
    }
  }

  Future<void> signup(
      {required String email,
      required String password,
      required String username}) async {
    try {
      await _dio.post(ApisUrl.signup,
          data: {'email': email, 'password': password, 'username': username});
    } on DioException {
      rethrow;
    }
  }

  Future<void> verifyOTP({required String email, required String otp}) async {
    try {
      await _dio
          .post(ApisUrl.otpVerification, data: {'email': email, 'otp': otp});
    } on DioException {
      rethrow;
    }
  }
}

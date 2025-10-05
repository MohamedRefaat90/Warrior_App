import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/features/Auth/data/models/user_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authRepo = Provider((ref) {
  return AuthRepo(ref.read(dioProvider));
});

class AuthRepo {
  final Dio _dio;

  AuthRepo(this._dio);

  Future<void> forgetPassword(String email) async {
    try {
      // Validate email
      if (email.trim().isEmpty) {
        throw ArgumentError('Email cannot be empty');
      }

      if (!_isValidEmail(email)) {
        throw ArgumentError('Invalid email format');
      }

      TalkerService.info('Sending password reset email to: $email', 'AUTH_REPO');

      await _dio.post(ApisUrl.forgetPassword, data: {'email': email.trim()});

      TalkerService.info('Password reset email sent successfully', 'AUTH_REPO');
    } on DioException catch (e) {
      TalkerService.error('Network error in forgetPassword', 'AUTH_REPO', e);
      rethrow;
    } catch (e) {
      TalkerService.error('Unexpected error in forgetPassword', 'AUTH_REPO', e);
      rethrow;
    }
  }

  Future<UserModel> googleSignIn(String? token) async {
    try {
      // Validate token
      if (token == null || token.trim().isEmpty) {
        throw ArgumentError('Google sign-in token cannot be null or empty');
      }

      TalkerService.info('Attempting Google sign-in', 'AUTH_REPO');

      final response = await _dio.post(
        ApisUrl.googleLogin,
        data: {'token': token.trim()},
      );

      // Validate response structure
      if (response.data == null ||
          response.data['data'] == null ||
          response.data['data']['token'] == null ||
          response.data['data']['user'] == null) {
        throw Exception('Invalid response format from Google sign-in');
      }

      final authToken = response.data['data']['token'] as String;
      final userData = response.data['data']['user'] as Map<String, dynamic>;

      // Store token securely
      await SecureStorageHandler.write(
        key: StorageKeys.token,
        value: authToken,
      );

      final user = UserModel.fromMap(userData);
      TalkerService.info(
          'Google sign-in successful for user: ${user.email ?? "unknown"}',
          'AUTH_REPO');

      return user;
    } on DioException catch (e) {
      TalkerService.error('Network error in googleSignIn', 'AUTH_REPO', e);
      rethrow;
    } on PlatformException catch (e) {
      TalkerService.error('Platform error in googleSignIn', 'AUTH_REPO', e);
      rethrow;
    } catch (e) {
      TalkerService.error('Unexpected error in googleSignIn', 'AUTH_REPO', e);
      rethrow;
    }
  }

  Future<UserModel> login(String email, String password) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        throw ArgumentError('Email and password cannot be empty');
      }

      if (!_isValidEmail(email)) {
        throw ArgumentError('Invalid email format');
      }

      if (password.length < 6) {
        throw ArgumentError('Password must be at least 6 characters');
      }

      TalkerService.info('Attempting login for user: ${email.trim()}', 'AUTH_REPO');

      final response = await _dio.post(
        ApisUrl.login,
        data: {
          'email': email.toLowerCase().trim(),
          'password': password,
        },
      );

      // Validate response structure
      if (response.data == null ||
          response.data['data'] == null ||
          response.data['data']['token'] == null ||
          response.data['data']['user'] == null) {
        throw Exception('Invalid response format from login');
      }

      final authToken = response.data['data']['token'] as String;
      final userData = response.data['data']['user'] as Map<String, dynamic>;

      // Store token securely
      await SecureStorageHandler.write(
        key: StorageKeys.token,
        value: authToken,
      );

      final user = UserModel.fromMap(userData);
      TalkerService.info(
          'Login successful for user: ${user.email ?? "unknown"}', 'AUTH_REPO');

      return user;
    } on DioException catch (e) {
      TalkerService.error(
          'Network error in login for: ${email.trim()}', 'AUTH_REPO', e);
      rethrow;
    } catch (e) {
      TalkerService.error('Unexpected error in login', 'AUTH_REPO', e);
      rethrow;
    }
  }

  Future<void> resetPassword({
    required String email,
    required String password,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty) {
        throw ArgumentError('Email and password cannot be empty');
      }

      if (!_isValidEmail(email)) {
        throw ArgumentError('Invalid email format');
      }

      if (password.length < 6) {
        throw ArgumentError('Password must be at least 6 characters');
      }

      TalkerService.info(
          'Resetting password for user: ${email.trim()}', 'AUTH_REPO');

      await _dio.post(
        ApisUrl.resetPassword,
        data: {
          'email': email.toLowerCase().trim(),
          'new_password': password,
        },
      );

      TalkerService.info('Password reset successful', 'AUTH_REPO');
    } on DioException catch (e) {
      TalkerService.error('Network error in resetPassword', 'AUTH_REPO', e);
      rethrow;
    } catch (e) {
      TalkerService.error('Unexpected error in resetPassword', 'AUTH_REPO', e);
      rethrow;
    }
  }

  Future<void> signup({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || password.isEmpty || username.trim().isEmpty) {
        throw ArgumentError('All fields are required');
      }

      if (!_isValidEmail(email)) {
        throw ArgumentError('Invalid email format');
      }

      if (password.length < 6) {
        throw ArgumentError('Password must be at least 6 characters');
      }

      if (username.trim().length < 2) {
        throw ArgumentError('Username must be at least 2 characters');
      }

      TalkerService.info('Creating account for user: ${email.trim()}', 'AUTH_REPO');

      await _dio.post(
        ApisUrl.signup,
        data: {
          'email': email.toLowerCase().trim(),
          'password': password,
          'username': username.trim(),
        },
      );

      TalkerService.info('Account created successfully', 'AUTH_REPO');
    } on DioException catch (e) {
      TalkerService.error('Network error in signup', 'AUTH_REPO', e);
      rethrow;
    } catch (e) {
      TalkerService.error('Unexpected error in signup', 'AUTH_REPO', e);
      rethrow;
    }
  }

  Future<void> verifyOTP({
    required String email,
    required String otp,
  }) async {
    try {
      // Validate inputs
      if (email.trim().isEmpty || otp.trim().isEmpty) {
        throw ArgumentError('Email and OTP cannot be empty');
      }

      if (!_isValidEmail(email)) {
        throw ArgumentError('Invalid email format');
      }

      if (otp.trim().length < 4 || otp.trim().length > 6) {
        throw ArgumentError('OTP must be 4-6 digits');
      }

      if (!RegExp(r'^\d+$').hasMatch(otp.trim())) {
        throw ArgumentError('OTP must contain only digits');
      }

      TalkerService.info('Verifying OTP for user: ${email.trim()}', 'AUTH_REPO');

      await _dio.post(
        ApisUrl.otpVerification,
        data: {
          'email': email.toLowerCase().trim(),
          'otp': otp.trim(),
        },
      );

      TalkerService.info('OTP verification successful', 'AUTH_REPO');
    } on DioException catch (e) {
      TalkerService.error('Network error in verifyOTP', 'AUTH_REPO', e);
      rethrow;
    } catch (e) {
      TalkerService.error('Unexpected error in verifyOTP', 'AUTH_REPO', e);
      rethrow;
    }
  }

  // Helper method for email validation
  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }
}

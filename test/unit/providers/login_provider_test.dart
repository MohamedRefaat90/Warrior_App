import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/features/Auth/data/models/user_model.dart';
import 'package:Warrior/features/Auth/data/repo/auth_repo.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  // Initialize test FCM token to avoid null errors
  setUpAll(() {
    AppServices.fcmToken = 'test_fcm_token_12345';
  });

  group('LoginProvider Tests', () {
    late MockAuthRepo mockAuthRepo;
    late ProviderContainer container;

    setUp(() {
      mockAuthRepo = MockAuthRepo();
      container = ProviderContainer(
        overrides: [
          authRepo.overrideWithValue(mockAuthRepo),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    test('should create LoginProvider instance', () {
      final provider = container.read(loginProvider.notifier);
      expect(provider, isA<LoginNotifier>());
    });

    test('should have initial empty state', () {
      final state = container.read(loginProvider);
      expect(state.isLoading, false);
      expect(state.isSuccess, false);
      expect(state.errorMessage, null);
    });

    test('should handle login method call', () async {
      // Arrange
      const email = 'test@example.com';
      const password = 'password123';
      final mockUser = UserModel(
        id: '1',
        email: email,
        username: 'testuser',
      );

      // Setup mock to return a user when login is called
      when(() => mockAuthRepo.login(
            any(),
            any(),
            any(),
            any(),
          )).thenAnswer((_) async => mockUser);

      final provider = container.read(loginProvider.notifier);

      // Act
      await provider.login(email, password);

      // Assert - Method was called (email is normalized inside login method)
      verify(() => mockAuthRepo.login(
            email, // Already lowercase in test, will be normalized in actual call
            password,
            'test_fcm_token_12345',
            'android',
          )).called(1);
    });

    test('should handle empty email validation', () async {
      // Arrange
      const email = '';
      const password = 'password123';

      final provider = container.read(loginProvider.notifier);

      // Act
      await provider.login(email, password);

      // Assert
      final state = container.read(loginProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('required'));

      verifyNever(() => mockAuthRepo.login(any(), any(), any(), any()));
    });

    test('should handle empty password validation', () async {
      // Arrange
      const email = 'test@example.com';
      const password = '';

      final provider = container.read(loginProvider.notifier);

      // Act
      await provider.login(email, password);

      // Assert
      final state = container.read(loginProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('required'));

      verifyNever(() => mockAuthRepo.login(any(), any(), any(), any()));
    });

    test('should handle Google login method call', () async {
      // Arrange
      const token = 'google_token_123';
      final mockUser = UserModel(
        id: '1',
        email: 'test@example.com',
        username: 'testuser',
      );

      // Setup mock to return a user when googleSignIn is called
      when(() => mockAuthRepo.googleSignIn(any()))
          .thenAnswer((_) async => mockUser);

      final provider = container.read(loginProvider.notifier);

      // Act
      await provider.googleLogin(token);

      // Assert - Method was called
      verify(() => mockAuthRepo.googleSignIn(token)).called(1);
    });

    test('should handle null Google token', () async {
      // Arrange
      const String? token = null;

      final provider = container.read(loginProvider.notifier);

      // Act
      await provider.googleLogin(token);

      // Assert
      final state = container.read(loginProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('cancelled'));

      verifyNever(() => mockAuthRepo.googleSignIn(any()));
    });

    test('should handle empty Google token', () async {
      // Arrange
      const token = '';

      final provider = container.read(loginProvider.notifier);

      // Act
      await provider.googleLogin(token);

      // Assert
      final state = container.read(loginProvider);
      expect(state.isLoading, false);
      expect(state.errorMessage, contains('cancelled'));

      verifyNever(() => mockAuthRepo.googleSignIn(any()));
    });

    test('should clear error state', () async {
      // Arrange - First create an error state
      const email = '';
      const password = 'password123';
      final provider = container.read(loginProvider.notifier);
      await provider.login(email, password);

      // Verify error state exists
      var state = container.read(loginProvider);
      expect(state.errorMessage, isNotNull);

      // Act
      provider.clearError();

      // Assert
      state = container.read(loginProvider);
      expect(state.errorMessage, null);
    });

    test('should handle logout', () {
      // Arrange
      final provider = container.read(loginProvider.notifier);

      // Act
      provider.logout();

      // Assert - Should not throw errors
      expect(provider.user, null);
    });
  });
}

// Mock classes
class MockAuthRepo extends Mock implements AuthRepo {}

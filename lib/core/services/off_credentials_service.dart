import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:openfoodfacts/openfoodfacts.dart';

/// Service for managing Open Food Facts API credentials securely.
///
/// Credentials are stored in secure storage and retrieved when needed
/// for API operations. Default credentials are provided for anonymous
/// contributions but users can set their own credentials for attribution.
class OpenFoodFactsCredentialsService {
  OpenFoodFactsCredentialsService._();

  /// Clears stored credentials and reverts to defaults.
  static Future<void> clearCredentials() async {
    await SecureStorageHandler.delete(key: StorageKeys.offUserId);
    await SecureStorageHandler.delete(key: StorageKeys.offPassword);
  }

  /// Gets the Open Food Facts user credentials.
  ///
  /// Returns user credentials from secure storage if available,
  /// otherwise returns default anonymous credentials.
  static Future<User> getUser() async {
    final userId = await SecureStorageHandler.read(key: StorageKeys.offUserId);
    final password =
        await SecureStorageHandler.read(key: StorageKeys.offPassword);

    TalkerService.info("User ID: $userId");
    TalkerService.info("Password: $password");
    TalkerService.info(
        "User Agent: ${OpenFoodAPIConfiguration.userAgent!.name}");
    return User(
      userId: userId ?? '',
      password: password ?? '',
      comment: 'Contributed via Warrior App',
    );
  }

  /// Checks if custom credentials are stored.
  static Future<bool> hasCustomCredentials() async {
    final userId = await SecureStorageHandler.read(key: StorageKeys.offUserId);
    return userId != null && userId.isNotEmpty;
  }

  /// Saves custom Open Food Facts credentials.
  ///
  /// Allows users to use their own Open Food Facts account
  /// for contributions to get attribution.
  static Future<void> saveCredentials({
    required String userId,
    required String password,
  }) async {
    await SecureStorageHandler.write(
      key: StorageKeys.offUserId,
      value: userId,
    );
    await SecureStorageHandler.write(
      key: StorageKeys.offPassword,
      value: password,
    );
  }
}

/// Storage keys for shared preferences and secure storage.
class StorageKeys {
  // Authentication
  static const String token = 'Token';

  static const String deviceToken = 'deviceToken';
  static const String isGuestMode = 'isGuestMode';
  // User preferences
  static const String isFirstTime = 'isFirstTime';

  static const String workoutAlert = 'workoutAlert';
  static const String foodSearchAlert = 'foodSearchAlert';
  static const String numberOfWorkouts = 'numberOfWorkouts';
  static const String isRating = 'isRating';
  static const String caloriesCalculatorData = 'caloriesCalculatorData';
  static const String isGridView = 'isGridView';
  static const String muscleViewMode = 'muscleViewMode';
  static const String themeMode = 'themeMode';
  static const String locale = 'locale';
  // Open Food Facts API credentials (secure storage)
  static const String offUserId = 'off_user_id';

  static const String offPassword = 'off_password';
  StorageKeys._();
}

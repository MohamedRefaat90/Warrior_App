import 'dart:convert';

/// Model representing user input data for calorie calculations
class UserDataModel {
  final double weight; // in kg
  final double height; // in cm
  final int age; // in years
  final String gender; // 'male' or 'female'
  final String activityLevel;
  final String goal; // 'weight_loss', 'maintain', 'muscle_gain'
  final double weeklyGoal; // in kg (0.25, 0.5, 0.75, 1.0)

  UserDataModel({
    required this.weight,
    required this.height,
    required this.age,
    required this.gender,
    required this.activityLevel,
    required this.goal,
    required this.weeklyGoal,
  }) {
    _validateInputs();
  }

  /// Create model from JSON
  factory UserDataModel.fromJson(Map<String, dynamic> json) {
    return UserDataModel(
      weight: (json['weight'] as num).toDouble(),
      height: (json['height'] as num).toDouble(),
      age: json['age'] as int,
      gender: json['gender'] as String,
      activityLevel: json['activityLevel'] as String,
      goal: json['goal'] as String,
      weeklyGoal: (json['weeklyGoal'] as num).toDouble(),
    );
  }

  /// Create model from string
  factory UserDataModel.fromJsonString(String jsonString) {
    return UserDataModel.fromJson(json.decode(jsonString));
  }

  /// Convert model to JSON for storage
  Map<String, dynamic> toJson() {
    return {
      'weight': weight,
      'height': height,
      'age': age,
      'gender': gender,
      'activityLevel': activityLevel,
      'goal': goal,
      'weeklyGoal': weeklyGoal,
    };
  }

  /// Convert model to string for storage
  String toJsonString() => json.encode(toJson());

  /// Validate all input values
  void _validateInputs() {
    if (!isValidAge(age)) {
      throw ArgumentError('Age must be between 13 and 120 years. Got: $age');
    }
    if (!isValidWeight(weight)) {
      throw ArgumentError('Weight must be between 20 and 300 kg. Got: $weight');
    }
    if (!isValidHeight(height)) {
      throw ArgumentError(
          'Height must be between 100 and 250 cm. Got: $height');
    }
  }

  /// Validate age (13-120 years)
  static bool isValidAge(int age) {
    return age >= 13 && age <= 120;
  }

  /// Validate height (100-250 cm)
  static bool isValidHeight(double height) {
    return height >= 100 && height <= 250;
  }

  /// Validate weight (20-300 kg)
  static bool isValidWeight(double weight) {
    return weight >= 20 && weight <= 300;
  }

  /// Get age validation error message
  static String? validateAgeInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your age';
    }
    final age = int.tryParse(value);
    if (age == null) {
      return 'Please enter a valid number';
    }
    if (!isValidAge(age)) {
      return 'Age must be between 13 and 120 years';
    }
    return null;
  }

  /// Get height validation error message
  static String? validateHeightInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your height';
    }
    final height = double.tryParse(value);
    if (height == null) {
      return 'Please enter a valid number';
    }
    if (!isValidHeight(height)) {
      return 'Height must be between 100 and 250 cm';
    }
    return null;
  }

  /// Get weight validation error message
  static String? validateWeightInput(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter your weight';
    }
    final weight = double.tryParse(value);
    if (weight == null) {
      return 'Please enter a valid number';
    }
    if (!isValidWeight(weight)) {
      return 'Weight must be between 20 and 300 kg';
    }
    return null;
  }
}

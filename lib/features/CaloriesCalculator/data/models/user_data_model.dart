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
  });

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

  /// Create a copy with updated fields
  UserDataModel copyWith({
    double? weight,
    double? height,
    int? age,
    String? gender,
    String? activityLevel,
    String? goal,
    double? weeklyGoal,
  }) {
    return UserDataModel(
      weight: weight ?? this.weight,
      height: height ?? this.height,
      age: age ?? this.age,
      gender: gender ?? this.gender,
      activityLevel: activityLevel ?? this.activityLevel,
      goal: goal ?? this.goal,
      weeklyGoal: weeklyGoal ?? this.weeklyGoal,
    );
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
}

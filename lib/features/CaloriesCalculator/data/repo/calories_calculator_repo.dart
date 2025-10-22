import 'dart:math';

import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/CaloriesCalculator/data/models/calories_result_model.dart';
import 'package:Warrior/features/CaloriesCalculator/data/models/user_data_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final caloriesCalculatorRepo = Provider<CaloriesCalculatorRepo>((ref) {
  return CaloriesCalculatorRepo();
});

/// Repository for handling calorie calculations and data persistence
class CaloriesCalculatorRepo {
  /// Activity level multipliers for TDEE calculation
  static const Map<String, double> _activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extra_active': 1.9,
  };

  /// Calculate BMR using Mifflin-St Jeor Equation
  /// Most accurate equation recommended by dietitians
  /// Men: BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age + 5
  /// Women: BMR = 10 * weight(kg) + 6.25 * height(cm) - 5 * age - 161
  double calculateBMR(UserDataModel userData) {
    try {
      final double baseBMR = (10 * userData.weight) +
          (6.25 * userData.height) -
          (5 * userData.age);

      final double bmr =
          userData.gender == 'male' ? baseBMR + 5 : baseBMR - 161;

      TalkerService.info('BMR calculated: $bmr', 'CALORIES_CALCULATOR');
      return bmr;
    } catch (e) {
      TalkerService.error('Error calculating BMR', 'CALORIES_CALCULATOR', e);
      rethrow;
    }
  }

  /// Calculate daily caloric needs based on goal
  /// Weight Loss: Create deficit (500 cal/day = 0.5kg/week)
  /// Muscle Gain: Create surplus (500 cal/day = 0.5kg/week)
  /// Maintain: Keep TDEE
  ///
  /// Note: 1 kg of body weight ≈ 7700 calories
  double calculateDailyCaloricNeeds(
      double tdee, String goal, double weeklyGoalKg) {
    try {
      if (goal == 'maintain') {
        return tdee;
      }

      // Calculate daily calorie adjustment
      // 7700 calories per kg of body weight
      final dailyAdjustment = (weeklyGoalKg * 7700) / 7;

      final dailyCalories = goal == 'weight_loss'
          ? tdee - dailyAdjustment
          : tdee + dailyAdjustment;

      // Ensure minimum calorie intake (1200 for women, 1500 for men)
      final minCalories = 1200.0;
      final adjustedCalories = max(dailyCalories, minCalories);

      TalkerService.info(
        'Daily caloric needs: $adjustedCalories',
        'CALORIES_CALCULATOR',
      );
      return adjustedCalories;
    } catch (e) {
      TalkerService.error(
        'Error calculating daily caloric needs',
        'CALORIES_CALCULATOR',
        e,
      );
      rethrow;
    }
  }

  /// Calculate macronutrient breakdown based on goal
  ///
  /// Weight Loss (High Protein, Moderate Carbs, Low Fat):
  /// - Protein: 40% (preserves muscle)
  /// - Carbs: 35% (energy for workouts)
  /// - Fats: 25% (essential functions)
  ///
  /// Maintain Weight (Balanced):
  /// - Protein: 30%
  /// - Carbs: 40%
  /// - Fats: 30%
  ///
  /// Muscle Gain (High Protein & Carbs):
  /// - Protein: 30% (builds muscle)
  /// - Carbs: 50% (fuel for growth)
  /// - Fats: 20% (hormonal balance)
  ///
  /// Note:
  /// - 1g Protein = 4 calories
  /// - 1g Carbs = 4 calories
  /// - 1g Fat = 9 calories
  MacronutrientModel calculateMacros(double dailyCalories, String goal) {
    try {
      double proteinPercent, carbsPercent, fatsPercent;

      switch (goal) {
        case 'weight_loss':
          proteinPercent = 0.40;
          carbsPercent = 0.35;
          fatsPercent = 0.25;
          break;
        case 'muscle_gain':
          proteinPercent = 0.30;
          carbsPercent = 0.50;
          fatsPercent = 0.20;
          break;
        case 'maintain':
        default:
          proteinPercent = 0.30;
          carbsPercent = 0.40;
          fatsPercent = 0.30;
          break;
      }

      // Calculate calories for each macro
      final proteinCalories = dailyCalories * proteinPercent;
      final carbsCalories = dailyCalories * carbsPercent;
      final fatsCalories = dailyCalories * fatsPercent;

      // Calculate grams (protein: 4 cal/g, carbs: 4 cal/g, fats: 9 cal/g)
      final proteinGrams = proteinCalories / 4;
      final carbsGrams = carbsCalories / 4;
      final fatsGrams = fatsCalories / 9;

      TalkerService.info(
        'Macros calculated - P: ${proteinGrams.toStringAsFixed(1)}g, '
            'C: ${carbsGrams.toStringAsFixed(1)}g, F: ${fatsGrams.toStringAsFixed(1)}g',
        'CALORIES_CALCULATOR',
      );

      return MacronutrientModel(
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatsGrams: fatsGrams,
        proteinCalories: proteinCalories,
        carbsCalories: carbsCalories,
        fatsCalories: fatsCalories,
        proteinPercentage: proteinPercent * 100,
        carbsPercentage: carbsPercent * 100,
        fatsPercentage: fatsPercent * 100,
      );
    } catch (e) {
      TalkerService.error(
        'Error calculating macros',
        'CALORIES_CALCULATOR',
        e,
      );
      rethrow;
    }
  }

  /// Calculate complete results
  CaloriesResultModel calculateResults(UserDataModel userData) {
    try {
      final bmr = calculateBMR(userData);
      final tdee = calculateTDEE(bmr, userData.activityLevel);
      final dailyCaloricNeeds =
          calculateDailyCaloricNeeds(tdee, userData.goal, userData.weeklyGoal);
      final macros = calculateMacros(dailyCaloricNeeds, userData.goal);

      TalkerService.info(
        'Complete calculation finished successfully',
        'CALORIES_CALCULATOR',
      );

      return CaloriesResultModel(
        bmr: bmr,
        tdee: tdee,
        dailyCaloricNeeds: dailyCaloricNeeds,
        macros: macros,
        goal: userData.goal,
        weeklyGoalKg: userData.weeklyGoal,
      );
    } catch (e) {
      TalkerService.error(
        'Error calculating complete results',
        'CALORIES_CALCULATOR',
        e,
      );
      rethrow;
    }
  }

  /// Calculate TDEE (Total Daily Energy Expenditure)
  /// TDEE = BMR * Activity Level Multiplier
  double calculateTDEE(double bmr, String activityLevel) {
    try {
      final multiplier = _activityMultipliers[activityLevel] ?? 1.2;
      final tdee = bmr * multiplier;

      TalkerService.info('TDEE calculated: $tdee', 'CALORIES_CALCULATOR');
      return tdee;
    } catch (e) {
      TalkerService.error('Error calculating TDEE', 'CALORIES_CALCULATOR', e);
      rethrow;
    }
  }

  /// Clear saved user data
  Future<void> clearUserData() async {
    try {
      await SharedPref.setString(StorageKeys.caloriesCalculatorData, '');
      TalkerService.info(
          'User data cleared successfully', 'CALORIES_CALCULATOR');
    } catch (e) {
      TalkerService.error(
        'Error clearing user data',
        'CALORIES_CALCULATOR',
        e,
      );
      rethrow;
    }
  }

  /// Load user data from local storage
  Future<UserDataModel?> loadUserData() async {
    try {
      final jsonString =
          SharedPref.getString(StorageKeys.caloriesCalculatorData);
      if (jsonString == null) {
        TalkerService.info('No saved user data found', 'CALORIES_CALCULATOR');
        return null;
      }

      final userData = UserDataModel.fromJsonString(jsonString);
      TalkerService.info(
          'User data loaded successfully', 'CALORIES_CALCULATOR');
      return userData;
    } catch (e) {
      TalkerService.error(
        'Error loading user data',
        'CALORIES_CALCULATOR',
        e,
      );
      return null;
    }
  }

  /// Save user data to local storage
  Future<void> saveUserData(UserDataModel userData) async {
    try {
      await SharedPref.setString(
        StorageKeys.caloriesCalculatorData,
        userData.toJsonString(),
      );
      TalkerService.info('User data saved successfully', 'CALORIES_CALCULATOR');
    } catch (e) {
      TalkerService.error(
        'Error saving user data',
        'CALORIES_CALCULATOR',
        e,
      );
      rethrow;
    }
  }
}

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

  /// Calculate macronutrient breakdown based on body weight and goal
  ///
  /// Following the standard macronutrient calculation:
  /// 1. Protein: Based on body weight
  ///    - Males (Athletes): 1.6-2.5g per kg body weight
  ///    - Females: 0.8-1.2g per kg body weight
  ///    - Adjusted based on goal (higher for muscle gain/weight loss)
  ///
  /// 2. Fats: 20-30% of total daily calories
  ///    - Weight Loss: 20-25%
  ///    - Maintain/Muscle Gain: 25-30%
  ///
  /// 3. Carbs: Remaining calories after protein and fats
  ///
  /// Note:
  /// - 1g Protein = 4 calories
  /// - 1g Carbs = 4 calories
  /// - 1g Fat = 9 calories
  MacronutrientModel calculateMacros(
    double dailyCalories,
    String goal,
    double weightKg,
    String gender,
  ) {
    try {
      // Step 1: Calculate Protein based on body weight
      double proteinGramsPerKg;

      if (gender == 'male') {
        // Males: 1.6-2.5g per kg
        switch (goal) {
          case 'weight_loss':
            proteinGramsPerKg = 1.6;
            break;
          case 'muscle_gain':
            proteinGramsPerKg = 1.8;
            break;
          case 'maintain':
          default:
            proteinGramsPerKg = 1.8;
            break;
        }
      } else {
        // Females: 0.8-1.2g per kg
        switch (goal) {
          case 'weight_loss':
            proteinGramsPerKg = 1.2;
            break;
          case 'muscle_gain':
            proteinGramsPerKg = 1.2;
            break;
          case 'maintain':
          default:
            proteinGramsPerKg = 1.0;
            break;
        }
      }

      final proteinGrams = weightKg * proteinGramsPerKg;
      final proteinCalories = proteinGrams * 4; // 4 calories per gram

      // Step 2: Calculate Fats (20-30% of total calories)
      double fatsPercent;
      switch (goal) {
        case 'weight_loss':
          fatsPercent = 0.20; // 20% for weight loss
          break;
        case 'muscle_gain':
          fatsPercent = 0.25; // 25% for muscle gain
          break;
        case 'maintain':
        default:
          fatsPercent = 0.30; // 30% for maintenance
          break;
      }

      final fatsCalories = dailyCalories * fatsPercent;
      final fatsGrams = fatsCalories / 9; // 9 calories per gram

      // Step 3: Calculate Carbs from remaining calories
      final carbsCalories = dailyCalories - proteinCalories - fatsCalories;
      final carbsGrams = carbsCalories / 4; // 4 calories per gram

      // Calculate percentages for display
      final proteinPercentage = (proteinCalories / dailyCalories) * 100;
      final carbsPercentage = (carbsCalories / dailyCalories) * 100;
      final fatsPercentage = (fatsCalories / dailyCalories) * 100;

      TalkerService.info(
        'Macros calculated - P: ${proteinGrams.toStringAsFixed(1)}g (${proteinPercentage.toStringAsFixed(1)}%), '
            'C: ${carbsGrams.toStringAsFixed(1)}g (${carbsPercentage.toStringAsFixed(1)}%), '
            'F: ${fatsGrams.toStringAsFixed(1)}g (${fatsPercentage.toStringAsFixed(1)}%)',
        'CALORIES_CALCULATOR',
      );

      return MacronutrientModel(
        proteinGrams: proteinGrams,
        carbsGrams: carbsGrams,
        fatsGrams: fatsGrams,
        proteinCalories: proteinCalories,
        carbsCalories: carbsCalories,
        fatsCalories: fatsCalories,
        proteinPercentage: proteinPercentage,
        carbsPercentage: carbsPercentage,
        fatsPercentage: fatsPercentage,
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
      final macros = calculateMacros(
        dailyCaloricNeeds,
        userData.goal,
        userData.weight,
        userData.gender,
      );

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

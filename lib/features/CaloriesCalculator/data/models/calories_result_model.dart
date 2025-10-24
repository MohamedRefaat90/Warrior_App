/// Model representing calculated calorie and macronutrient results
class CaloriesResultModel {
  final double bmr; // Basal Metabolic Rate
  final double tdee; // Total Daily Energy Expenditure
  final double dailyCaloricNeeds; // Adjusted calories based on goal
  final MacronutrientModel macros; // Protein, carbs, fats breakdown
  final String goal;
  final double weeklyGoalKg;

  CaloriesResultModel({
    required this.bmr,
    required this.tdee,
    required this.dailyCaloricNeeds,
    required this.macros,
    required this.goal,
    required this.weeklyGoalKg,
  });

  /// Get weekly goal description
  String get weeklyGoalDescription {
    if (goal == 'maintain') return 'Maintain current weight';
    final action = goal == 'weight_loss' ? 'Lose' : 'Gain';
    return '$action $weeklyGoalKg kg per week';
  }
}

/// Model for macronutrient breakdown
class MacronutrientModel {
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;
  final double proteinCalories;
  final double carbsCalories;
  final double fatsCalories;
  final double proteinPercentage;
  final double carbsPercentage;
  final double fatsPercentage;

  MacronutrientModel({
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
    required this.proteinCalories,
    required this.carbsCalories,
    required this.fatsCalories,
    required this.proteinPercentage,
    required this.carbsPercentage,
    required this.fatsPercentage,
  });
}

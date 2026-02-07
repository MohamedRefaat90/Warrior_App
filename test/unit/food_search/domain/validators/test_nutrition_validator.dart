import 'package:Warrior/features/FoodSearch/domain/validators/nutrition_validator.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('NutritionValidator', () {
    test('accepts valid calories value', () {
      expect(NutritionValidator.validateCalories(100), true);
    });

    test('accepts zero calories', () {
      expect(NutritionValidator.validateCalories(0), true);
    });

    test('accepts maximum reasonable calories', () {
      expect(NutritionValidator.validateCalories(900), true);
    });

    test('rejects negative calories', () {
      expect(NutritionValidator.validateCalories(-1), false);
    });

    test('accepts valid protein value', () {
      expect(NutritionValidator.validateProtein(25.5), true);
    });

    test('rejects negative protein', () {
      expect(NutritionValidator.validateProtein(-1), false);
    });

    test('accepts valid carbohydrates value', () {
      expect(NutritionValidator.validateCarbohydrates(50), true);
    });

    test('rejects excessive fat value', () {
      expect(NutritionValidator.validateFat(150), false);
    });

    test('accepts valid fiber value', () {
      expect(NutritionValidator.validateFiber(5), true);
    });

    test('validates complete nutrition facts', () {
      final isValid = NutritionValidator.validateNutrition(
        calories: 150,
        protein: 5,
        carbs: 30,
        fat: 3,
        fiber: 2,
      );
      expect(isValid, true);
    });
  });
}

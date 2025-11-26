import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/CaloriesCalculator/data/models/user_data_model.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/provider/calories_calculator_provider.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/activity_level_item.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/calculator_header_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/gender_selection_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/goal_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/input_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/section_title.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/weekly_goal_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class CaloriesCalculatorScreen extends ConsumerStatefulWidget {
  const CaloriesCalculatorScreen({super.key});

  @override
  ConsumerState<CaloriesCalculatorScreen> createState() =>
      _CaloriesCalculatorScreenState();
}

class _CaloriesCalculatorScreenState
    extends ConsumerState<CaloriesCalculatorScreen> {
  // Controllers
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();

  // Selected values
  String _selectedGender = 'male';
  String _selectedActivityLevel = 'sedentary';
  String _selectedGoal = 'maintain';
  double _selectedWeeklyGoal = 0.5;

  // Activity level options
  final List<Map<String, String>> _activityLevels = [
    {
      'value': 'sedentary',
      'label': 'Sedentary',
      'desc': 'Little or no exercise'
    },
    {
      'value': 'lightly_active',
      'label': 'Lightly Active',
      'desc': 'Light exercise 1-3 days/week'
    },
    {
      'value': 'moderately_active',
      'label': 'Moderately Active',
      'desc': 'Moderate exercise 3-5 days/week'
    },
    {
      'value': 'very_active',
      'label': 'Very Active',
      'desc': 'Hard exercise 6-7 days/week'
    },
    {
      'value': 'extra_active',
      'label': 'Extra Active',
      'desc': 'Very hard exercise & physical job'
    },
  ];

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caloriesCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Calories Calculator',
          style: TextStyle(fontFamily: 'kings', fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          if (state.hasCalculated)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _handleReset,
              tooltip: 'Reset Calculator',
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: Loader())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header Section
                  Center(child: const CalculatorHeaderCard()),
                  const SizedBox(height: 30),

                  // Basic Info Section
                  const SectionTitle(title: 'Basic Information'),
                  const SizedBox(height: 15),
                  InputCard(
                    label: 'Weight',
                    hint: 'Enter weight',
                    suffix: 'kg',
                    controller: _weightController,
                  ),
                  const SizedBox(height: 15),
                  InputCard(
                    label: 'Height',
                    hint: 'Enter height',
                    suffix: 'cm',
                    controller: _heightController,
                  ),
                  const SizedBox(height: 15),
                  InputCard(
                    label: 'Age',
                    hint: 'Enter age',
                    suffix: 'years',
                    controller: _ageController,
                  ),
                  const SizedBox(height: 30),

                  // Gender Selection
                  const SectionTitle(title: 'Gender'),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      Expanded(
                        child: GenderSelectionCard(
                          icon: Icons.male,
                          label: 'Male',
                          isSelected: _selectedGender == 'male',
                          onTap: () => setState(() => _selectedGender = 'male'),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: GenderSelectionCard(
                          icon: Icons.female,
                          label: 'Female',
                          isSelected: _selectedGender == 'female',
                          onTap: () =>
                              setState(() => _selectedGender = 'female'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Activity Level
                  const SectionTitle(title: 'Activity Level'),
                  const SizedBox(height: 15),
                  ..._activityLevels.map((level) {
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: ActivityLevelItem(
                        value: level['value']!,
                        label: level['label']!,
                        description: level['desc']!,
                        isSelected: _selectedActivityLevel == level['value'],
                        onTap: () {
                          setState(
                              () => _selectedActivityLevel = level['value']!);
                        },
                      ),
                    );
                  }),
                  const SizedBox(height: 30),

                  // Goal Selection
                  const SectionTitle(title: 'Your Goal'),
                  const SizedBox(height: 15),
                  GoalCard(
                    icon: Icons.trending_down,
                    title: 'Weight Loss',
                    subtitle: 'Lose weight gradually',
                    value: 'weight_loss',
                    isSelected: _selectedGoal == 'weight_loss',
                    color: Colors.orange,
                    onTap: () => setState(() => _selectedGoal = 'weight_loss'),
                  ),
                  const SizedBox(height: 12),
                  GoalCard(
                    icon: Icons.trending_flat,
                    title: 'Maintain Weight',
                    subtitle: 'Keep current weight',
                    value: 'maintain',
                    isSelected: _selectedGoal == 'maintain',
                    color: Colors.blue,
                    onTap: () => setState(() => _selectedGoal = 'maintain'),
                  ),
                  const SizedBox(height: 12),
                  GoalCard(
                    icon: Icons.trending_up,
                    title: 'Muscle Gain',
                    subtitle: 'Build muscle mass',
                    value: 'muscle_gain',
                    isSelected: _selectedGoal == 'muscle_gain',
                    color: Colors.green,
                    onTap: () => setState(() => _selectedGoal = 'muscle_gain'),
                  ),
                  const SizedBox(height: 30),

                  // Weekly Goal (only if not maintain)
                  if (_selectedGoal != 'maintain') ...[
                    const SectionTitle(title: 'Weekly Goal'),
                    const SizedBox(height: 15),
                    WeeklyGoalItem(
                      goal: 0.25,
                      isSelected: _selectedWeeklyGoal == 0.25,
                      action: _selectedGoal == 'weight_loss' ? 'Lose' : 'Gain',
                      onTap: () => setState(() => _selectedWeeklyGoal = 0.25),
                    ),
                    const SizedBox(height: 12),
                    WeeklyGoalItem(
                      goal: 0.5,
                      isSelected: _selectedWeeklyGoal == 0.5,
                      action: _selectedGoal == 'weight_loss' ? 'Lose' : 'Gain',
                      onTap: () => setState(() => _selectedWeeklyGoal = 0.5),
                    ),
                    const SizedBox(height: 12),
                    WeeklyGoalItem(
                      goal: 0.75,
                      isSelected: _selectedWeeklyGoal == 0.75,
                      action: _selectedGoal == 'weight_loss' ? 'Lose' : 'Gain',
                      onTap: () => setState(() => _selectedWeeklyGoal = 0.75),
                    ),
                    const SizedBox(height: 12),
                    WeeklyGoalItem(
                      goal: 1.0,
                      isSelected: _selectedWeeklyGoal == 1.0,
                      action: _selectedGoal == 'weight_loss' ? 'Lose' : 'Gain',
                      onTap: () => setState(() => _selectedWeeklyGoal = 1.0),
                    ),
                    const SizedBox(height: 30),
                  ],

                  // Calculate Button
                  SizedBox(
                    width: double.infinity,
                    child: CustomBTN(
                      press: _handleCalculate,
                      color: AppColors.primaryColor,
                      radius: 15,
                      widget: Text(
                        'Calculate',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  @override
  void dispose() {
    _weightController.dispose();
    _heightController.dispose();
    _ageController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    // Load saved data after the first frame to avoid circular dependency
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadSavedData();
    });
  }

  void _handleCalculate() {
    // Validate weight
    final weightError =
        UserDataModel.validateWeightInput(_weightController.text);
    if (weightError != null) {
      showValidationErrorFlushbar(context, weightError);
      return;
    }

    // Validate height
    final heightError =
        UserDataModel.validateHeightInput(_heightController.text);
    if (heightError != null) {
      showValidationErrorFlushbar(context, heightError);
      return;
    }

    // Validate age
    final ageError = UserDataModel.validateAgeInput(_ageController.text);
    if (ageError != null) {
      showValidationErrorFlushbar(context, ageError);
      return;
    }

    try {
      final userData = UserDataModel(
        weight: double.parse(_weightController.text),
        height: double.parse(_heightController.text),
        age: int.parse(_ageController.text),
        gender: _selectedGender,
        activityLevel: _selectedActivityLevel,
        goal: _selectedGoal,
        weeklyGoal: _selectedWeeklyGoal,
      );

      ref.read(caloriesCalculatorProvider.notifier).calculate(userData);
      TalkerService.info('Navigating to results', 'CALORIES_CALCULATOR');
      showSuccessFlushbar(context, 'Calculation completed successfully! 🎉');
      context.pushNamed(AppRouters.caloriesResults);
    } catch (e) {
      showErrorFlushbar(context, 'Failed to calculate: ${e.toString()}');
    }
  }

  void _handleReset() {
    ref.read(caloriesCalculatorProvider.notifier).reset();
    _weightController.clear();
    _heightController.clear();
    _ageController.clear();
    setState(() {
      _selectedGender = 'male';
      _selectedActivityLevel = 'sedentary';
      _selectedGoal = 'maintain';
      _selectedWeeklyGoal = 0.5;
    });
  }

  void _loadSavedData() {
    final state = ref.read(caloriesCalculatorProvider);
    if (state.userData != null) {
      final userData = state.userData!;
      _weightController.text = userData.weight.toString();
      _heightController.text = userData.height.toString();
      _ageController.text = userData.age.toString();
      _selectedGender = userData.gender;
      _selectedActivityLevel = userData.activityLevel;
      _selectedGoal = userData.goal;
      _selectedWeeklyGoal = userData.weeklyGoal;
      setState(() {});
    }
  }
}

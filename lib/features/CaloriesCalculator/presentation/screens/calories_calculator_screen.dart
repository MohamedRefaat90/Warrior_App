import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/functions/flushbar.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
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

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(caloriesCalculatorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          'caloriesCalculator'.tr(context),
          style: TextStyle(fontFamily: 'kings', fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          if (state.hasCalculated)
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _handleReset,
              tooltip: 'resetCalculator'.tr(context),
            ),
        ],
      ),
      body: state.isLoading
          ? const Center(child: Loader())
          : SingleChildScrollView(
              padding: context.screenPadding,
              child: Center(
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: ResponsiveUtils.maxContentWidth,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header Section
                      Center(child: const CalculatorHeaderCard()),
                      SizedBox(height: context.largeSpacing),

                      // Basic Info Section
                      SectionTitle(title: 'basicInformation'.tr(context)),
                      SizedBox(height: context.mediumSpacing),
                      InputCard(
                        label: 'weight'.tr(context),
                        hint: 'enterWeight'.tr(context),
                        suffix: 'kg'.tr(context),
                        controller: _weightController,
                      ),
                      SizedBox(height: context.mediumSpacing),
                      InputCard(
                        label: 'height'.tr(context),
                        hint: 'enterHeight'.tr(context),
                        suffix: 'cm'.tr(context),
                        controller: _heightController,
                      ),
                      SizedBox(height: context.mediumSpacing),
                      InputCard(
                        label: 'age'.tr(context),
                        hint: 'enterAge'.tr(context),
                        suffix: 'years'.tr(context),
                        controller: _ageController,
                      ),
                      SizedBox(height: context.largeSpacing),

                      // Gender Selection
                      SectionTitle(title: 'gender'.tr(context)),
                      SizedBox(height: context.mediumSpacing),
                      Row(
                        children: [
                          Expanded(
                            child: GenderSelectionCard(
                              icon: Icons.male,
                              label: 'male'.tr(context),
                              isSelected: _selectedGender == 'male',
                              onTap: () =>
                                  setState(() => _selectedGender = 'male'),
                            ),
                          ),
                          SizedBox(width: context.mediumSpacing),
                          Expanded(
                            child: GenderSelectionCard(
                              icon: Icons.female,
                              label: 'female'.tr(context),
                              isSelected: _selectedGender == 'female',
                              onTap: () =>
                                  setState(() => _selectedGender = 'female'),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: context.largeSpacing),

                      // Activity Level
                      SectionTitle(title: 'activityLevel'.tr(context)),
                      SizedBox(height: context.mediumSpacing),
                      ..._getActivityLevels(context).map((level) {
                        return Padding(
                          padding:
                              EdgeInsets.only(bottom: context.smallSpacing),
                          child: ActivityLevelItem(
                            value: level['value']!,
                            label: level['label']!,
                            description: level['desc']!,
                            isSelected:
                                _selectedActivityLevel == level['value'],
                            onTap: () {
                              setState(() =>
                                  _selectedActivityLevel = level['value']!);
                            },
                          ),
                        );
                      }),
                      SizedBox(height: context.largeSpacing),

                      // Goal Selection
                      SectionTitle(title: 'yourGoal'.tr(context)),
                      SizedBox(height: context.mediumSpacing),
                      GoalCard(
                        icon: Icons.trending_down,
                        title: 'weightLoss'.tr(context),
                        subtitle: 'loseWeightGradually'.tr(context),
                        value: 'weight_loss',
                        isSelected: _selectedGoal == 'weight_loss',
                        color: Colors.orange,
                        onTap: () =>
                            setState(() => _selectedGoal = 'weight_loss'),
                      ),
                      SizedBox(height: context.smallSpacing),
                      GoalCard(
                        icon: Icons.trending_flat,
                        title: 'maintainWeight'.tr(context),
                        subtitle: 'keepCurrentWeight'.tr(context),
                        value: 'maintain',
                        isSelected: _selectedGoal == 'maintain',
                        color: Colors.blue,
                        onTap: () => setState(() => _selectedGoal = 'maintain'),
                      ),
                      SizedBox(height: context.smallSpacing),
                      GoalCard(
                        icon: Icons.trending_up,
                        title: 'muscleGain'.tr(context),
                        subtitle: 'buildMuscleMass'.tr(context),
                        value: 'muscle_gain',
                        isSelected: _selectedGoal == 'muscle_gain',
                        color: Colors.green,
                        onTap: () =>
                            setState(() => _selectedGoal = 'muscle_gain'),
                      ),
                      SizedBox(height: context.largeSpacing),

                      // Weekly Goal (only if not maintain)
                      if (_selectedGoal != 'maintain') ...[
                        SectionTitle(title: 'weeklyGoal'.tr(context)),
                        SizedBox(height: context.mediumSpacing),
                        WeeklyGoalItem(
                          goal: 0.25,
                          isSelected: _selectedWeeklyGoal == 0.25,
                          action: _selectedGoal == 'weight_loss'
                              ? 'lose'.tr(context)
                              : 'gain'.tr(context),
                          onTap: () =>
                              setState(() => _selectedWeeklyGoal = 0.25),
                        ),
                        SizedBox(height: context.smallSpacing),
                        WeeklyGoalItem(
                          goal: 0.5,
                          isSelected: _selectedWeeklyGoal == 0.5,
                          action: _selectedGoal == 'weight_loss'
                              ? 'lose'.tr(context)
                              : 'gain'.tr(context),
                          onTap: () =>
                              setState(() => _selectedWeeklyGoal = 0.5),
                        ),
                        SizedBox(height: context.smallSpacing),
                        WeeklyGoalItem(
                          goal: 0.75,
                          isSelected: _selectedWeeklyGoal == 0.75,
                          action: _selectedGoal == 'weight_loss'
                              ? 'lose'.tr(context)
                              : 'gain'.tr(context),
                          onTap: () =>
                              setState(() => _selectedWeeklyGoal = 0.75),
                        ),
                        SizedBox(height: context.smallSpacing),
                        WeeklyGoalItem(
                          goal: 1.0,
                          isSelected: _selectedWeeklyGoal == 1.0,
                          action: _selectedGoal == 'weight_loss'
                              ? 'lose'.tr(context)
                              : 'gain'.tr(context),
                          onTap: () =>
                              setState(() => _selectedWeeklyGoal = 1.0),
                        ),
                        SizedBox(height: context.largeSpacing),
                      ],

                      // Calculate Button
                      SizedBox(
                        width: double.infinity,
                        child: CustomBTN(
                          press: _handleCalculate,
                          color: AppColors.primaryColor,
                          radius: context.responsiveBorderRadius,
                          widget: Text(
                            'calculate'.tr(context),
                            style: Theme.of(context)
                                .textTheme
                                .titleMedium
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.white,
                                ),
                          ),
                        ),
                      ),
                      SizedBox(height: context.mediumSpacing),
                    ],
                  ),
                ),
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

  // Activity level options
  List<Map<String, String>> _getActivityLevels(BuildContext context) => [
        {
          'value': 'sedentary',
          'label': 'sedentary'.tr(context),
          'desc': 'sedentaryDesc'.tr(context),
        },
        {
          'value': 'lightly_active',
          'label': 'lightlyActive'.tr(context),
          'desc': 'lightlyActiveDesc'.tr(context),
        },
        {
          'value': 'moderately_active',
          'label': 'moderatelyActive'.tr(context),
          'desc': 'moderatelyActiveDesc'.tr(context),
        },
        {
          'value': 'very_active',
          'label': 'veryActive'.tr(context),
          'desc': 'veryActiveDesc'.tr(context),
        },
        {
          'value': 'extra_active',
          'label': 'extraActive'.tr(context),
          'desc': 'extraActiveDesc'.tr(context),
        },
      ];

  void _handleCalculate() {
    // Validate weight
    final weightError =
        UserDataModel.validateWeightInput(_weightController.text, context);
    if (weightError != null) {
      showValidationErrorFlushbar(context, weightError);
      return;
    }

    // Validate height
    final heightError =
        UserDataModel.validateHeightInput(_heightController.text, context);
    if (heightError != null) {
      showValidationErrorFlushbar(context, heightError);
      return;
    }

    // Validate age
    final ageError =
        UserDataModel.validateAgeInput(_ageController.text, context);
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
      showSuccessFlushbar(context, 'calculationSuccess'.tr(context));
      context.pushNamed(AppRouters.caloriesResults);
    } catch (e) {
      showErrorFlushbar(
        context,
        '${'failedToCalculate'.tr(context)}: ${e.toString()}',
      );
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

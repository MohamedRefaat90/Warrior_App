import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/provider/calories_calculator_provider.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/macro_pie_chart_painter.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/macro_row.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/main_calories_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/metric_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/results_header_card.dart';
import 'package:Warrior/features/CaloriesCalculator/presentation/widgets/section_title.dart';
import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class CaloriesResultsScreen extends ConsumerWidget {
  const CaloriesResultsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(caloriesCalculatorProvider);

    if (state.results == null) {
      return Scaffold(
        appBar: AppBar(
          title: const Text('Results'),
          centerTitle: true,
        ),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.info_outline,
                size: 80,
                color: AppColors.primaryColor,
              ),
              const SizedBox(height: 20),
              Text(
                'No calculation results available',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'Please complete the calculator form first',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.black.withValues(alpha: 0.6),
                ),
              ),
              const SizedBox(height: 30),
              CustomBTN(
                press: () => Navigator.pop(context),
                color: AppColors.primaryColor,
                radius: 15,
                widget: Text(
                  'Go Back',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    final results = state.results!;
    final macros = results.macros;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Your Results',
          style: TextStyle(fontFamily: 'kings', fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Navigator.pop(context),
            tooltip: 'New Calculation',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header Card
            Center(
              child: FadeInDown(
                duration: const Duration(milliseconds: 600),
                child: ResultsHeaderCard(
                  goal: results.goal,
                  weeklyGoalDescription: results.weeklyGoalDescription,
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Main Calories Card
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 100),
              child: MainCaloriesCard(
                dailyCaloricNeeds: results.dailyCaloricNeeds,
              ),
            ),
            const SizedBox(height: 25),

            // Metrics Section
            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 200),
              child: const SectionTitle(title: 'Metabolic Metrics'),
            ),
            const SizedBox(height: 15),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'BMR',
                      value: '${results.bmr.round()}',
                      subtitle: 'Basal Metabolic\nRate',
                      icon: Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: MetricCard(
                      title: 'TDEE',
                      value: '${results.tdee.round()}',
                      subtitle: 'Total Daily Energy\nExpenditure',
                      icon: Icons.local_fire_department,
                      color: Colors.deepOrange,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),

            // Macros Chart Section
            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 400),
              child: const SectionTitle(title: 'Macronutrient Split'),
            ),
            const SizedBox(height: 15),
            ZoomIn(
              duration: const Duration(milliseconds: 800),
              delay: const Duration(milliseconds: 500),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.black.withValues(alpha: 0.08),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: SizedBox(
                  height: 280,
                  child: MacroPieChart(
                    proteinPercent: macros.proteinPercentage,
                    carbsPercent: macros.carbsPercentage,
                    fatsPercent: macros.fatsPercentage,
                    proteinGrams: macros.proteinGrams,
                    carbsGrams: macros.carbsGrams,
                    fatsGrams: macros.fatsGrams,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),

            // Macros Details
            FadeInLeft(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 600),
              child: const SectionTitle(title: 'Daily Macros Target'),
            ),
            const SizedBox(height: 15),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 650),
              child: MacroRow(
                label: 'Protein',
                grams: macros.proteinGrams,
                calories: macros.proteinCalories,
                percentage: macros.proteinPercentage,
                color: Color.fromARGB(255, 238, 31, 31),
              ),
            ),
            const SizedBox(height: 12),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 700),
              child: MacroRow(
                label: 'Carbohydrates',
                grams: macros.carbsGrams,
                calories: macros.carbsCalories,
                percentage: macros.carbsPercentage,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 12),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 750),
              child: MacroRow(
                label: 'Fats',
                grams: macros.fatsGrams,
                calories: macros.fatsCalories,
                percentage: macros.fatsPercentage,
                color: Colors.orange,
              ),
            ),
            const SizedBox(height: 25),

            // Reset Button
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 900),
              child: SizedBox(
                width: double.infinity,
                child: CustomBTN(
                  press: () {
                    ref.read(caloriesCalculatorProvider.notifier).reset();
                    Navigator.pop(context);
                  },
                  color: AppColors.primaryColor,
                  radius: 15,
                  widget: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.refresh, color: Colors.white),
                      const SizedBox(width: 10),
                      Text(
                        'New Calculation',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.white,
                        ),
                      ),
                    ],
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
}

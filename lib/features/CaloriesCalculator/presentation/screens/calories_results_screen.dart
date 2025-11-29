import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
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
          title: Text('results'.tr(context)),
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
                'noResultsAvailable'.tr(context),
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                'completeFormFirst'.tr(context),
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
                  'goBack'.tr(context),
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
        title: Text(
          'yourResults'.tr(context),
          style: TextStyle(fontFamily: 'kings', fontWeight: FontWeight.w900),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => Navigator.pop(context),
            tooltip: 'newCalculation'.tr(context),
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
              child: SectionTitle(title: 'metabolicMetrics'.tr(context)),
            ),
            const SizedBox(height: 15),
            FadeInUp(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 300),
              child: Row(
                children: [
                  Expanded(
                    child: MetricCard(
                      title: 'bmr'.tr(context),
                      value: '${results.bmr.round()}',
                      subtitle: 'basalMetabolicRate'.tr(context),
                      icon: Icons.favorite,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 15),
                  Expanded(
                    child: MetricCard(
                      title: 'tdee'.tr(context),
                      value: '${results.tdee.round()}',
                      subtitle: 'totalDailyEnergyExpenditure'.tr(context),
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
              child: SectionTitle(title: 'macronutrientSplit'.tr(context)),
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
              child: SectionTitle(title: 'dailyMacrosTarget'.tr(context)),
            ),
            const SizedBox(height: 15),
            FadeInRight(
              duration: const Duration(milliseconds: 600),
              delay: const Duration(milliseconds: 650),
              child: MacroRow(
                label: 'protein'.tr(context),
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
                label: 'carbs'.tr(context),
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
                label: 'fats'.tr(context),
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
                        'newCalculation'.tr(context),
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

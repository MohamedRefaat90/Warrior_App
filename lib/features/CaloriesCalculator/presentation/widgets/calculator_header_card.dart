import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

/// Header card for the calculator screen
class CalculatorHeaderCard extends StatelessWidget {
  const CalculatorHeaderCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: context.cardPadding,
      width: context.screenWidth * 0.7,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.red,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius + 4),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(
            Icons.calculate_rounded,
            size: ResponsiveUtils.iconSize(context,
                mobile: 50, tablet: 56, desktop: 64),
            color: AppColors.white,
          ),
          SizedBox(height: context.smallSpacing),
          Text(
            'calculateYourDailyCaloricNeeds'.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
          ),
          SizedBox(height: context.smallSpacing / 2),
          Text(
            'getPersonalizedNutritionTargets'.tr(context),
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
          ),
        ],
      ),
    );
  }
}

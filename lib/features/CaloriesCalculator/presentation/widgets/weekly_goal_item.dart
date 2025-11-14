import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Weekly goal selection item widget
class WeeklyGoalItem extends StatelessWidget {
  final double goal;
  final bool isSelected;
  final String action;
  final VoidCallback onTap;

  const WeeklyGoalItem({
    super.key,
    required this.goal,
    required this.isSelected,
    required this.action,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(bottom: 12.h),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor!.withValues(alpha: 0.1)
                : isDarkMode
                    ? AppColors.darkSurface
                    : AppColors.white,
            borderRadius: BorderRadius.circular(15.r),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor!
                  : AppColors.black.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor!.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.2 : 1.0,
                child: Icon(
                  isSelected ? Icons.check_circle : Icons.circle_outlined,
                  color: isSelected
                      ? AppColors.primaryColor
                      : isDarkMode
                          ? AppColors.white.withValues(alpha: 0.3)
                          : AppColors.black.withValues(alpha: 0.3),
                ),
              ),
              SizedBox(width: 15.w),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 300),
                style: TextStyle(
                  fontSize: 15.sp,
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  color: isDarkMode ? AppColors.white : AppColors.black,
                ),
                child: Text('$action $goal kg per week'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

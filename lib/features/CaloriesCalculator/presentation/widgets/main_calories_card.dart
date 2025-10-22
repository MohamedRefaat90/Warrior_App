import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Main calories display card
class MainCaloriesCard extends StatelessWidget {
  final double dailyCaloricNeeds;

  const MainCaloriesCard({
    super.key,
    required this.dailyCaloricNeeds,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(25.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor!,
            AppColors.red!,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor!.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Daily Caloric Target',
            style: TextStyle(
              fontSize: 16.sp,
              color: AppColors.white.withValues(alpha: 0.9),
            ),
          ),
          SizedBox(height: 10.h),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${dailyCaloricNeeds.round()}',
                style: TextStyle(
                  fontSize: 48.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.white,
                ),
              ),
              SizedBox(width: 5.w),
              Text(
                'kcal',
                style: TextStyle(
                  fontSize: 18.sp,
                  color: AppColors.white.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          SizedBox(height: 5.h),
          Text(
            'per day',
            style: TextStyle(
              fontSize: 14.sp,
              color: AppColors.white.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}

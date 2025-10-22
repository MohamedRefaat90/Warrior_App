import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Header card for results screen showing goal type
class ResultsHeaderCard extends StatelessWidget {
  final String goal;
  final String weeklyGoalDescription;

  const ResultsHeaderCard({
    super.key,
    required this.goal,
    required this.weeklyGoalDescription,
  });

  @override
  Widget build(BuildContext context) {
    IconData goalIcon;
    Color goalColorDark;
    Color goalColorLight;
    String goalText;

    switch (goal) {
      case 'weight_loss':
        goalIcon = Icons.trending_down;
        goalColorDark = Colors.orange.shade700;
        goalColorLight = Colors.orange.shade400;
        goalText = 'Weight Loss Plan';
        break;
      case 'muscle_gain':
        goalIcon = Icons.trending_up;
        goalColorDark = Colors.green.shade700;
        goalColorLight = Colors.green.shade400;
        goalText = 'Muscle Gain Plan';
        break;
      default:
        goalIcon = Icons.trending_flat;
        goalColorDark = Colors.blue.shade700;
        goalColorLight = Colors.blue.shade400;
        goalText = 'Maintenance Plan';
    }

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [goalColorDark, goalColorLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20.r),
        boxShadow: [
          BoxShadow(
            color: goalColorDark.withValues(alpha: 0.3),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(goalIcon, size: 50.sp, color: AppColors.white),
          SizedBox(height: 10.h),
          Text(
            goalText,
            style: TextStyle(
              fontSize: 22.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.white,
            ),
          ),
          if (goal != 'maintain') ...[
            SizedBox(height: 5.h),
            Text(
              weeklyGoalDescription,
              style: TextStyle(
                fontSize: 14.sp,
                color: AppColors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

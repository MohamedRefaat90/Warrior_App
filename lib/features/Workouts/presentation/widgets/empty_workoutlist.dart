import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyWorkoutList extends StatelessWidget {
  const EmptyWorkoutList({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text('No Workouts Found',
            style: TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.bold,
                fontSize: 22.sp)),
        SizedBox(height: 20.h),
        CustomBTN(
            widget: Text("Create Workout Set"),
            color: AppColors.primaryColor,
            padding: 12,
            press: () {})
      ]),
    );
  }
}

import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class EmptyWorkoutExercises extends ConsumerWidget {
  final WorkoutSetModel workout;

  const EmptyWorkoutExercises({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.w),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: 80.w,
              color: Colors.grey[400],
            ),
            SizedBox(height: 24.h),
            Text(
              'No Exercises Yet',
              style: TextStyle(
                fontFamily: 'Kings',
                fontWeight: FontWeight.bold,
                fontSize: 24.sp,
                color: Colors.grey[700],
              ),
            ),
            SizedBox(height: 12.h),
            Text(
              'Your workout "${workout.name}" is ready for some exercises!',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 16.sp,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 8.h),
            Text(
              'Add exercises to get started with your training.',
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 14.sp,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

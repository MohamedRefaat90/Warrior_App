import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PredefinedWorkoutCard extends StatelessWidget {
  final WorkoutSetModel workout;

  const PredefinedWorkoutCard({
    super.key,
    required this.workout,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        context.pushNamed(
          AppRouters.predefinedWorkoutDetails,
          extra: workout,
        );
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                workout.name!,
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 12.sp,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'poppins',
                ),
              ),
              SizedBox(height: 8.h),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${workout.workoutItems!.length} ",
                    style: TextStyle(
                      fontSize: 13.sp,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Icon(Icons.fitness_center, size: 13.sp),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

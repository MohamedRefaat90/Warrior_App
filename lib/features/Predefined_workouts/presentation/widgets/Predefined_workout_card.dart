import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/provider/predefined_provider.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class PredefinedWorkoutCard extends ConsumerStatefulWidget {
  final WorkoutSetModel workout;
  const PredefinedWorkoutCard({super.key, required this.workout});

  @override
  ConsumerState<PredefinedWorkoutCard> createState() =>
      _PredefinedWorkoutCardState();
}

class _PredefinedWorkoutCardState extends ConsumerState<PredefinedWorkoutCard> {
  @override
  Widget build(BuildContext context) {
    final viewMode = ref.watch(viewModeProvider);
    return GestureDetector(
      onTap: () {
        context.pushNamed(AppRouters.predefinedWorkoutDetails,
            extra: widget.workout);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          child: Column(
              mainAxisAlignment: viewMode == WorkoutViewMode.list
                  ? MainAxisAlignment.start
                  : MainAxisAlignment.center,
              crossAxisAlignment: viewMode == WorkoutViewMode.list
                  ? CrossAxisAlignment.start
                  : CrossAxisAlignment.center,
              children: [
                Text(
                  widget.workout.name!,
                  style: TextStyle(
                    fontSize: 16.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                  ),
                ),
                viewMode == WorkoutViewMode.list
                    ? SizedBox(height: 0.01.sh)
                    : SizedBox(),
                Row(
                  mainAxisAlignment: viewMode == WorkoutViewMode.list
                      ? MainAxisAlignment.start
                      : MainAxisAlignment.center,
                  children: [
                    Text(
                      "${widget.workout.workoutItems!.length} ",
                      style: TextStyle(
                          fontSize: 13.sp, fontWeight: FontWeight.bold),
                    ),
                    viewMode == WorkoutViewMode.grid
                        ? SizedBox(height: 0.03.sh)
                        : SizedBox(),
                    Icon(Icons.fitness_center, size: 13.sp),
                  ],
                ),
              ]),
        ),
      ),
    );
  }
}

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class PredefinedWorkoutCard extends StatelessWidget {
  final WorkoutSetModel workout;

  const PredefinedWorkoutCard({super.key, required this.workout});

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: GestureDetector(
        onTap: () {
          context.pushNamed(
            AppRouters.predefinedWorkoutDetails,
            extra: workout as WorkoutSetModel,
          );
        },
        child: Card(
          clipBehavior: Clip.antiAlias,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(5),
          ),
          color: AppColors.lightTail,
          elevation: 20,
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: context.smallSpacing,
              vertical: context.smallSpacing / 2,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  workout.name!,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                ),
                SizedBox(height: context.smallSpacing),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "${workout.workoutItems!.length} ",
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                    ),
                    Icon(
                      Icons.fitness_center,
                      size: ResponsiveUtils.iconSize(
                        context,
                        mobile: 13,
                        tablet: 15,
                        desktop: 17,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

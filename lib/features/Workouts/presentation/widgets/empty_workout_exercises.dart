import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class EmptyWorkoutExercises extends ConsumerWidget {
  final WorkoutSetModel workout;

  const EmptyWorkoutExercises({super.key, required this.workout});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: context.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.fitness_center_outlined,
              size: context.largeIconSize,
              color: Colors.grey[400],
            ),
            SizedBox(height: context.largeSpacing),
            Text(
              'No Exercises Yet',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontFamily: 'Kings',
                    fontWeight: FontWeight.bold,
                    color: Colors.grey[700],
                  ),
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              'Your workout "${workout.name}" is ready for some exercises!',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              'Add exercises to get started with your training.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
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

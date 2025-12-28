import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/FinishBTN.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/create_workout_warning.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutCreationAndWarning extends ConsumerWidget {
  final bool isComingFromWorkoutScreen;
  final bool appendToExistingWorkoutSet;
  const WorkoutCreationAndWarning(
      {super.key,
      required this.isComingFromWorkoutScreen,
      required this.appendToExistingWorkoutSet});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    return Column(children: [
      if (isComingFromWorkoutScreen == true &&
          (workoutNotifier.newWorkout.workoutItems == null ||
              workoutNotifier.newWorkout.workoutItems!.isEmpty)) ...[
        CreateWorkoutWarning(),
        const SizedBox(height: 8),
      ],
      if (isComingFromWorkoutScreen) ...[
        FinishBTN(
            primaryColor: AppColors.darkPrimary,
            appendToExistingWorkoutSet: appendToExistingWorkoutSet),
        const SizedBox(height: 16),
      ]
    ]);
  }
}

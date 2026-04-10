import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/FinishBTN.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/create_workout_warning.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutCreationAndWarning extends ConsumerWidget {
  final bool isComingFromWorkoutScreen;
  final bool appendToExistingWorkoutSet;
  final int extraPops;
  const WorkoutCreationAndWarning({
    super.key,
    required this.isComingFromWorkoutScreen,
    required this.appendToExistingWorkoutSet,
    this.extraPops = 0,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final providerState = ref.watch(workoutsProvider);
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    final showWarning = isComingFromWorkoutScreen == true &&
        !providerState.isSuccess &&
        (workoutNotifier.newWorkout.workoutItems == null ||
            workoutNotifier.newWorkout.workoutItems!.isEmpty);

    return Column(children: [
      ClipRect(
        child: AnimatedAlign(
          alignment: Alignment.topCenter,
          heightFactor: showWarning ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          child: AnimatedOpacity(
            opacity: showWarning ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 200),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CreateWorkoutWarning(),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
      if (isComingFromWorkoutScreen) ...[
        FinishBTN(
            primaryColor: AppColors.darkPrimary,
            appendToExistingWorkoutSet: appendToExistingWorkoutSet,
            extraPops: extraPops),
        const SizedBox(height: 16),
      ]
    ]);
  }
}

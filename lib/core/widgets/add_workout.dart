import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class AddWorkoutBtn extends ConsumerWidget {
  final WorkoutSetModel workout;

  final WorkoutsNotifier workoutNotifier;
  const AddWorkoutBtn(
      {super.key, required this.workout, required this.workoutNotifier});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.all(10),
      child: ref.watch(workoutsProvider).isLoading
          ? const SizedBox(
              height: 50,
              width: 50,
              child: Loader(),
            )
          : CustomBTN(
              widget: Text('Add to my workouts'.capitalizeWord()),
              width: double.infinity,
              color: AppColors.primaryColor,
              press: () async {
                // Fill and create the workout
                workoutNotifier.fillNewWorkout(
                  name: workout.name,
                  description: workout.description,
                  workoutItems: workout.workoutItems,
                );
                await workoutNotifier.createWorkoutSet();

                // Navigate to workouts screen (success message is handled by provider)
                if (context.mounted) {
                  context.pushReplacement(AppRouters.workouts);
                }
              },
            ),
    );
  }
}

import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workout_exercises.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredefinedExerciseGridView extends ConsumerStatefulWidget {
  final WorkoutSetModel workout;

  const PredefinedExerciseGridView(this.workout, {super.key});

  @override
  ConsumerState<PredefinedExerciseGridView> createState() =>
      _PredefinedExerciseGridViewState();
}

class _PredefinedExerciseGridViewState
    extends ConsumerState<PredefinedExerciseGridView> {
  @override
  Widget build(BuildContext context) {
    // ref.watch(workoutsProvider);

    // // Check if workout has no exercises
    // if (widget.workout.workoutItems == null ||
    //     widget.workout.workoutItems!.isEmpty) {
    //   return EmptyWorkoutExercises(workout: widget.workout);
    // }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
                itemCount: widget.workout.workoutItems!.length,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 15,
                  childAspectRatio: 0.9,
                ),
                itemBuilder: (context, index) {
                  final WorkoutItemModel workoutExercise =
                      widget.workout.workoutItems![index];
                  return ExerciseCard(
                    exercise: workoutExercise.exercise,
                    isComingFromWorkoutScreen: false,
                  );
                }),
          ],
        ),
      ),
    );
  }
}

import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';

class ExercisesGridView extends StatelessWidget {
  final List<ExerciseModel> exercises;
  final bool? isComingFromWorkoutScreen;
  const ExercisesGridView(
      {super.key, required this.exercises, this.isComingFromWorkoutScreen});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          itemCount: exercises.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            final ExerciseModel exercise = exercises[index];
            return ExerciseCard(
              exercise: exercise,
              isComingFromWorkoutScreen: isComingFromWorkoutScreen,
            );
          }),
    );
  }
}

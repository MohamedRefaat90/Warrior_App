import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:flutter/material.dart';

class ExercisesGridView extends StatelessWidget {
  List<ExerciseModel> exercises;
  ExercisesGridView({super.key, required this.exercises});
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
            HiveBoxes.exercisesBox.add(exercise);
            return ExerciseCard(exercise: exercise);
          }),
    );
  }
}

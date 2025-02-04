import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercises_gridview.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';

class WorkoutDetails extends StatelessWidget {
  final WorkoutSetModel workout;

  const WorkoutDetails(this.workout, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          workout.name!,
          style: TextStyle(
              fontFamily: 'poppins',
              fontWeight: FontWeight.bold,
              letterSpacing: 1.5),
        ),
      ),
      body: ExercisesGridView(
        exercises: workout.workoutItems!.map((e) => e.exercise).toList(),
        isComingFromWorkoutScreen: false,
      ),
    );
  }
}

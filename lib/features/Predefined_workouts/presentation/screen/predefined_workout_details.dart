import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_exercise_gridwiew.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';

class PredefinedWorkoutDetails extends StatelessWidget {
  final WorkoutSetModel workout;

  const PredefinedWorkoutDetails(this.workout, {super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          workout.name ?? 'Workout',
          style: const TextStyle(
              fontFamily: "Kings", fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(child: PredefinedExerciseGridView(workout)),
        ],
      ),
    );
  }
}

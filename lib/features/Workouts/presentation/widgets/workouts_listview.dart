import 'package:flutter/material.dart';

import '../../data/models/workoutSet_model.dart';

class WorkoutsListview extends StatelessWidget {
  const WorkoutsListview(this.workouts, {super.key});
  final List<WorkoutSetModel> workouts;
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: workouts.length,
      itemBuilder: (context, index) {
        final workout = workouts[index];
        return ListTile(
          title: Text(workout.name),
          subtitle: Text(workout.description),
        );
      },
    );
  }
}

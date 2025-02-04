import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workout_card.dart';
import 'package:flutter/material.dart';

class WorkoutsListview extends StatelessWidget {
  final List<WorkoutSetModel> workouts;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  const WorkoutsListview(
      this.workouts, this.nameController, this.descriptionController,
      {super.key});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ListView.builder(
        itemCount: workouts.length,
        itemBuilder: (context, index) {
          return WorkoutCard(
            workout: workouts[index],
            nameController: nameController,
            descriptionController: descriptionController,
          );
        },
      ),
    );
  }
}

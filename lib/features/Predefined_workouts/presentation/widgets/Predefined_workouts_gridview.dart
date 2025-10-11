import 'dart:developer';

import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_workout_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredefinedWorkoutsGridView extends ConsumerStatefulWidget {
  final List<WorkoutSetModel> workouts;

  const PredefinedWorkoutsGridView(this.workouts, {super.key});

  @override
  ConsumerState<PredefinedWorkoutsGridView> createState() =>
      _PredefinedWorkoutsGridViewState();
}

class _PredefinedWorkoutsGridViewState
    extends ConsumerState<PredefinedWorkoutsGridView> {
  @override
  Widget build(BuildContext context) {
    // if Local Storage Empty save Data From server
    if (HiveManager.workoutsBox.isEmpty) {
      log("Save New Data To Hive");
      HiveManager.saveToHive(
          HiveManager.predefinedWorkoutsBox, widget.workouts);
    }
    return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 15,
            childAspectRatio: 0.9,
          ),
          itemCount: widget.workouts.length,
          itemBuilder: (context, index) {
            return PredefinedWorkoutCard(
              key: Key("$index"),
              workout: widget.workouts[index],
            );
          },
        ));
  }
}

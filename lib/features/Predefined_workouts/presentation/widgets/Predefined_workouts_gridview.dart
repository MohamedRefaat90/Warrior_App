import 'dart:developer';

import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/native_ad_widget.dart';
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
          shrinkWrap: true,
          itemCount: widget.workouts.length + 1, // +1 for native ad
          itemBuilder: (context, index) {
            // Show native ad in middle (position 4, spans 2 columns)
            if (index == 4 && widget.workouts.length > 4) {
              return const NativeAdWidget();
            }

            // Adjust index after native ad
            final workoutIndex = index > 4 ? index - 1 : index;

            // Don't show item if we're past the end
            if (workoutIndex >= widget.workouts.length) {
              return const SizedBox.shrink();
            }

            return PredefinedWorkoutCard(
              key: Key("$workoutIndex"),
              workout: widget.workouts[workoutIndex],
            );
          },
        ));
  }
}

import 'dart:developer';

import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/native_ad_widget.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_workout_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredefinedWorkoutsListView extends ConsumerStatefulWidget {
  final List<WorkoutSetModel> workouts;

  const PredefinedWorkoutsListView(this.workouts, {super.key});

  @override
  ConsumerState<PredefinedWorkoutsListView> createState() =>
      _PredefinedWorkoutsListViewState();
}

class _PredefinedWorkoutsListViewState
    extends ConsumerState<PredefinedWorkoutsListView> {
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
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.workouts.length + 1, // +1 for native ad
          itemBuilder: (context, index) {
            // Show native ad in the middle (after 3rd item)
            if (index == 3 && widget.workouts.length > 3) {
              return const NativeAdWidget();
            }

            // Adjust index after native ad
            final workoutIndex = index > 3 ? index - 1 : index;

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

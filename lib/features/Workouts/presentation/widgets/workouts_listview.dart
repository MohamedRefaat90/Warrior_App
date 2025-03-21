import 'dart:developer';

import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutsListview extends ConsumerStatefulWidget {
  final List<WorkoutSetModel> workouts;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  const WorkoutsListview(
      this.workouts, this.nameController, this.descriptionController,
      {super.key});

  @override
  ConsumerState<WorkoutsListview> createState() => _WorkoutsListviewState();
}

class _WorkoutsListviewState extends ConsumerState<WorkoutsListview> {
  @override
  Widget build(BuildContext context) {
    // if Local Storage Empty Load Data From Database
    if (HiveManager.workoutsBox.isEmpty) {
      log("Save New Data To Hive");
      HiveManager.saveToHive(HiveManager.workoutsBox, widget.workouts);
    }
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0),
      child: ReorderableListView.builder(
        itemCount: widget.workouts.length,
        itemBuilder: (context, index) {
          return WorkoutCard(
            key: Key("$index"),
            index: index,
            workout: widget.workouts[index],
          );
        },
        onReorder: (oldIndex, newIndex) async {
          setState(() {
            if (oldIndex < newIndex) {
              newIndex -= 1;
            }
            final WorkoutSetModel item = widget.workouts.removeAt(oldIndex);
            widget.workouts.insert(newIndex, item);
          });
          if (ConnectivityChecker.isOnline!) {
            await ref
                .read(workoutsProvider.notifier)
                .reorderWorkoutsList(widget.workouts);
          }
          await HiveManager.saveToHive(
              HiveManager.workoutsBox, widget.workouts);
        },
      ),
    );
  }
}

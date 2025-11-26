import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_row.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';

/// A wrapper component that displays workouts in multiple rows,
/// with up to 3 cards per row
class WorkoutGrid extends StatelessWidget {
  final List<WorkoutSetModel> workouts;
  final double? verticalSpacing;

  const WorkoutGrid({
    super.key,
    required this.workouts,
    this.verticalSpacing,
  });

  @override
  Widget build(BuildContext context) {
    final spacing = verticalSpacing ?? context.mediumSpacing;

    // Split workouts into chunks of 3
    final List<List<WorkoutSetModel>> rows = [];
    for (int i = 0; i < workouts.length; i += 3) {
      final end = (i + 3 < workouts.length) ? i + 3 : workouts.length;
      rows.add(workouts.sublist(i, end));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: List.generate(
        rows.length,
        (index) {
          return Padding(
            padding: EdgeInsets.only(
              bottom: index < rows.length - 1 ? spacing : 0,
            ),
            child: WorkoutRow(
              workouts: rows[index],
            ),
          );
        },
      ),
    );
  }
}

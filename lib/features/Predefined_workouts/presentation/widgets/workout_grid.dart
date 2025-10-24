import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_row.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A wrapper component that displays workouts in multiple rows,
/// with up to 3 cards per row
class WorkoutGrid extends StatelessWidget {
  final List<WorkoutSetModel> workouts;
  final double verticalSpacing;

  const WorkoutGrid({
    super.key,
    required this.workouts,
    this.verticalSpacing = 16,
  });

  @override
  Widget build(BuildContext context) {
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
              bottom: index < rows.length - 1 ? verticalSpacing.h : 0,
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

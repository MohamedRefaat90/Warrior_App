import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_workout_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A horizontal row of workout cards (max 3 cards)
class WorkoutRow extends StatelessWidget {
  final List<WorkoutSetModel> workouts;

  const WorkoutRow({
    super.key,
    required this.workouts,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate spacing between cards
        final spacing = 12.w;

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: List.generate(
            workouts.length > 3 ? 3 : workouts.length,
            (index) {
              if (index >= workouts.length) {
                return const SizedBox.shrink();
              }

              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                    right: index < 2 ? spacing : 0,
                  ),
                  child: PredefinedWorkoutCard(
                    key: Key("workout_${workouts[index].id}"),
                    workout: workouts[index],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

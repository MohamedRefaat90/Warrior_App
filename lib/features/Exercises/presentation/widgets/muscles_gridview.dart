import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/FinishBTN.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/grid_muscle_card.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusclesGridView extends ConsumerWidget {
  final List<MuscleModel> muscles;
  final bool? isComingFromWorkoutScreen;
  final bool? appendToExistingWorkoutSet;

  const MusclesGridView({
    super.key,
    required this.muscles,
    this.isComingFromWorkoutScreen,
    this.appendToExistingWorkoutSet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    final primaryColor = Color.fromARGB(255, 19, 67, 139);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: SingleChildScrollView(
        child: Column(
          children: [
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: ResponsiveUtils.getGridColumns(context),
                childAspectRatio: 0.85,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: muscles.length - 1,
              itemBuilder: (context, index) {
                final muscle = muscles[index];
                return TweenAnimationBuilder<double>(
                  tween: Tween(begin: 0.0, end: 1.0),
                  duration: Duration(milliseconds: 300 + (index * 50)),
                  curve: Curves.easeOutCubic,
                  builder: (context, value, child) {
                    return Transform.scale(
                      scale: value,
                      child: Opacity(
                        opacity: value,
                        child: child,
                      ),
                    );
                  },
                  child: GridMuscleCard(
                      muscle: muscle,
                      isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                      isDark: isDark,
                      primaryColor: primaryColor),
                );
              },
            ),
            const SizedBox(height: 10),
            Center(
              child: GridMuscleCard(
                  muscle: muscles.last,
                  isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                  isDark: isDark,
                  primaryColor: primaryColor),
            ),
            const SizedBox(height: 16),
            if (isComingFromWorkoutScreen == true &&
                (workoutNotifier.newWorkout.workoutItems == null ||
                    workoutNotifier.newWorkout.workoutItems!.isEmpty))
              Container(
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(Icons.warning_rounded, color: Colors.red.shade700),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        "You must add at least one exercise",
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 12),
            if (isComingFromWorkoutScreen ?? false)
              FinishBTN(
                  primaryColor: primaryColor,
                  appendToExistingWorkoutSet: appendToExistingWorkoutSet),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

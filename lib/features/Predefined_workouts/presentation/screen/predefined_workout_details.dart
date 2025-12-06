import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/add_workout.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_exercise_gridwiew.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class PredefinedWorkoutDetails extends ConsumerWidget {
  final WorkoutSetModel workout;

  const PredefinedWorkoutDetails(this.workout, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
        title: Text(
          workout.name ?? 'Workout',
          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                fontFamily: "Poppins",
                fontWeight: FontWeight.bold,
              ),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(
            maxWidth: ResponsiveUtils.maxContentWidth,
          ),
          child: Column(
            children: [
              const BannerAdWidget(
                  adUnitId: "ca-app-pub-7417773148722475/7261407290"),
              Expanded(child: PredefinedExerciseGridView(workout)),
              AddWorkoutBtn(workout: workout, workoutNotifier: workoutNotifier),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExercisesGridView extends ConsumerStatefulWidget {
  final List<ExerciseModel> exercises;
  final bool? isComingFromWorkoutScreen;
  const ExercisesGridView({
    super.key,
    required this.exercises,
    this.isComingFromWorkoutScreen,
  });

  @override
  ConsumerState<ExercisesGridView> createState() => _ExercisesGridViewState();
}

class _ExercisesGridViewState extends ConsumerState<ExercisesGridView> {
  @override
  Widget build(BuildContext context) {
    ref.watch(workoutsProvider);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          itemCount: widget.exercises.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
          ),
          itemBuilder: (context, index) {
            return ExerciseCard(
              exercise: widget.exercises[index],
              isComingFromWorkoutScreen:
                  ref.watch(workoutsProvider.notifier).selectMode,
            );
          }),
    );
  }

  @override
  void didChangeDependencies() {
    if (widget.isComingFromWorkoutScreen!) {
      setState(() {
        ref.read(workoutsProvider.notifier).selectMode = true;
      });
    }
    super.didChangeDependencies();
  }
}

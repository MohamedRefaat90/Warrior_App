import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/widgets/native_ad_widget.dart';
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
    final isSelectMode = widget.isComingFromWorkoutScreen == true;

    // Split exercises: first 4, then the rest
    final firstFourExercises = widget.exercises.take(4).toList();
    final remainingExercises =
        widget.exercises.length > 4 ? widget.exercises.skip(4).toList() : [];

    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: CustomScrollView(
        slivers: [
          // First grid with up to 4 exercises
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ExerciseCard(
                  exercise: firstFourExercises[index],
                  isComingFromWorkoutScreen: isSelectMode,
                );
              },
              childCount: firstFourExercises.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
          ),
          // Native ad after first 4 items (full width)
          if (widget.exercises.length > 4 && ConnectivityChecker.isOnline!)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: SizedBox(
                  height: 300,
                  child: const NativeAdWidget(),
                ),
              ),
            ),
          // Remaining exercises in grid
          if (remainingExercises.isNotEmpty)
            SliverGrid(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  return ExerciseCard(
                    exercise: remainingExercises[index],
                    isComingFromWorkoutScreen: isSelectMode,
                  );
                },
                childCount: remainingExercises.length,
              ),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
              ),
            ),
        ],
      ),
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

  @override
  void dispose() {
    // Reset select mode when leaving the exercises screen
    // This prevents the select mode from persisting when navigating back
    if (widget.isComingFromWorkoutScreen == true) {
      try {
        // Check if the provider is still available before accessing it
        if (mounted) {
          ref.read(workoutsProvider.notifier).selectMode = false;
        }
      } catch (e) {
        // Ignore errors if the widget is already disposed or ref is unavailable
        // The selectMode will be reset by the parent ExercisesScreen's PopScope
      }
    }
    super.dispose();
  }
}

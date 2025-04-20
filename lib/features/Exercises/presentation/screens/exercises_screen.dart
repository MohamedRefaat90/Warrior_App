import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/cache_manager.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/refresh_widget.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercises_gridview.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class ExercisesScreen extends ConsumerWidget {
  final Map muscle;
  final bool? isComingFromWorkoutScreen;

  const ExercisesScreen({
    super.key,
    required this.muscle,
    this.isComingFromWorkoutScreen,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
              onPressed: () {
                ref.read(workoutsProvider.notifier).selectMode = false;
                context.pop();
              },
              icon: Icon(Icons.arrow_back_ios_new)),
          title: Text(
            '${muscle['name']} Exercises',
            style: const TextStyle(
                fontFamily: "Kings", fontSize: 30, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: ConnectivityChecker.isOnline!
            ? ref.watch(muscleExerciseProvider(muscle['id'])).when(
                loading: () => const Loader(),
                data: (exercises) {
                  DataManager.preloadAndSaveData(
                      HiveManager.exercisesBox, exercises);
                  return ExercisesGridView(
                      exercises: exercises,
                      isComingFromWorkoutScreen:
                          isComingFromWorkoutScreen ?? false);
                },
                error: (error, stackTrace) =>
                    RefreshWidget(muscleExerciseProvider(muscle['id'])))
            : HiveManager.exercisesBox.isEmpty
                ? Center(
                    child: Text(
                      "No exercises available offline",
                      style: TextStyle(
                          fontFamily: "poppins",
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                  )
                : ExercisesGridView(
                    exercises: HiveManager.exercisesBox.values
                        .where((exercise) => exercise.muscleID == muscle['id'])
                        .toList(),
                    isComingFromWorkoutScreen:
                        isComingFromWorkoutScreen ?? false,
                  ));
  }
}

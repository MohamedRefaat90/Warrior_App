import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/cache_manager.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/refresh_widget.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercises_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ExercisesScreen extends ConsumerWidget {
  final Map muscle;
  const ExercisesScreen({super.key, required this.muscle});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
        appBar: AppBar(
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
                  return ExercisesGridView(exercises: exercises);
                },
                error: (error, stackTrace) =>
                    RefreshWidget(muscleExerciseProvider(muscle['id'])))
            : ExercisesGridView(
                exercises: HiveManager.exercisesBox.values
                    .where((exercise) => exercise.muscleID == muscle['id'])
                    .toList()));
  }
}

import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/cache_manager.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/loader.dart';
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
    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        // Reset select mode when navigating back using device back button
        if (didPop && (isComingFromWorkoutScreen ?? false)) {
          ref.read(workoutsProvider.notifier).selectMode = false;
        }
      },
      child: Scaffold(
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
                error: (error, stackTrace) => Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text('Something went wrong!'),
                          ElevatedButton(
                            onPressed: () => ref
                                .refresh(muscleExerciseProvider(muscle['id'])),
                            child: Text('Refresh'),
                          ),
                        ],
                      ),
                    ))
            : HiveManager.exercisesBox.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.wifi_off,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          "No exercises available offline",
                          style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 20,
                              fontWeight: FontWeight.bold),
                          textAlign: TextAlign.center,
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Please go online to download exercises",
                          style: TextStyle(
                              fontFamily: "poppins",
                              fontSize: 16,
                              color: Colors.grey[600]),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : () {
                    final filteredExercises = HiveManager.exercisesBox.values
                        .where((exercise) => exercise.muscleID == muscle['id'])
                        .toList();

                    if (filteredExercises.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.fitness_center,
                              size: 64,
                              color: Colors.grey,
                            ),
                            SizedBox(height: 16),
                            Text(
                              "No ${muscle['name']} exercises available offline",
                              style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(height: 8),
                            Text(
                              "Go online to get ${muscle['name']} exercises",
                              style: TextStyle(
                                  fontFamily: "poppins",
                                  fontSize: 16,
                                  color: Colors.grey[600]),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      );
                    }

                    return ExercisesGridView(
                      exercises: filteredExercises,
                      isComingFromWorkoutScreen:
                          isComingFromWorkoutScreen ?? false,
                    );
                  }(),
      ),
    );
  }
}

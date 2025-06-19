import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workout_gridview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class WorkoutDetails extends ConsumerWidget {
  final WorkoutSetModel workout;

  const WorkoutDetails(this.workout, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    ref.watch(workoutsProvider);
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    return PopScope(
      onPopInvokedWithResult: (result, data) {
        ref.watch(workoutsProvider.notifier).selectMode = false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              workoutNotifier.newWorkout = workout;

              context.pushNamed(AppRouters.muscles, extra: {
                "isComingFromWorkoutScreen": true,
                "appendToExistingWorkoutSet": true
              });
            },
            tooltip: "Add New Exercise",
            shape: CircleBorder(),
            child: Icon(
              Icons.add,
              color: AppColors.white,
            )),
        appBar: AppBar(
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              workoutNotifier.selectMode = false;
              Navigator.pop(context);
            },
          ),
          title: Text(
            '${workout.name} Exercises',
            style: const TextStyle(
                fontFamily: "Kings", fontSize: 30, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        bottomNavigationBar: workoutNotifier.selectMode
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CustomBTN(
                  widget: Text("Delete"),
                  color: AppColors.primaryColor,
                  press: () async {
                    if (workoutNotifier.newWorkout.workoutItems == null ||
                        workout.workoutItems == null) {
                      return;
                    }

                    Set<int> selectedExerciseIds = workoutNotifier
                        .newWorkout.workoutItems!
                        .map((e) => e.exercise.id)
                        .toSet();

                    // Both modify the local instance for immediate UI update
                    // and create the list for the API update
                    workout.workoutItems!.removeWhere((element) =>
                        selectedExerciseIds.contains(element.exercise.id));

                    // Update the workout in the backend
                    await workoutNotifier.updateWorkoutSet(WorkoutSetModel(
                      id: workout.id,
                      name: workout.name,
                      description: workout.description,
                      workoutItems: workout.workoutItems,
                    ));

                    // Clear selected items from newWorkout to reset checkbox state
                    workoutNotifier.newWorkout.workoutItems!.clear();

                    // Reset selection mode
                    workoutNotifier.toggleSelectMode();
                  },
                ),
              )
            : null,
        body: WorkoutGridView(workout),
      ),
    );
  }
}

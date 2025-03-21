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
    return PopScope(
      onPopInvokedWithResult: (result, data) {
        debugPrint('Back from exercise screen');
        ref.watch(workoutsProvider.notifier).selectMode = false;
      },
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
            backgroundColor: AppColors.primaryColor,
            onPressed: () {
              ref.read(workoutsProvider.notifier).newWorkout = workout;

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
          title: Text(
            workout.name!,
            style: TextStyle(
                fontFamily: 'poppins',
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5),
          ),
          leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              ref.read(workoutsProvider.notifier).selectMode = false;
              Navigator.pop(context);
            },
          ),
        ),
        bottomNavigationBar: ref.watch(workoutsProvider.notifier).selectMode
            ? Padding(
                padding: const EdgeInsets.all(10),
                child: CustomBTN(
                    widget: Text("Delete"),
                    color: AppColors.primaryColor,
                    press: () {
                      List afterSelect = ref
                          .read(workoutsProvider.notifier)
                          .newWorkout
                          .workoutItems!
                          .map((e) => {
                                "exercise_id": e.exercise.id,
                                "last_weight": e.lastWeight,
                                "equipment_type": e.exercise.equipmentType,
                              })
                          .toList();

                      List<WorkoutItemModel> uniqueItems = workout.workoutItems!
                          .where((originalItem) => !afterSelect.any((newItem) =>
                              originalItem.exercise.id ==
                              newItem['exercise_id']))
                          .toList();

                      ref.read(workoutsProvider.notifier).updateWorkoutSet(
                          WorkoutSetModel(
                              id: workout.id,
                              name: workout.name,
                              description: workout.description,
                              workoutItems: uniqueItems));
                    }),
              )
            : null,
        body: WorkoutGridView(workout),
      ),
    );
  }
}

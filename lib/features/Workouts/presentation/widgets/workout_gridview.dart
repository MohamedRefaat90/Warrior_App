import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workout_exercises.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/last_weight_selector.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutGridView extends ConsumerStatefulWidget {
  final WorkoutSetModel workout;

  const WorkoutGridView(this.workout, {super.key});

  @override
  ConsumerState<WorkoutGridView> createState() => _WorkoutGridViewState();
}

class _WorkoutGridViewState extends ConsumerState<WorkoutGridView> {
  @override
  Widget build(BuildContext context) {
    ref.watch(workoutsProvider);
    final workoutNotifier = ref.watch(workoutsProvider.notifier);

    // Check if workout has no exercises
    if (widget.workout.workoutItems == null ||
        widget.workout.workoutItems!.isEmpty) {
      return EmptyWorkoutExercises(workout: widget.workout);
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0.8),
      child: CustomScrollView(
        slivers: [
          SliverGrid(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                final WorkoutItemModel workoutExercise =
                    widget.workout.workoutItems![index];
                return Stack(
                  alignment: Alignment.center,
                  clipBehavior: Clip.none,
                  fit: StackFit.passthrough,
                  children: [
                    GestureDetector(
                      onLongPress: () {
                        workoutNotifier.toggleSelectMode();
                      },
                      child: ExerciseCard(
                        exercise: workoutExercise.exercise,
                        isComingFromWorkoutScreen: workoutNotifier.selectMode,
                      ),
                    ),
                    Positioned(
                        width: 95.w,
                        height: 20.h,
                        bottom: -5.h,
                        right: 33.w,
                        child: CustomBTN(
                          widget: Text.rich(
                            TextSpan(children: [
                              TextSpan(
                                  text: "Last Weight : ",
                                  style:
                                      TextStyle(fontWeight: FontWeight.w400)),
                              TextSpan(text: "${workoutExercise.lastWeight} "),
                              TextSpan(
                                  text:
                                      workoutExercise.exercise.equipmentType ==
                                              "machine"
                                          ? "Bar"
                                          : "KG",
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ]),
                            style: TextStyle(fontSize: 9.sp),
                          ),
                          radius: 4,
                          color: AppColors.green,
                          padding: 0,
                          press: () async {
                            final newWeight = await showModalBottomSheet<num>(
                                context: context,
                                isScrollControlled: true,
                                backgroundColor: Colors.transparent,
                                constraints: BoxConstraints(
                                  maxHeight:
                                      MediaQuery.of(context).size.height * 0.7,
                                ),
                                // shape: const RoundedRectangleBorder(
                                //   borderRadius: BorderRadius.only(
                                //     topLeft: Radius.circular(20),
                                //     topRight: Radius.circular(20),
                                //   ),
                                // ),
                                builder: (context) => LastWeightSelector(
                                    workoutID: widget.workout.id!,
                                    workoutExercise: workoutExercise));

                            if (newWeight != null) {
                              setState(() {
                                workoutExercise.lastWeight = newWeight;
                              });
                            }
                          },
                        ))
                  ],
                );
              },
              childCount: widget.workout.workoutItems!.length,
            ),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 10,
              mainAxisSpacing: 15,
              childAspectRatio: 0.9,
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(height: 20.h),
          ),
        ],
      ),
    );
  }
}

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workout_exercises.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/value_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
      padding: EdgeInsets.symmetric(horizontal: context.smallSpacing),
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
                        workoutItem: workoutExercise,
                        workoutSetId: widget.workout.id,
                      ),
                    ),
                    Positioned(
                        width: ResponsiveUtils.value<double>(
                          context,
                          mobile: context.screenWidth * 0.26,
                          tablet: 120,
                          desktop: 130,
                        ),
                        height: ResponsiveUtils.value<double>(
                          context,
                          mobile: context.screenHeight * 0.03,
                          tablet: 26,
                          desktop: 28,
                        ),
                        bottom: -7,

                        // Last Weight Button
                        child: CustomBTN(
                          widget: Text.rich(
                            TextSpan(children: [
                              TextSpan(text: context.l10n.lastWeight),
                              TextSpan(
                                  text: ": ${workoutExercise.lastWeight} "),
                              TextSpan(
                                  text:
                                      workoutExercise.exercise.equipmentType ==
                                              "machine"
                                          ? context.l10n.bar
                                          : context.l10n.kg),
                            ]),
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: context.screenWidth * 0.025,
                                color: AppColors.white),
                            textDirection: TextDirection.ltr,
                          ),
                          radius: 4,
                          color: AppColors.green,
                          padding: 2,
                          press: () async {
                            final newWeight = await showModalBottomSheet<num>(
                              context: context,
                              isScrollControlled: true,
                              backgroundColor: Colors.transparent,
                              builder: (context) => ValueSelectionBottomSheet(
                                mode: ValueSelectionMode.weight,
                                currentValue: workoutExercise.lastWeight,
                                title: workoutExercise.exercise.name,
                                subtitle: context.l10n.selectWeight,
                                isMachine:
                                    workoutExercise.exercise.equipmentType ==
                                        "machine",
                                primaryColor: AppColors.green,
                              ),
                            );

                            if (newWeight != null &&
                                newWeight != workoutExercise.lastWeight) {
                              // Update Provider
                              await ref
                                  .read(workoutsProvider.notifier)
                                  .updateLastWeight(
                                    widget.workout.id,
                                    workoutExercise.exercise.id,
                                    newWeight,
                                    workout: widget.workout,
                                  );

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
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getGridColumns(context),
              crossAxisSpacing: context.smallSpacing,
              mainAxisSpacing: context.mediumSpacing,
              childAspectRatio: 0.9,
            ),
          ),
          SliverToBoxAdapter(child: SizedBox(height: context.mediumSpacing)),
        ],
      ),
    );
  }
}

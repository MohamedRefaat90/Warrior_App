import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workout_exercises.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/value_selection_bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';

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
                                title:
                                    context.l10n.weightSelectionTitleGridView,
                                subtitle: context
                                    .l10n.weightSelectionSubtitleGridView,
                                isMachine:
                                    workoutExercise.exercise.equipmentType ==
                                        "machine",
                                primaryColor: AppColors.primaryColor,
                                tooltipMessage:
                                    context.l10n.weightSelectionTooltipGridView,
                              ),
                            );

                            if (newWeight != null &&
                                newWeight != workoutExercise.lastWeight) {
                              // Update Provider: Apply to ALL sets
                              final weightChange = await ref
                                  .read(workoutsProvider.notifier)
                                  .applyWeightToAllSets(
                                    widget.workout.id,
                                    workoutExercise.exercise.id,
                                    newWeight,
                                    workout: widget.workout,
                                  );

                              TalkerService.instance
                                  .warning("Weight change: $weightChange");
                              if (weightChange != null && mounted) {
                                _showFeedbackOverlay(context, weightChange);
                              }
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

  void _showFeedbackOverlay(BuildContext context, num weightChange) {
    if (weightChange == 0) return;

    final isPositive = weightChange > 0;
    final animationFile = isPositive ? AppAssets.fire : AppAssets.downArrow;
    final message = isPositive
        ? context.l10n.weightIncreased
        : context.l10n.weightDecreased;

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (context) {
        Future.delayed(const Duration(seconds: 3), () {
          if (context.mounted) Navigator.of(context).pop();
        });

        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.asset(
                animationFile,
                width: isPositive ? 300 : 200,
                height: isPositive ? 300 : 200,
                repeat: true,
              ),
              const SizedBox(height: 16),
              Material(
                color: Colors.transparent,
                child: Text(
                  message,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

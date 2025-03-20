import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:Warrior/features/Workouts/data/data_sources/workout_item_weights.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/weight_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutGridView extends ConsumerStatefulWidget {
  final List<WorkoutItemModel> workoutItems;
  // final bool? isComingFromWorkoutScreen;
  // final String? workoutName;

  const WorkoutGridView({
    super.key,
    required this.workoutItems,
  });

  @override
  ConsumerState<WorkoutGridView> createState() => _ExercisesGridViewState();
}

class _ExercisesGridViewState extends ConsumerState<WorkoutGridView> {
  @override
  Widget build(BuildContext context) {
    ref.watch(workoutsProvider);
    final workoutNotifier = ref.watch(workoutsProvider.notifier);
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GridView.builder(
          itemCount: widget.workoutItems.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final WorkoutItemModel workoutExercise = widget.workoutItems[index];
            return Stack(
              alignment: Alignment.center,
              fit: StackFit.passthrough,
              children: [
                InkWell(
                  onLongPress: () {
                    // if (widget.isComingFromWorkoutScreen!) {
                    workoutNotifier.toggleSelectMode();
                    // }
                  },
                  child: ExerciseCard(
                    exercise: workoutExercise.exercise,
                    isComingFromWorkoutScreen: workoutNotifier.selectMode,
                  ),
                ),
                // if (widget.isComingFromWorkoutScreen! &&
                //     widget.workoutName != null)
                Positioned(
                    width: 75.w,
                    height: 15.h,
                    top: 10.h,
                    right: 5.w,
                    child: CustomBTN(
                      widget: Text.rich(
                        TextSpan(children: [
                          TextSpan(text: "Last Weight : "),
                          TextSpan(text: "0 "),
                          TextSpan(
                              text: workoutExercise.equipmentType == "machine"
                                  ? "Bar"
                                  : "KG"),
                        ]),
                        style: TextStyle(fontSize: 8.sp),
                      ),
                      radius: 4,
                      color: AppColors.green,
                      padding: 0,
                      press: () {
                        showModalBottomSheet(
                            context: context,
                            builder: (context) => Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Expanded(
                                      child: ListView(
                                        scrollDirection: Axis.vertical,
                                        shrinkWrap: true,
                                        children:
                                            workoutExercise.equipmentType ==
                                                    "machine"
                                                ? MachineWeights.values
                                                    .map((e) => WeightChip(
                                                          weight: e.weight,
                                                          type: e,
                                                          lastWeight:
                                                              workoutExercise
                                                                  .lastWeight,
                                                        ))
                                                    .toList()
                                                : FreeWeights.values
                                                    .map((e) => WeightChip(
                                                          weight: e.weight,
                                                          type: e,
                                                          lastWeight:
                                                              workoutExercise
                                                                  .lastWeight,
                                                        ))
                                                    .toList(),
                                      ),
                                    ),
                                    CustomBTN(
                                        widget: Text("Update"),
                                        padding: 10,
                                        width: 150.w,
                                        radius: 8,
                                        color: Colors.deepPurpleAccent,
                                        press: () {})
                                  ],
                                ));
                      },
                    ))
              ],
            );
          }),
    );
  }
}

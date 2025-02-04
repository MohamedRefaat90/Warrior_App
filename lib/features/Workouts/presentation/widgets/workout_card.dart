import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/core/widgets/custom_text_field.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class WorkoutCard extends ConsumerStatefulWidget {
  final WorkoutSetModel workout;
  TextEditingController nameController;
  TextEditingController descriptionController;
  WorkoutCard(
      {super.key,
      required this.workout,
      required this.nameController,
      required this.descriptionController});

  @override
  ConsumerState<WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends ConsumerState<WorkoutCard> {
  @override
  void initState() {
    widget.nameController = TextEditingController(text: widget.workout.name);
    widget.descriptionController =
        TextEditingController(text: widget.workout.description);
    super.initState();
  }

  // @override
  // void dispose() {
  //   nameController.dispose();
  //   descriptionController.dispose();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        context.pushNamed(AppRouters.workoutDetails, extra: widget.workout);
      },
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(
                  widget.workout.name!,
                  style: TextStyle(
                    fontSize: 17.sp,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'poppins',
                  ),
                ),
                Text(
                  widget.workout.description!,
                  maxLines: 2,
                ),
                Row(
                  children: [
                    Text(
                      "${widget.workout.workoutItems!.length} ",
                      style: TextStyle(
                          fontSize: 15.sp, fontWeight: FontWeight.bold),
                    ),
                    Icon(Icons.fitness_center, size: 15.sp),
                  ],
                ),
              ]),
              Column(
                children: [
                  CustomBTN(
                    widget: Icon(Icons.edit, size: 15.sp),
                    color: Colors.green,
                    radius: 0,
                    padding: 15,
                    splashColor: AppColors.white,
                    press: () {
                      showAdaptiveDialog(
                          context: context,
                          builder: (context) {
                            return AlertDialog(
                              title: Text('Edit Workout Set'),
                              content: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  CustomTextField(
                                      textEditingController:
                                          widget.nameController),
                                  SizedBox(height: 10.h),
                                  CustomTextField(
                                      textEditingController:
                                          widget.descriptionController,
                                      isTextArea: true,
                                      placeholderText: 'Description'),
                                ],
                              ),
                              actions: [
                                TextButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    child: Text('Cancel')),
                                Consumer(
                                  builder: (context, ref, child) => TextButton(
                                      onPressed: () async {
                                        await ref
                                            .read(workoutsProvider.notifier)
                                            .updateWorkoutSet(widget.workout
                                                .copyWith(
                                                    name: widget
                                                        .nameController.text,
                                                    description: widget
                                                        .descriptionController
                                                        .text));
                                        Navigator.of(context).pop();
                                      },
                                      child: Text('Edit')),
                                ),
                              ],
                            );
                          });
                    },
                  ),
                  CustomBTN(
                    widget: Icon(Icons.delete, size: 15.sp),
                    color: Colors.red,
                    radius: 0,
                    padding: 15,
                    splashColor: AppColors.white,
                    press: () {
                      ref
                          .read(workoutsProvider.notifier)
                          .deleteWorkoutSet(widget.workout.id!);
                      ref
                          .read(workoutsProvider.notifier)
                          .workoutList
                          .removeWhere(
                              (element) => element.id == widget.workout.id);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

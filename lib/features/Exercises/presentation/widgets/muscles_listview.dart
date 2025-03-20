import 'dart:developer';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class MusclesListView extends ConsumerWidget {
  final List<MuscleModel> muscles;
  final bool? isComingFromWorkoutScreen;
  final bool? appendToExistingWorkoutSet;
  const MusclesListView(
      {super.key,
      required this.muscles,
      this.isComingFromWorkoutScreen,
      this.appendToExistingWorkoutSet});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    final workoutProviderState = ref.watch(workoutsProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: SingleChildScrollView(
        child: Column(
          children: [
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => MuscleTile(
                      muscle: muscles[index],
                      isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                    ),
                separatorBuilder: (context, index) => 5.verticalSpace,
                itemCount: muscles.length),
            10.verticalSpace,
            if (isComingFromWorkoutScreen == true &&
                (workoutNotifier.newWorkout.workoutItems == null ||
                    workoutNotifier.newWorkout.workoutItems!.isEmpty))
              Text(
                "you must add at least one exercise".capitalizeWord(),
                style: TextStyle(
                    color: Colors.red,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w800),
              ),
            5.verticalSpace,
            if (isComingFromWorkoutScreen ?? false)
              CustomBTN(
                  widget: workoutProviderState.isLoading
                      ? SizedBox(
                          width: 20.w,
                          height: 20.w,
                          child: CircularProgressIndicator(
                            color: AppColors.primaryColor,
                          ))
                      : Text.rich(TextSpan(children: [
                          TextSpan(
                              text: appendToExistingWorkoutSet!
                                  ? "Update "
                                  : "Finish "),
                          TextSpan(text: "Your Workout Set"),
                        ])),
                  padding: 15,
                  width: 200.w,
                  color: AppColors.black,
                  isDisabled:
                      (workoutNotifier.newWorkout.workoutItems == null ||
                          workoutNotifier.newWorkout.workoutItems!.isEmpty),
                  press: () async {
                    if (!appendToExistingWorkoutSet!) {
                      await workoutNotifier.createWorkoutSet();
                    } else {
                      await workoutNotifier
                          .updateWorkoutSet(workoutNotifier.newWorkout);
                      log("Update Existing Set");
                    }
                    if (workoutProviderState.isSuccess) {
                      if (context.mounted) {
                        context.pop(); // Pop muscles screen
                        context.pop(); // Return to workouts screen
                      }
                    }
                  }),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}

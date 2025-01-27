import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusclesListView extends ConsumerWidget {
  final List<MuscleModel> muscles;
  final bool? isComingFromWorkoutScreen;
  const MusclesListView({
    super.key,
    required this.muscles,
    this.isComingFromWorkoutScreen,
  });
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  MuscleTile(muscle: muscles[index]),
              separatorBuilder: (context, index) => 10.verticalSpace,
              itemCount: muscles.length),
          Spacer(),
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
          10.verticalSpace,
          if (isComingFromWorkoutScreen ?? false)
            CustomBTN(
                widget: Text("Finish Your Workout Set".capitalizeWord()),
                padding: 15,
                width: 200.w,
                color: AppColors.black,
                isDisabled: (workoutNotifier.newWorkout.workoutItems == null ||
                    workoutNotifier.newWorkout.workoutItems!.isEmpty),
                press: () {
                  workoutNotifier.createWorkoutSet();
                }),
          20.verticalSpace,
        ],
      ),
    );
  }
}

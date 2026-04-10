import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/FinishBTN.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

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
    return Padding(
        padding: EdgeInsets.symmetric(horizontal: context.smallSpacing),
        child: Column(
          children: [
            ListView.separated(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemBuilder: (context, index) => MuscleTile(
                      muscle: muscles[index],
                      isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                      appendToExistingWorkoutSet: appendToExistingWorkoutSet,
                    ),
                separatorBuilder: (context, index) =>
                    SizedBox(height: context.smallSpacing / 2),
                itemCount: muscles.length),
            SizedBox(height: context.smallSpacing),
            if (isComingFromWorkoutScreen == true &&
                (workoutNotifier.newWorkout.workoutItems == null ||
                    workoutNotifier.newWorkout.workoutItems!.isEmpty))
              Text(
                "you must add at least one exercise".capitalizeWord(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.red,
                      fontWeight: FontWeight.w800,
                    ),
              ),
            SizedBox(height: context.smallSpacing),
            if (isComingFromWorkoutScreen ?? false)
              FinishBTN(
                  primaryColor: AppColors.primaryColor,
                  appendToExistingWorkoutSet: appendToExistingWorkoutSet),
            SizedBox(height: context.smallSpacing),
          ],
        ));
  }
}

import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/image_error.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_widget.dart';

class ExerciseCard extends ConsumerStatefulWidget {
  final ExerciseModel exercise;
  final bool? isComingFromWorkoutScreen;
  const ExerciseCard(
      {super.key, required this.exercise, this.isComingFromWorkoutScreen});

  @override
  ConsumerState<ExerciseCard> createState() => _ExerciseCardState();
}

class _ExerciseCardState extends ConsumerState<ExerciseCard> {
  bool isSelected = false;
  @override
  void initState() {
    super.initState();
    final workoutsNotifier = ref.read(workoutsProvider.notifier);
    // Check if exercise is already in workout list
    isSelected = workoutsNotifier.newWorkout.workoutItems!
        .any((item) => item.exercise.id == widget.exercise.id);
  }

  @override
  Widget build(BuildContext context) {
    final workoutsNotifier = ref.read(workoutsProvider.notifier);
    return InkWell(
      onTap: () =>
          context.pushNamed(AppRouters.exerciseDetails, extra: widget.exercise),
      child: Card(
          elevation: 3,
          child: Stack(
            alignment: Alignment.center,
            children: [
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  CachedNetworkImage(
                    imageUrl: widget.exercise.image,
                    height: 120.h,
                    placeholder: (context, url) => CustomLoadingWidget(),
                    errorWidget: (context, url, error) => ImageError(),
                  ),
                  SizedBox(
                    width: 100.w,
                    child: Text(
                      widget.exercise.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                    ),
                  ),
                ],
              ),
              if (widget.isComingFromWorkoutScreen! &&
                  ref.watch(workoutsProvider.notifier).selectMode)
                Positioned(
                  top: 0,
                  left: 0,
                  child: Checkbox.adaptive(
                    value: isSelected,
                    onChanged: (value) {
                      setState(() {
                        isSelected = value!;
                      });

                      isSelected
                          ? workoutsNotifier.newWorkout.workoutItems!
                              .add(WorkoutItemModel(
                              exercise: widget.exercise,
                              lastWeight: 0,
                              equipmentType: widget.exercise.equipmentType!,
                            ))
                          : workoutsNotifier.newWorkout.workoutItems!
                              .removeWhere(
                                  (e) => e.exercise.id == widget.exercise.id);
                    },
                  ),
                ),
            ],
          )),
    );
  }
}

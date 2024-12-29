import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

class ExerciseCard extends StatelessWidget {
  const ExerciseCard({super.key, required this.exercise});

  final ExerciseModel exercise;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () =>
          context.pushNamed(AppRouters.exerciseDetails, extra: exercise),
      child: Card(
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CachedNetworkImage(
                imageUrl: exercise.image,
                height: 120.h,
              ),
              Text(exercise.name),
            ],
          )),
    );
  }
}

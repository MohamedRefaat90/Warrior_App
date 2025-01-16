import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/image_error.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/loading_widget.dart';

class ExerciseCard extends StatelessWidget {
  final ExerciseModel exercise;

  const ExerciseCard({super.key, required this.exercise});

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
                placeholder: (context, url) => CustomLoadingWidget(),
                errorWidget: (context, url, error) => ImageError(),
              ),
              SizedBox(
                width: 100.w,
                child: Text(
                  exercise.name,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.clip,
                ),
              ),
            ],
          )),
    );
  }
}

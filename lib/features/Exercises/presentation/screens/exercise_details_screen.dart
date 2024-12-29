import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseDetailsScreen extends StatelessWidget {
  final ExerciseModel exercise;
  const ExerciseDetailsScreen({super.key, required this.exercise});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          exercise.name,
          style: const TextStyle(fontFamily: "Poppins"),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            CachedNetworkImage(
              imageUrl: exercise.image,
              width: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            10.verticalSpace,
            CachedNetworkImage(
              imageUrl: exercise.targetedMuscles,
              width: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            10.verticalSpace,
            CachedNetworkImage(
              imageUrl: exercise.gif,
              width: double.infinity,
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }
}

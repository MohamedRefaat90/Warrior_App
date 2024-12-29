import 'package:Warrior/core/widgets/error_widget.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/exercise_card.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class ExerciseScreen extends ConsumerWidget {
  final Map muscle;
  const ExerciseScreen({super.key, required this.muscle});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${muscle['name']} Exercises',
          style: const TextStyle(
              fontFamily: "Kings", fontSize: 30, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: ref.watch(muscleExerciseProvider(muscle['id'])).when(
          loading: () => const Loader(),
          data: (exercises) => Padding(
                padding: const EdgeInsets.all(8.0),
                child: GridView.builder(
                    itemCount: exercises.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemBuilder: (context, index) {
                      final ExerciseModel exercise = exercises[index];
                      return ExerciseCard(exercise: exercise);
                    }),
              ),
          error: (error, stackTrace) =>
              CustomErrorWidget(errorMsg: error.toString())),
    );
  }
}

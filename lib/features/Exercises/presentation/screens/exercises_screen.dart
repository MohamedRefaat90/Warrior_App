import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/network/api_error_handler.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';

class ExercisesScreen extends ConsumerStatefulWidget {
  const ExercisesScreen({super.key});

  @override
  ConsumerState<ExercisesScreen> createState() => _ExercisesScreenState();
}

class _ExercisesScreenState extends ConsumerState<ExercisesScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(muscleProvider);
    return Scaffold(
        appBar: AppBar(
          title: const Text('Exercises',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Kings",
                  fontSize: 30)),
          centerTitle: true,
        ),
        body: ref.watch(muscleProvider).when(
            loading: () => Center(
                  child: Lottie.asset(AppAssets.loader, width: 150.w),
                ),
            data: (muscles) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) =>
                          MuscleTile(muscle: muscles[index]),
                      separatorBuilder: (context, index) => 10.verticalSpace,
                      itemCount: 5),
                ),
            error: (error, stackTrace) => Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Card(
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(10),
                        child: Text(error.toString()),
                      ),
                    ),
                  ),
                )));
  }
}

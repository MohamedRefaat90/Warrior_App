import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    final workoutNotifier = ref.read(workoutsProvider.notifier);
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Your Workouts',
            style: TextStyle(
                fontFamily: 'kings',
                fontWeight: FontWeight.bold,
                fontSize: 28.sp)),
      ),
      body: ref.watch(workoutsProvider).isLoading
          ? Loader()
          : !workoutNotifier.workoutList.isEmpty
              ? EmptyWorkoutList()
              : WorkoutsListview(workoutNotifier.workoutList),
    );
  }
}

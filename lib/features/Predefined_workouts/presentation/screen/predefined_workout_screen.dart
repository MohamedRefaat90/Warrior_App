import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/provider/predefined_provider.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_groups_view.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class PredefinedWorkoutsScreen extends ConsumerStatefulWidget {
  const PredefinedWorkoutsScreen({super.key});

  @override
  ConsumerState<PredefinedWorkoutsScreen> createState() =>
      _PredefinedWorkoutScreenState();
}

class _PredefinedWorkoutScreenState
    extends ConsumerState<PredefinedWorkoutsScreen> {
  @override
  Widget build(BuildContext context) {
    // Watch the grouped workouts provider instead of flat list
    final groupedWorkoutsState = ref.watch(groupedWorkoutsProvider);

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        centerTitle: true,
        title: Text(
          'Your Workouts',
          style: TextStyle(
            fontFamily: 'kings',
            fontWeight: FontWeight.bold,
            fontSize: 28.sp,
          ),
        ),
        // View mode toggle removed since we're using grouped view
        // actions: [
        //   IconButton(
        //     onPressed: () {
        //       ref.read(viewModeProvider.notifier).toggle();
        //     },
        //     icon: Icon(
        //       viewMode == WorkoutViewMode.list
        //           ? Icons.grid_view
        //           : Icons.view_list,
        //     ),
        //     tooltip: viewMode == WorkoutViewMode.list
        //         ? 'Switch to Grid View'
        //         : 'Switch to List View',
        //   ),
        // ],
      ),
      body: groupedWorkoutsState.when(
        data: (workoutGroups) {
          // Use the new grouped view with domain entities
          return WorkoutGroupsView(workoutGroups: workoutGroups);
        },
        loading: () => const Loader(),
        error: (error, stackTrace) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text('something went wrong'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  // Refresh the grouped workouts provider
                  ref.invalidate(groupedWorkoutsProvider);
                },
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/provider/predefined_provider.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_workouts_gridview.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/Predefined_workouts_listview.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/empty_Predefined_workoutlist.dart';
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
    final predefinedState = ref.watch(predefinedProvider);
    final viewMode = ref.watch(viewModeProvider);

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
        actions: [
          IconButton(
            onPressed: () {
              // Toggle between list and grid view using Riverpod v3 Notifier
              ref.read(viewModeProvider.notifier).toggle();
            },
            icon: Icon(
              viewMode == WorkoutViewMode.list
                  ? Icons.grid_view
                  : Icons.view_list,
            ),
            tooltip: viewMode == WorkoutViewMode.list
                ? 'Switch to Grid View'
                : 'Switch to List View',
          ),
        ],
      ),
      body: predefinedState.when(
        data: (workouts) {
          // Switch between list and grid based on view mode
          return viewMode == WorkoutViewMode.list
              ? PredefinedWorkoutsListView(workouts)
              : PredefinedWorkoutsGridView(workouts);
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
                  // Refresh the provider
                  ref.invalidate(predefinedProvider);
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

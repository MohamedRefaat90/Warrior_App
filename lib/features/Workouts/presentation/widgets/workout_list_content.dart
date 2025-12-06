import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/workouts_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the workout list with loading and empty states.
class WorkoutListContent extends ConsumerWidget {
  final TextEditingController nameController;

  final TextEditingController descriptionController;
  const WorkoutListContent({
    required this.nameController,
    required this.descriptionController,
    super.key,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final workoutState = ref.watch(workoutsProvider);
    final workoutNotifier = ref.watch(workoutsProvider.notifier);

    if (workoutState.isLoading) {
      return const SliverFillRemaining(
        child: Loader(),
      );
    }

    if (workoutNotifier.workoutList.isEmpty) {
      return const SliverFillRemaining(
        child: EmptyWorkoutList(),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return _AnimatedWorkoutListItem(
              index: index,
              workoutList: workoutNotifier.workoutList,
              nameController: nameController,
              descriptionController: descriptionController,
            );
          },
          childCount: 1,
        ),
      ),
    );
  }
}

class _AnimatedWorkoutListItem extends StatelessWidget {
  final int index;

  final List<WorkoutSetModel> workoutList;
  final TextEditingController nameController;
  final TextEditingController descriptionController;
  const _AnimatedWorkoutListItem({
    required this.index,
    required this.workoutList,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(
            opacity: value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: WorkoutsListView(
          workoutList,
          nameController,
          descriptionController,
        ),
      ),
    );
  }
}

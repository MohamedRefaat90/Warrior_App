import 'dart:ui';

import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/empty_workoutlist.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/enhanced_workout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays the workout list with loading, empty, and content states.
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
      return const SliverFillRemaining(child: Loader());
    }

    if (workoutNotifier.workoutList.isEmpty) {
      return const SliverFillRemaining(child: EmptyWorkoutList());
    }

    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return TweenAnimationBuilder<double>(
              duration: const Duration(milliseconds: 300),
              tween: Tween(begin: 0.0, end: 1.0),
              curve: Curves.easeOutCubic,
              builder: (context, value, child) {
                return Transform.translate(
                  offset: Offset(0, 20 * (1 - value)),
                  child: Opacity(opacity: value, child: child),
                );
              },
              child: Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _WorkoutsReorderableList(
                  workouts: workoutNotifier.workoutList,
                  nameController: nameController,
                  descriptionController: descriptionController,
                ),
              ),
            );
          },
          childCount: 1,
        ),
      ),
    );
  }
}

/// Background shown when swiping to delete a workout.
class _DismissBackground extends ConsumerWidget {
  const _DismissBackground();
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(appSettingsProvider).locale;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: language.languageCode == 'ar'
          ? Alignment.centerLeft
          : Alignment.centerRight,
      padding: language.languageCode == 'ar'
          ? const EdgeInsets.only(left: 20)
          : const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: language.languageCode == 'ar'
              ? Alignment.centerRight
              : Alignment.centerLeft,
          end: language.languageCode == 'ar'
              ? Alignment.centerLeft
              : Alignment.centerRight,
          colors: [Colors.transparent, Colors.red],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.delete_rounded, color: Colors.white, size: 32),
          const SizedBox(height: 4),
          Text(
            'delete'.tr(context),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

/// Reorderable list of workouts with drag-and-drop and swipe-to-delete.
class _WorkoutsReorderableList extends ConsumerStatefulWidget {
  final List<WorkoutSetModel> workouts;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const _WorkoutsReorderableList({
    required this.workouts,
    required this.nameController,
    required this.descriptionController,
  });

  @override
  ConsumerState<_WorkoutsReorderableList> createState() =>
      _WorkoutsReorderableListState();
}

class _WorkoutsReorderableListState
    extends ConsumerState<_WorkoutsReorderableList> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.workouts.length,
      buildDefaultDragHandles: false,
      proxyDecorator: _buildProxyDecorator,
      itemBuilder: (context, index) => _buildWorkoutItem(index),
      onReorder: _handleReorder,
    );
  }

  @override
  void initState() {
    super.initState();
    if (HiveManager.workoutsBox.isEmpty) {
      HiveManager.saveToHive(HiveManager.workoutsBox, widget.workouts);
    }
  }

  Widget _buildProxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final animValue = Curves.easeInOut.transform(animation.value);
        final elevation = lerpDouble(0, 12, animValue)!;
        final scale = lerpDouble(1.0, 1.05, animValue)!;
        final rotation = lerpDouble(0, 0.02, animValue)!;

        return Transform.scale(
          scale: scale,
          child: Transform.rotate(
            angle: rotation,
            child: Material(
              elevation: elevation,
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(16),
              shadowColor: Colors.black.withOpacity(0.3),
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildWorkoutItem(int index) {
    final workout = widget.workouts[index];

    return Dismissible(
      key: Key('${workout.id}_$index'),
      direction: DismissDirection.endToStart,
      background: _DismissBackground(),
      confirmDismiss: (_) => _confirmDelete(index),
      child: Stack(
        children: [
          EnhancedWorkoutCard(
            key: ValueKey(workout.id),
            workout: workout,
            index: index,
          ),
          Center(
            child: ReorderableDragStartListener(
              index: index,
              child: Icon(
                Icons.drag_handle,
                color: Colors.grey[600],
                size: 25,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<bool?> _confirmDelete(int index) async {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('deleteWorkout'.tr(context))),
          ],
        ),
        content: Text(context.l10n.deleteWorkoutMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(workoutsProvider.notifier)
                  .deleteWorkoutSet(widget.workouts[index].id,
                      workout: widget.workouts[index]);
              Navigator.of(context).pop(true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: Text('delete'.tr(context)),
          ),
        ],
      ),
    );
  }

  Future<void> _handleReorder(int oldIndex, int newIndex) async {
    setState(() {
      if (oldIndex < newIndex) newIndex -= 1;
      final item = widget.workouts.removeAt(oldIndex);
      widget.workouts.insert(newIndex, item);
    });

    await ref
        .read(workoutsProvider.notifier)
        .reorderWorkoutsList(widget.workouts);
    await HiveManager.saveToHive(HiveManager.workoutsBox, widget.workouts);
  }
}

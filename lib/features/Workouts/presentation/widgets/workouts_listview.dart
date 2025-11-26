import 'dart:developer';
import 'dart:ui';

import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/enhanced_workout_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutsListView extends ConsumerStatefulWidget {
  final List<WorkoutSetModel> workouts;
  final TextEditingController nameController;
  final TextEditingController descriptionController;

  const WorkoutsListView(
      this.workouts, this.nameController, this.descriptionController,
      {super.key});

  @override
  ConsumerState<WorkoutsListView> createState() => _WorkoutsListViewState();
}

class _WorkoutsListViewState extends ConsumerState<WorkoutsListView> {
  @override
  Widget build(BuildContext context) {
    return ReorderableListView.builder(
      padding: EdgeInsets.zero,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: widget.workouts.length,
      buildDefaultDragHandles: false,
      proxyDecorator: _buildProxyDecorator,
      itemBuilder: (context, index) {
        return _buildWorkoutItem(index);
      },
      onReorder: _handleReorder,
    );
  }

  @override
  void initState() {
    super.initState();
    // Save to Hive if empty
    if (HiveManager.workoutsBox.isEmpty) {
      log("Save New Data To Hive");
      HiveManager.saveToHive(HiveManager.workoutsBox, widget.workouts);
    }
  }

  Widget _buildDismissBackground() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [
            Colors.transparent,
            Colors.red,
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_rounded,
            color: Colors.white,
            size: 32,
          ),
          const SizedBox(height: 4),
          Text(
            'delete'.tr(context),
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProxyDecorator(
    Widget child,
    int index,
    Animation<double> animation,
  ) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        final double animValue = Curves.easeInOut.transform(animation.value);
        final double elevation = lerpDouble(0, 12, animValue)!;
        final double scale = lerpDouble(1.0, 1.05, animValue)!;
        final double rotation = lerpDouble(0, 0.02, animValue)!;

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
    return Dismissible(
      key: Key('${widget.workouts[index].id}_$index'),
      direction: DismissDirection.endToStart,
      background: _buildDismissBackground(),
      confirmDismiss: (direction) => _confirmDelete(index),
      child: Stack(
        children: [
          EnhancedWorkoutCard(
            key: ValueKey(widget.workouts[index].id),
            workout: widget.workouts[index],
            index: index,
          ),
          // Drag handle - positioned at top left corner
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
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.warning_rounded,
                color: Colors.red,
                size: 24,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(child: Text('deleteWorkout'.tr(context))),
          ],
        ),
        content: const Text(
          'Are you sure you want to delete this workout set? This action cannot be undone.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('cancel'.tr(context)),
          ),
          ElevatedButton(
            onPressed: () {
              ref
                  .read(workoutsProvider.notifier)
                  .deleteWorkoutSet(widget.workouts[index].id!, index);
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
      if (oldIndex < newIndex) {
        newIndex -= 1;
      }
      final WorkoutSetModel item = widget.workouts.removeAt(oldIndex);
      widget.workouts.insert(newIndex, item);
    });

    await ref
        .read(workoutsProvider.notifier)
        .reorderWorkoutsList(widget.workouts);

    await HiveManager.saveToHive(HiveManager.workoutsBox, widget.workouts);
  }
}

import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/widgets/native_ad_widget.dart';
import 'package:Warrior/features/Predefined_workouts/domain/entities/workout_group.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_group_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Widget that displays workout groups with expansion tiles
class WorkoutGroupsView extends ConsumerStatefulWidget {
  final List<WorkoutGroup> workoutGroups;

  const WorkoutGroupsView({
    super.key,
    required this.workoutGroups,
  });

  @override
  ConsumerState<WorkoutGroupsView> createState() => _WorkoutGroupsViewState();
}

class _WorkoutGroupsViewState extends ConsumerState<WorkoutGroupsView> {
  // Track which expansion tiles are expanded
  late List<bool> _expandedStates;

  @override
  Widget build(BuildContext context) {
    if (widget.workoutGroups.isEmpty) {
      return Center(
        child: Text(
          'No workout groups available',
          style: TextStyle(fontSize: 16.sp),
        ),
      );
    }

    return ListView.separated(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
      itemCount: widget.workoutGroups.length,
      separatorBuilder: (context, index) {
        // Show native ad after the first group
        if (index == 0 && ConnectivityChecker.isOnline!) {
          return Column(
            children: [
              SizedBox(height: 16.h),
              const NativeAdWidget(),
              SizedBox(height: 16.h),
            ],
          );
        }
        return SizedBox(height: 16.h);
      },
      itemBuilder: (context, index) {
        final group = widget.workoutGroups[index];

        return WorkoutGroupTile(
          title: group.groupName,
          subtitle: '${group.workoutCount} workouts',
          icon: _getIconForGroup(index),
          iconColor: _getColorForGroup(index),
          workouts: group.workouts,
          onExpansionChanged: (expanded) {
            setState(() {
              _expandedStates[index] = expanded;
            });
          },
        );
      },
    );
  }

  @override
  void didUpdateWidget(WorkoutGroupsView oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update expansion states if the number of groups changed
    if (oldWidget.workoutGroups.length != widget.workoutGroups.length) {
      _expandedStates =
          List.generate(widget.workoutGroups.length, (index) => index == 0);
    }
  }

  @override
  void initState() {
    super.initState();
    // Initialize expansion states - first group expanded by default
    _expandedStates =
        List.generate(widget.workoutGroups.length, (index) => index == 0);
  }

  /// Get color for group based on index
  Color _getColorForGroup(int index) {
    final colors = [
      Colors.green,
      Colors.blue,
      Colors.purple,
      Colors.orange,
      Colors.red,
      const Color.fromARGB(255, 22, 218, 224),
    ];
    return colors[index % colors.length];
  }

  /// Get icon for group based on index
  IconData _getIconForGroup(int index) {
    // Use same fitness icon for all groups
    return Icons.fitness_center_rounded;
  }
}

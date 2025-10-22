import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_row.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// A reusable workout group tile widget with expansion functionality
class WorkoutGroupTile extends StatefulWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Color iconColor;
  final List<WorkoutSetModel> workouts;
  final Function(bool) onExpansionChanged;

  const WorkoutGroupTile({
    super.key,
    required this.title,
    this.subtitle,
    required this.icon,
    required this.iconColor,
    required this.workouts,
    required this.onExpansionChanged,
  });

  @override
  State<WorkoutGroupTile> createState() => _WorkoutGroupTileState();
}

class _WorkoutGroupTileState extends State<WorkoutGroupTile> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      // Change card color based on expansion state
      color: _isExpanded
          ? Colors.white
          : null, // Default card color when collapsed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.r),
        side: _isExpanded
            ? BorderSide(color: widget.iconColor, width: 1.w)
            : BorderSide.none,
      ),
      child: ExpansionTile(
        initiallyExpanded: false,
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
          widget.onExpansionChanged(expanded);
        },
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: widget.iconColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8.r),
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: 24.sp,
          ),
        ),
        title: Text(
          widget.title,
          style: TextStyle(
            fontSize: 18.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        children: [
          Padding(
            padding: EdgeInsets.all(12.w),
            child: WorkoutRow(workouts: widget.workouts),
          ),
        ],
      ),
    );
  }
}

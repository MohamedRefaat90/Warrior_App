import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Predefined_workouts/presentation/widgets/workout_grid.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Card(
      elevation: 2,
      // Change card color based on expansion state
      color: _isExpanded
          ? Colors.white
          : null, // Default card color when collapsed
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        side: _isExpanded
            ? BorderSide(color: widget.iconColor, width: 1)
            : BorderSide.none,
      ),

      child: ExpansionTile(
        initiallyExpanded: false,
        tilePadding: EdgeInsets.symmetric(
          horizontal: context.smallSpacing,
          vertical: context.smallSpacing / 2,
        ),
        onExpansionChanged: (expanded) {
          setState(() {
            _isExpanded = expanded;
          });
          widget.onExpansionChanged(expanded);
        },
        shape: const Border(),
        collapsedShape: const Border(),
        leading: Container(
          padding: EdgeInsets.all(context.smallSpacing),
          decoration: BoxDecoration(
            color: widget.iconColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(context.smallSpacing),
          ),
          child: Icon(
            widget.icon,
            color: widget.iconColor,
            size: ResponsiveUtils.iconSize(context),
          ),
        ),
        title: Text(
          widget.title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color:
                    isDark && _isExpanded ? AppColors.black : AppColors.white,
              ),
        ),
        children: [
          Padding(
            padding: context.cardPadding,
            child: WorkoutGrid(workouts: widget.workouts),
          ),
        ],
      ),
    );
  }
}

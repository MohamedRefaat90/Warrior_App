import 'dart:developer';

import 'package:Warrior/features/Predefined_workouts/domain/entities/workout_group.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';

/// Use case for grouping workouts by their group field
class GroupWorkoutsUseCase {
  /// Groups a list of workouts by their group field
  ///
  /// Returns a list of [WorkoutGroup] where each group contains
  /// all workouts with the same group name.
  ///
  /// If a workout has no group (null or empty), it will be placed
  /// in a default group called "Other Workouts"
  List<WorkoutGroup> call(List<WorkoutSetModel> workouts) {
    if (workouts.isEmpty) {
      return [];
    }

    // Group workouts by their group field
    final Map<String, List<WorkoutSetModel>> groupedMap = {};

    for (final workout in workouts) {
      // Use group name or default to "Other Workouts"
      final groupName = workout.group?.trim().isEmpty ?? true
          ? 'Other Workouts'
          : workout.group!.trim();

      if (!groupedMap.containsKey(groupName)) {
        groupedMap[groupName] = [];
      }

      groupedMap[groupName]!.add(workout);
    }

    // Debug: Log grouped data
    log('Grouped Map: ${groupedMap.keys.toList()}');

    // Convert map to list of WorkoutGroup entities
    final List<WorkoutGroup> groupedList = groupedMap.entries
        .map(
          (entry) => WorkoutGroup(
            groupName: entry.key,
            workouts: entry.value,
          ),
        )
        .toList();

    // // Sort groups alphabetically, but keep "Other Workouts" at the end
    // groupedList.sort((a, b) {
    //   if (a.groupName == 'Other Workouts') return 1;
    //   if (b.groupName == 'Other Workouts') return -1;
    //   return a.groupName.compareTo(b.groupName);
    // });

    return groupedList;
  }
}

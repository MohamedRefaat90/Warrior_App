import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';

/// Domain entity representing a group of workouts
class WorkoutGroup {
  final String groupName;
  final List<WorkoutSetModel> workouts;

  const WorkoutGroup({
    required this.groupName,
    required this.workouts,
  });

  @override
  int get hashCode => groupName.hashCode ^ workouts.hashCode;

  /// Check if the group is empty
  bool get isEmpty => workouts.isEmpty;

  /// Check if the group is not empty
  bool get isNotEmpty => workouts.isNotEmpty;

  /// Get the number of workouts in this group
  int get workoutCount => workouts.length;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is WorkoutGroup &&
        other.groupName == groupName &&
        other.workouts == workouts;
  }

  @override
  String toString() =>
      'WorkoutGroup(groupName: $groupName, workoutCount: $workoutCount)';
}

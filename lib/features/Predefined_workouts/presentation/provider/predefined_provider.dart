import 'package:Warrior/features/Predefined_workouts/data/repo/predefined_repo.dart';
import 'package:Warrior/features/Predefined_workouts/domain/entities/workout_group.dart';
import 'package:Warrior/features/Predefined_workouts/domain/use_cases/group_workouts_use_case.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to represent view modes
// enum WorkoutViewMode { list, grid }

/// Provider for grouped workouts
///
/// Fetches predefined workouts and transforms them into grouped format
/// using the domain use case
final groupedWorkoutsProvider = FutureProvider<List<WorkoutGroup>>((ref) async {
  // Fetch workouts from repository
  final repo = ref.watch(predefinedRepo);
  final workouts = await repo.fetchPredefinedWorkouts();

  // Group the workouts using the use case
  final groupUseCase = GroupWorkoutsUseCase();
  return groupUseCase(workouts);
});

/// Notifier for managing view mode state (Riverpod v3 manual pattern)
// class ViewModeNotifier extends Notifier<WorkoutViewMode> {
//   @override
//   WorkoutViewMode build() => WorkoutViewMode.list;

//   /// Toggle between list and grid view
//   void toggle() {
//     state = state == WorkoutViewMode.list
//         ? WorkoutViewMode.grid
//         : WorkoutViewMode.list;
//   }

//   /// Set a specific view mode
//   void set(WorkoutViewMode mode) {
//     state = mode;
//   }
// }

// /// Provider instance for view mode
// final viewModeProvider = NotifierProvider<ViewModeNotifier, WorkoutViewMode>(
//   ViewModeNotifier.new,
// );

import 'package:Warrior/features/Predefined_workouts/data/repo/predefined_repo.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Enum to represent view modes
enum WorkoutViewMode { list, grid }

/// Provider for fetching predefined workouts (Riverpod v3)
final predefinedProvider = FutureProvider<List<WorkoutSetModel>>((ref) async {
  final repo = ref.watch(predefinedRepo);
  return repo.fetchPredefinedWorkouts();
});

/// Notifier for managing view mode state (Riverpod v3 manual pattern)
class ViewModeNotifier extends Notifier<WorkoutViewMode> {
  @override
  WorkoutViewMode build() => WorkoutViewMode.list;

  /// Toggle between list and grid view
  void toggle() {
    state = state == WorkoutViewMode.list
        ? WorkoutViewMode.grid
        : WorkoutViewMode.list;
  }

  /// Set a specific view mode
  void set(WorkoutViewMode mode) {
    state = mode;
  }
}

/// Provider instance for view mode
final viewModeProvider = NotifierProvider<ViewModeNotifier, WorkoutViewMode>(
  ViewModeNotifier.new,
);

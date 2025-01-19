import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Workouts/data/models/workoutSet_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutsProvider =
    StateNotifierProvider.autoDispose<WorkoutsNotifier, ProviderStates>((ref) {
  return WorkoutsNotifier(ref.read(workoutRepo));
});

class WorkoutsNotifier extends StateNotifier<ProviderStates> {
  final WorkoutRepo _workoutRepo;

  WorkoutsNotifier(this._workoutRepo) : super(ProviderStates()) {
    getWorkoutSets();
  }

  List<WorkoutSetModel> workoutList = [];

  WorkoutSetModel newWorkout = WorkoutSetModel();

  Future<void> getWorkoutSets() async {
    state = ProviderStates(isLoading: true);
    try {
      workoutList = await _workoutRepo.getWorkoutSets();
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> createWorkoutSet(String name, String description) async {
    await _workoutRepo.createWorkoutSet(name: name, description: description);
  }
}

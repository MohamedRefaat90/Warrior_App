import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
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

  WorkoutSetModel newWorkout = WorkoutSetModel(
    name: '',
    description: '',
    workoutItems: [],
  );

  void fillNewWorkout({
    String? name,
    String? description,
    List<WorkoutItemModel>? workoutItems,
  }) {
    newWorkout = newWorkout.copyWith(
      name: name,
      description: description,
      workoutItems: workoutItems,
    );
  }

  void resetNewWorkout() {
    newWorkout = WorkoutSetModel(
      name: '',
      description: '',
      workoutItems: [],
    );
  }

  Future<void> getWorkoutSets() async {
    state = ProviderStates(isLoading: true);
    try {
      workoutList = await _workoutRepo.getWorkoutSets();
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> createWorkoutSet() async {
    try {
      state = ProviderStates(isLoading: true);
      await _workoutRepo.createWorkoutSet(newWorkout);
      await getWorkoutSets(); // Refresh the list after creating
      resetNewWorkout();
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> deleteWorkoutSet(int workoutID) async {
    try {
      _workoutRepo.deleteWorkoutSet(workoutID);
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }

  Future<void> updateWorkoutSet(WorkoutSetModel workout) async {
    try {
      state = ProviderStates(isLoading: true);
      await _workoutRepo.updateWorkoutSet(workout);
      await getWorkoutSets(); // Refresh the list after creating
      // resetNewWorkout();
      state = ProviderStates(isSuccess: true);
    } catch (e) {
      state = ProviderStates(errorMessage: e.toString());
    }
  }
}

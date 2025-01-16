import 'package:Warrior/features/Workouts/data/models/workoutSet_model.dart';
import 'package:Warrior/features/Workouts/data/repo/workout_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutsProvider = FutureProvider.autoDispose<List<WorkoutSetModel>>(
    (ref) => ref.read(workoutRepo).getWorkoutSets());

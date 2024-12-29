import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/data/repo/exercises_repo.dart';
import 'package:Warrior/features/Exercises/data/repo/muscle_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final muscleExerciseProvider = FutureProvider.family
    .autoDispose<List<ExerciseModel>, int>((ref, id) async {
  return await ref.read(exercisesRepo).getMuscleExercises(muscleID: id);
});

final musclesProvider = FutureProvider<List<MuscleModel>>((ref) async {
  return await ref.read(muscleRepo).getAllMuscles();
});

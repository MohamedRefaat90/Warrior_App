import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static late Box<ExerciseModel> exercisesBox;
  static late Box<MuscleModel> musclesBox;
  static late Box<WorkoutSetModel> workoutsBox;

  static Future<void> init() async {
    await Hive.initFlutter();

    Hive.registerAdapter(ExerciseModelAdapter());
    Hive.registerAdapter(MuscleModelAdapter());
    Hive.registerAdapter(WorkoutSetModelAdapter());
    Hive.registerAdapter(WorkoutItemModelAdapter());

    musclesBox = await Hive.openBox<MuscleModel>('muscles');
    exercisesBox = await Hive.openBox<ExerciseModel>('exercises');
    workoutsBox = await Hive.openBox<WorkoutSetModel>('workouts');
  }

  static Future<void> saveToHive(Box box, List data) async {
    try {
      await box.clear();
      for (int i = 0; i < data.length; i++) {
        await box.put(i, data[i]);
      }
    } catch (e) {
      debugPrint('Failed to save data to Hive: $e');
    }
  }
}

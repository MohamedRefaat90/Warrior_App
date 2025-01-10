import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

class HiveManager {
  static late Box<ExerciseModel> exercisesBox;
  static late Box<MuscleModel> musclesBox;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ExerciseModelAdapter());
    Hive.registerAdapter(MuscleModelAdapter());
    musclesBox = await Hive.openBox<MuscleModel>('muscles');
    exercisesBox = await Hive.openBox<ExerciseModel>('exercises');
  }

  static Future<void> saveToHive(Box box, List data) async {
    try {
      for (var item in data) {
        // Check if the item already exists (by id or another unique identifier)
        final exists = box.containsKey(item.id);
        if (exists == false) {
          await box.put(item.id, item);
        }
      }
    } catch (e) {
      debugPrint('Failed to save data to Hive: $e');
    }
  }
}

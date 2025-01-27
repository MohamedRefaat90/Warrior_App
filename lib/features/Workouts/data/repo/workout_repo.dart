import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/features/Workouts/data/models/workoutSet_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRepo = Provider<WorkoutRepo>((ref) {
  return WorkoutRepo(DioHandler.dio);
});

class WorkoutRepo {
  final Dio dio;

  WorkoutRepo(this.dio);

  Future<void> createWorkoutSet(WorkoutSetModel workoutSet) async {
    try {
      await dio.post(
        ApisUrl.workouts,
        data: {
          'name': workoutSet.name,
          'description': workoutSet.description,
          'workout_items':
              workoutSet.workoutItems?.map((item) => item.toMap()).toList(),
        },
      );
    } on DioException {
      rethrow;
    }
  }

  Future<List<WorkoutSetModel>> getWorkoutSets() async {
    try {
      final response = await dio.get(ApisUrl.workouts);
      final results = response.data['data']['results'] as List;
      return results
          .map((e) {
            try {
              return WorkoutSetModel.fromMap(e);
            } catch (e, stack) {
              debugPrint('Error parsing workout: $e\n$stack');
              return null;
            }
          })
          .whereType<WorkoutSetModel>()
          .toList();
    } on DioException catch (e) {
      debugPrint('Network error: ${e.message}\n${e.response?.data}');
      rethrow;
    }
  }
}

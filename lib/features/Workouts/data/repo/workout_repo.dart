import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/features/Workouts/data/models/workoutSet_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRepo = Provider<WorkoutRepo>((ref) {
  return WorkoutRepo(DioHandler.dio);
});

class WorkoutRepo {
  final Dio dio;

  WorkoutRepo(this.dio);

  Future<void> createWorkoutSet({
    required String name,
    required String description,
  }) async {
    try {
      await dio.post(
        ApisUrl.workouts,
        data: {'name': name, 'description': description},
      );
    } on DioException {
      rethrow;
    }
  }

  Future<List<WorkoutSetModel>> getWorkoutSets() async {
    try {
      final response = await dio.get(ApisUrl.workouts);
      return (response.data['data']['results'] as List)
          .map((e) => WorkoutSetModel.fromMap(e))
          .toList();
    } on DioException {
      rethrow;
    }
  }
}

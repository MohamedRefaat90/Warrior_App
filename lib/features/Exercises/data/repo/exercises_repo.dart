import 'package:Warrior/core/network/api_error_handler.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final exercisesRepo = Provider<ExercisesRepo>((ref) {
  return ExercisesRepo(DioHandler.dio);
});

class ExercisesRepo {
  final Dio _dio;
  ExercisesRepo(this._dio);

  /// Fetches all exercises for multiple muscles sequentially
  Future<List<ExerciseModel>> getAllExercises({
    required List<int> muscleIds,
  }) async {
    List<ExerciseModel> allExercises = [];

    for (final muscleId in muscleIds) {
      try {
        final exercises = await getMuscleExercises(muscleID: muscleId);
        allExercises.addAll(exercises);
      } catch (e) {
        TalkerService.warning(
          'Failed to fetch exercises for muscle $muscleId',
          'EXERCISES',
          e,
        );
      }
    }

    return allExercises;
  }

  Future<List<ExerciseModel>> getMuscleExercises(
      {required int muscleID}) async {
    try {
      final Response response = await _dio.get('Muscles/$muscleID/exercises/');
      List<ExerciseModel> exercises = [];
      for (var exercise in response.data['data']) {
        exercises.add(ExerciseModel.fromMap(exercise));
      }
      return exercises;
    } on DioException catch (e) {
      final String errorMessage =
          ErrorHandler.handle(e).apiErrorModel.message ??
              "An unknown error occurred";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }
}

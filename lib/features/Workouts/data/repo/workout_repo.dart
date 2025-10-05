import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRepo = Provider<WorkoutRepo>((ref) {
  return WorkoutRepo(ref.read(dioProvider));
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
          'workout_items': workoutSet.workoutItems!
              .map((e) =>
                  {"exercise_id": e.exercise.id, "last_weight": e.lastWeight})
              .toList()
        },
      );
    } on DioException {
      rethrow;
    }
  }

  Future<void> deleteWorkoutSet(int workoutID) async {
    try {
      await dio.delete("${ApisUrl.workouts}/$workoutID/");
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
              TalkerService.error(
                  'Error parsing workout', 'WORKOUT_REPO', e, stack);
              return null;
            }
          })
          .whereType<WorkoutSetModel>()
          .toList();
    } on DioException catch (e) {
      TalkerService.error('Network error in getWorkoutSets', 'WORKOUT_REPO', e);
      rethrow;
    }
  }

  Future<void> reorderWorkoutsList(
      List<Map<String, dynamic>> reorderedWorkouts) async {
    try {
      await dio.patch("${ApisUrl.workouts}/reorder/",
          data: {"workouts": reorderedWorkouts});
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateLastWeight(
      int workoutID, int exerciseID, num weight) async {
    try {
      await dio
          .patch("${ApisUrl.workouts}/$workoutID/update_last_weight/", data: {
        "exercise_id": exerciseID,
        "last_weight": weight,
      });
    } on DioException {
      rethrow;
    }
  }

  Future<void> updateWorkoutSet(WorkoutSetModel workoutSet) async {
    try {
      await dio.patch(
        "${ApisUrl.workouts}/${workoutSet.id}/",
        data: {
          'name': workoutSet.name,
          'description': workoutSet.description,
          'workout_items': workoutSet.workoutItems!
              .map((e) =>
                  {"exercise_id": e.exercise.id, "last_weight": e.lastWeight})
              .toList()
        },
      );
    } on DioException {
      rethrow;
    }
  }
}

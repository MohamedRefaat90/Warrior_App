import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/api_error_handler.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final workoutRepo = Provider<WorkoutRepo>((ref) {
  return WorkoutRepo(ref.read(dioProvider));
});

class WorkoutRepo {
  final Dio dio;

  WorkoutRepo(this.dio);

  /// Creates a backend-driven share link for a workout set and returns the URL.
  ///
  /// POSTs a compact payload to the server and expects `{ code, url }` back.
  Future<String> createShareLink(WorkoutSetModel workoutSet) async {
    try {
      final payload = {
        'name': workoutSet.name,
        'description': workoutSet.description,
        'workout_items': workoutSet.workoutItems
                ?.map((e) => {
                      'exercise_id': e.exercise.id,
                      'last_weight': e.lastWeight,
                    })
                .toList() ??
            [],
      };

      final Response response = await dio
          .post('${ApisUrl.workouts}${workoutSet.id}/share/', data: payload);

      // Be resilient to different envelope shapes.
      final data = response.data;
      if (data is Map && data['share_url'] is String) {
        return data['share_url'] as String;
      }
      if (data is Map &&
          data['data'] is Map &&
          data['data']['share_url'] is String) {
        return data['data']['share_url'] as String;
      }

      TalkerService.error(
          'Unexpected response from share endpoint', 'WORKOUT_REPO');
      throw StateError('Unexpected response from share endpoint');
    } on DioException catch (e) {
      TalkerService.error('createShareLink failed', 'WORKOUT_REPO', e);
      rethrow;
    }
  }

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

  Future<WorkoutSetModel> fetchSharedWorkout(String code) async {
    try {
      final Response response = await dio.get('${ApisUrl.workouts}share/$code');
      final Map<String, dynamic> body;

      // Extract data from response envelope
      if (response.data is Map && (response.data as Map)['data'] is Map) {
        body = (response.data as Map)['data'] as Map<String, dynamic>;
      } else {
        throw StateError('Unexpected response for fetchSharedWorkout');
      }

      final List<dynamic> items = (body['workout_items'] as List?) ?? [];

      final mappedItems = items.map((raw) {
        final map = (raw as Map).cast<String, dynamic>();

        // Parse the full exercise object from backend
        final exerciseData = map['exercise'] as Map<String, dynamic>?;
        final ExerciseModel exercise;

        if (exerciseData != null) {
          // Map backend response to ExerciseModel
          exercise = ExerciseModel(
            id: (exerciseData['id'] as num?)?.toInt() ?? 0,
            name: (exerciseData['name'] as String?) ?? '',
            description: (exerciseData['description'] as String?) ?? '',
            image: (exerciseData['image'] as String?) ?? '',
            video: (exerciseData['video'] as String?) ?? '',
            targetedMuscles: (exerciseData['targetedMuscles'] as String?) ?? '',
            muscleID: (exerciseData['muscle'] as num?)?.toInt() ?? 0,
            muscle: (exerciseData['muscle_name'] as String?) ?? '',
            equipmentType: exerciseData['equipment_type'] as String?,
          );
        } else {
          // Fallback: create minimal exercise if not provided
          exercise = ExerciseModel(
            id: 0,
            name: 'Unknown Exercise',
            description: '',
            image: '',
            video: '',
            targetedMuscles: '',
            muscleID: 0,
            muscle: '',
            equipmentType: null,
          );
        }

        return WorkoutItemModel(exercise: exercise, lastWeight: 0);
      }).toList();

      return WorkoutSetModel(
        name: (body['name'] as String?) ?? 'Shared Workout',
        description: (body['description'] as String?) ?? '',
        workoutItems: mappedItems,
      );
    } on DioException catch (e) {
      TalkerService.error('fetchSharedWorkout failed', 'WORKOUT_REPO', e);
      throw ErrorHandler.handle(e);
    }
  }

  /// Fetches a single workout by ID from the server.
  /// Used to refresh workout data after updates.
  Future<WorkoutSetModel> fetchWorkoutById(int workoutId) async {
    try {
      final response = await dio.get('${ApisUrl.workouts}$workoutId/');
      final data = response.data['data'] as Map<String, dynamic>?;
      if (data != null) {
        return WorkoutSetModel.fromMap(data);
      }
      // Fallback: some APIs return data directly
      return WorkoutSetModel.fromMap(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      TalkerService.error('fetchWorkoutById failed', 'WORKOUT_REPO', e);
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

  /// Updates the sets for a specific exercise within a workout.
  ///
  /// This endpoint handles add/edit/delete operations for sets.
  /// The server replaces the existing sets with the provided list.
  Future<void> updateExerciseSets({
    required int workoutSetId,
    required int exerciseId,
    required List<Map<String, dynamic>> sets,
  }) async {
    try {
      await dio.patch(
        "${ApisUrl.workouts}$workoutSetId/update_sets/",
        data: {
          'exercise_id': exerciseId,
          'sets': sets,
        },
      );
    } on DioException catch (e) {
      TalkerService.error('updateExerciseSets failed', 'WORKOUT_REPO', e);
      rethrow;
    }
  }

  Future<num?> updateLastWeight(
      int workoutID, int exerciseID, num weight) async {
    try {
      final response = await dio
          .patch("${ApisUrl.workouts}/$workoutID/update_last_weight/", data: {
        "exercise_id": exerciseID,
        "last_weight": weight,
      });

      if (response.data is Map &&
          response.data['data']['weight_change'] != null) {
        return response.data['data']['weight_change'] as num;
      }
      return null;
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

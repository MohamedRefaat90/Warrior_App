import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/providers/cache_provider.dart';
import 'package:Warrior/core/services/exercise_cache_manager.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final predefinedRepo = Provider<PredefinedWorkoutRepository>((ref) {
  return PredefinedWorkoutRepository(
    ref.read(dioProvider),
    ref.read(exerciseCacheManagerProvider),
  );
});

class PredefinedWorkoutRepository {
  final Dio _dio;
  final ExerciseCacheManager _exerciseCacheManager;

  PredefinedWorkoutRepository(this._dio, this._exerciseCacheManager);

  /// Fetches predefined workouts from the server only.
  /// Callers are responsible for persisting to Hive and updating cache metadata.
  Future<List<WorkoutSetModel>> fetchFromServer() async {
    final Response response = await _dio.get(ApisUrl.predefinedWorkouts);
    final List<dynamic> data = response.data['data'] as List<dynamic>;
    final workouts = data
        .map((e) => WorkoutSetModel.fromMap(e as Map<String, dynamic>))
        .toList();
    TalkerService.info(
      'Fetched ${workouts.length} predefined workouts from server',
      'PREDEFINED-REPO',
    );
    return workouts;
  }

  /// Caches exercise media files for the given workouts.
  /// Call after a successful [fetchFromServer] to populate offline media.
  Future<void> cacheExerciseMedia(List<WorkoutSetModel> workouts) async {
    try {
      await _exerciseCacheManager.autoCacheWorkoutExercises(workouts);
    } catch (e) {
      TalkerService.error(
        'Failed to auto-cache predefined workout exercises',
        'PREDEFINED-REPO',
        e,
      );
    }
  }

  /// Syncs exercise media paths from the local cache for offline workouts.
  void syncExercisesWithCache(List<WorkoutSetModel> workouts) {
    try {
      _exerciseCacheManager.syncWorkoutExercisesWithCache(workouts);
    } catch (e) {
      TalkerService.error(
        'Failed to sync predefined workouts with local cache',
        'PREDEFINED-REPO',
        e,
      );
    }
  }
}

import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final predefinedRepo = Provider<PredefinedWorkoutRepository>((ref) {
  return PredefinedWorkoutRepository(ref.read(dioProvider));
});

class PredefinedWorkoutRepository {
  final Dio _dio;

  PredefinedWorkoutRepository(this._dio);

  bool get _isOnline => ConnectivityChecker.isOnline == true;

  Future<List<WorkoutSetModel>> fetchPredefinedWorkouts() async {
    try {
      if (_isOnline) {
        // Online: Fetch from server and cache in Hive
        final Response response = await _dio.get(ApisUrl.predefinedWorkouts);
        if (response.statusCode == 200) {
          List<dynamic> data = response.data['data'];
          List<WorkoutSetModel> workouts =
              data.map((e) => WorkoutSetModel.fromMap(e)).toList();

          // Save to Hive for offline access
          await HiveManager.predefinedWorkoutsBox.clear();
          for (var workout in workouts) {
            await HiveManager.predefinedWorkoutsBox.add(workout);
          }

          TalkerService.info(
              'Fetched ${workouts.length} predefined workouts from server',
              'PREDEFINED-REPO');
          return workouts;
        }
      } else {
        // Offline: Load from Hive cache
        final cachedWorkouts =
            HiveManager.predefinedWorkoutsBox.values.toList();
        TalkerService.info(
            'Loaded ${cachedWorkouts.length} predefined workouts from cache',
            'PREDEFINED-REPO');
        return cachedWorkouts;
      }
    } catch (e) {
      // On error, try to load from cache as fallback
      TalkerService.error(
          'Error fetching predefined workouts: $e', 'PREDEFINED-REPO');
      final cachedWorkouts = HiveManager.predefinedWorkoutsBox.values.toList();
      if (cachedWorkouts.isNotEmpty) {
        TalkerService.info(
            'Falling back to ${cachedWorkouts.length} cached workouts',
            'PREDEFINED-REPO');
        return cachedWorkouts;
      }
    }
    return [];
  }
}

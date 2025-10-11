import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/dio.dart';
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

  Future<List<WorkoutSetModel>> fetchPredefinedWorkouts() async {
    try {
      final Response response = await _dio.get(ApisUrl.predefinedWorkouts);
      if (response.statusCode == 200) {
        List<dynamic> data = response.data['data'];
        List<WorkoutSetModel> workouts =
            data.map((e) => WorkoutSetModel.fromMap(e)).toList();
        TalkerService.info('Fetched ${workouts.length} predefined workouts',
            'PREDEFINED-REPO');
        return workouts;
      }
    } catch (e) {
      TalkerService.error(
          'Error fetching predefined workouts: $e', 'PREDEFINED-REPO');
    }
    return [];
  }
}

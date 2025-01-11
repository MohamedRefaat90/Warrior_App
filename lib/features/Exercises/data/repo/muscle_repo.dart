import 'package:Warrior/core/constants/apis_url.dart';
import 'package:Warrior/core/network/api_error_handler.dart';
import 'package:Warrior/core/network/dio.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final muscleRepo = Provider<MuscleRepo>((ref) {
  return MuscleRepo(DioHandler.dio);
});

class MuscleRepo {
  final Dio _dio;

  MuscleRepo(this._dio);

  Future<List<MuscleModel>> getAllMuscles() async {
    try {
      final Response response = await _dio.get(ApisUrl.muscles);
      final List<MuscleModel> muscles = [];
      for (final muscle in response.data['data']['results']) {
        muscles.add(MuscleModel.fromMap(muscle as Map<String, dynamic>));
      }
      return muscles;
    } on DioException catch (e) {
      final errorMessage = ErrorHandler.handle(e).apiErrorModel.message ??
          "An unknown error occurred";
      throw Exception(errorMessage);
    } catch (e) {
      throw Exception("An unexpected error occurred: ${e.toString()}");
    }
  }
}

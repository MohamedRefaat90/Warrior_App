import 'package:Warrior/core/network/provider_states.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/data/repo/muscle_repo.dart';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// final musclesProvider =
//     StateNotifierProvider.autoDispose<MuscleNotifier, ProviderStates>((ref) {
//   return MuscleNotifier(ref.read(muscleRepo));
// });

// class MuscleNotifier extends StateNotifier<ProviderStates> {
//   MuscleNotifier(this._repo) : super(ProviderStates()) {
//     getAllMuscles();
//   }

//   final MuscleRepo _repo;
//   List<MuscleModel> muscles = [];
//   Future<void> getAllMuscles() async {
//     try {
//       state = ProviderStates(isLoading: true);
//       muscles = await _repo.getAllMuscles();
//       state = ProviderStates(isSuccess: true);
//     } on DioException catch (e) {
//       state = ProviderStates(errorMessage: e.response!.data["message"]);
//     } catch (e) {
//       state = ProviderStates(errorMessage: e.toString());
//     }
//   }
// }

final muscleProvider = FutureProvider<List<MuscleModel>>((ref) async {
  return await ref.read(muscleRepo).getAllMuscles();
});

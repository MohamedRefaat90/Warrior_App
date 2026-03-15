import 'package:Warrior/core/network/cache_status_repository.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/cache_metadata_service.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/data/repo/exercises_repo.dart';
import 'package:Warrior/features/Exercises/data/repo/muscle_repo.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides exercises for a given muscle ID.
/// Auto-disposes because per-muscle data is only needed on the detail screen.
final muscleExerciseProvider = FutureProvider.family
    .autoDispose<List<ExerciseModel>, int>((ref, id) async {
  return await ref.read(exercisesRepo).getMuscleExercises(muscleID: id);
});

/// Provides the list of muscles with a cache-first strategy.
///
/// - On first build with existing Hive data: returns cached muscles immediately
///   (no loading spinner), then validates against the server in the background.
///
/// - On first build with no Hive data: fetches from the API and stores metadata.
///
/// - Not autoDispose, so it persists in memory across navigations, preventing
///   redundant re-fetches when the user navigates back to the screen.
final musclesProvider =
    AsyncNotifierProvider<MusclesNotifier, List<MuscleModel>>(
  MusclesNotifier.new,
);

class MusclesNotifier extends AsyncNotifier<List<MuscleModel>> {
  @override
  Future<List<MuscleModel>> build() async {
    final cached = HiveManager.musclesBox.values.toList();

    if (cached.isNotEmpty) {
      TalkerService.info(
        'Serving ${cached.length} muscles from Hive cache',
        'MUSCLES',
      );
      // Validate in background without blocking the UI.
      Future.microtask(_validateAndRefreshIfNeeded);
      return cached;
    }

    // No cache — must fetch from the network.
    return _fetchAndStoreMetadata();
  }

  /// Checks the lightweight `/cache-status/` endpoint. Fetches fresh data only
  /// when the server reports a change since the last full fetch.
  Future<void> _validateAndRefreshIfNeeded() async {
    if (!(ConnectivityChecker.isOnline ?? false)) return;

    try {
      final cacheStatusRepo = ref.read(cacheStatusRepositoryProvider);
      final status = await cacheStatusRepo.fetchCacheStatus();
      if (status == null) return;

      final needsRefresh = CacheMetadataService.needsRefresh(
        key: CacheMetadataService.muscles,
        serverLastUpdated: status.muscles.lastUpdated,
        serverCount: status.muscles.count,
      );

      if (!needsRefresh) return;

      TalkerService.info(
        'Muscles changed on server — fetching fresh data',
        'MUSCLES',
      );
      final muscles = await _fetchAndStoreMetadata(
        serverLastUpdated: status.muscles.lastUpdated,
        serverCount: status.muscles.count,
      );
      state = AsyncData(muscles);
    } catch (e, st) {
      TalkerService.error(
        'Background cache validation failed — keeping cached data',
        'MUSCLES',
        e,
        st,
      );
    }
  }

  /// Fetches fresh muscle data, saves to Hive, and persists cache metadata.
  Future<List<MuscleModel>> _fetchAndStoreMetadata({
    String? serverLastUpdated,
    int? serverCount,
  }) async {
    final muscles = await ref.read(muscleRepo).getAllMuscles();
    await HiveManager.saveToHive(HiveManager.musclesBox, muscles);

    // If we already have metadata from a prior cache-status call, use it.
    // Otherwise, fetch it so future navigations can use it.
    String? lastUpdated = serverLastUpdated;
    int count = serverCount ?? muscles.length;

    if (lastUpdated == null && (ConnectivityChecker.isOnline ?? false)) {
      final status =
          await ref.read(cacheStatusRepositoryProvider).fetchCacheStatus();
      if (status != null) {
        lastUpdated = status.muscles.lastUpdated;
        count = status.muscles.count;
      }
    }

    await CacheMetadataService.updateMetadata(
      key: CacheMetadataService.muscles,
      lastUpdated: lastUpdated,
      count: count,
    );

    TalkerService.info(
      'Fetched ${muscles.length} muscles from API and updated cache',
      'MUSCLES',
    );
    return muscles;
  }
}

import 'package:Warrior/core/network/cache_status_repository.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/cache_metadata_service.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Predefined_workouts/data/repo/predefined_repo.dart';
import 'package:Warrior/features/Predefined_workouts/domain/entities/workout_group.dart';
import 'package:Warrior/features/Predefined_workouts/domain/use_cases/group_workouts_use_case.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides predefined workouts grouped by category with a cache-first strategy.
///
/// - Returns Hive data immediately on return visits (no loading spinner).
/// - Validates against the server in the background and refreshes only when
///   the server reports a change.
/// - Not autoDispose so the provider persists in memory across navigations.
///   Call `ref.invalidate(groupedWorkoutsProvider)` on user logout to clear
///   stale data.
final groupedWorkoutsProvider =
    AsyncNotifierProvider<PredefinedWorkoutsNotifier, List<WorkoutGroup>>(
  PredefinedWorkoutsNotifier.new,
  retry: (retryCount, error) =>
      null, // Disable automatic retries; errors are handled in the UI with a retry button.
);

class PredefinedWorkoutsNotifier extends AsyncNotifier<List<WorkoutGroup>> {
  final _groupUseCase = GroupWorkoutsUseCase();

  @override
  Future<List<WorkoutGroup>> build() async {
    final cached = HiveManager.predefinedWorkoutsBox.values.toList();

    if (cached.isNotEmpty) {
      TalkerService.info(
        'Serving ${cached.length} predefined workouts from Hive cache',
        'PREDEFINED',
      );
      // Sync exercise media paths without blocking the UI.
      ref.read(predefinedRepo).syncExercisesWithCache(cached);
      // Validate against the server in the background.
      _scheduleBackgroundValidation();
      return _groupUseCase(cached);
    }

    // No cache — fetch only if online; throw if offline so the UI
    // shows the error state (with retry button) instead of empty list.
    if (!(ConnectivityChecker.isOnline ?? false)) {
      TalkerService.info(
        'Offline and no cache — throwing to show error state',
        'PREDEFINED',
      );
      throw Exception("No cached predefined workouts and device is offline");
    }
    return _fetchAndGroup();
  }

  /// Schedules [_validateAndRefreshIfNeeded] as a microtask with a disposal
  /// guard so the microtask is a no-op if the notifier is disposed first.
  void _scheduleBackgroundValidation() {
    var disposed = false;
    ref.onDispose(() => disposed = true);
    Future.microtask(() {
      if (!disposed) _validateAndRefreshIfNeeded();
    });
  }

  /// Checks the lightweight `/cache-status/` endpoint and refreshes only when
  /// the server reports a change since the last full fetch.
  Future<void> _validateAndRefreshIfNeeded() async {
    if (!(ConnectivityChecker.isOnline ?? false)) return;

    try {
      final status =
          await ref.read(cacheStatusRepositoryProvider).fetchCacheStatus();
      if (status == null) return;

      final needsRefresh = CacheMetadataService.needsRefresh(
        key: CacheMetadataService.predefinedWorkouts,
        serverLastUpdated: status.predefinedWorkouts.lastUpdated,
        serverCount: status.predefinedWorkouts.count,
      );

      if (!needsRefresh) return;

      TalkerService.info(
        'Predefined workouts changed on server — fetching fresh data',
        'PREDEFINED',
      );
      final groups = await _fetchAndGroup(
        serverLastUpdated: status.predefinedWorkouts.lastUpdated,
        serverCount: status.predefinedWorkouts.count,
      );
      state = AsyncData(groups);
    } catch (e, st) {
      TalkerService.error(
        'Background cache validation failed — keeping cached predefined workouts',
        'PREDEFINED',
        e,
        st,
      );
    }
  }

  /// Fetches fresh data from the server, persists to Hive, caches exercise
  /// media, updates cache metadata, and returns grouped workouts.
  Future<List<WorkoutGroup>> _fetchAndGroup({
    String? serverLastUpdated,
    int? serverCount,
  }) async {
    final repo = ref.read(predefinedRepo);
    final List<WorkoutSetModel> workouts;
    try {
      workouts = await repo.fetchFromServer();
    } catch (e, st) {
      TalkerService.error(
        'Failed to fetch predefined workouts from server',
        'PREDEFINED',
        e,
        st,
      );
      rethrow;
    }

    await _saveToHive(workouts);
    await repo.cacheExerciseMedia(workouts);

    String? lastUpdated = serverLastUpdated;
    int count = serverCount ?? workouts.length;

    if (lastUpdated == null && (ConnectivityChecker.isOnline ?? false)) {
      final status =
          await ref.read(cacheStatusRepositoryProvider).fetchCacheStatus();
      if (status != null) {
        lastUpdated = status.predefinedWorkouts.lastUpdated;
        count = status.predefinedWorkouts.count;
      }
    }

    await CacheMetadataService.updateMetadata(
      key: CacheMetadataService.predefinedWorkouts,
      lastUpdated: lastUpdated,
      count: count,
    );

    TalkerService.info(
      'Fetched ${workouts.length} predefined workouts from API and updated cache',
      'PREDEFINED',
    );
    return _groupUseCase(workouts);
  }

  Future<void> _saveToHive(List<WorkoutSetModel> workouts) async {
    await HiveManager.saveToHive(
      HiveManager.predefinedWorkoutsBox,
      workouts,
    );
  }
}

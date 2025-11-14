import 'package:Warrior/core/services/exercise_cache_manager.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provider for cache progress state
final cacheProgressProvider =
    NotifierProvider<CacheProgressNotifier, CacheProgress>(
  CacheProgressNotifier.new,
);

/// Stream provider for cache progress updates
final cacheProgressStreamProvider = StreamProvider<CacheProgress>((ref) {
  final cacheManager = ref.watch(exerciseCacheManagerProvider);
  return cacheManager.progressStream;
});

/// Provider for the singleton ExerciseCacheManager instance
final exerciseCacheManagerProvider = Provider<ExerciseCacheManager>((ref) {
  final manager = ExerciseCacheManager();
  ref.onDispose(() => manager.dispose());
  return manager;
});

/// Family provider for individual exercise cache status
final exerciseCacheStatusProvider =
    Provider.family.autoDispose<ExerciseCacheStatus, int>((ref, exerciseId) {
  final cacheProgress = ref.watch(cacheProgressProvider);

  // Get exercise from Hive
  final exercise = HiveManager.exercisesBox.get(exerciseId);
  if (exercise == null) {
    return ExerciseCacheStatus.notDownloaded;
  }

  // Check if this exercise is in the current batch being downloaded
  if (cacheProgress.status == CacheStatus.downloading &&
      cacheProgress.downloadingExerciseIds.contains(exerciseId)) {
    return ExerciseCacheStatus.downloading;
  }

  // Check if exercise is cached (has local file paths)
  if (_isLocalPath(exercise.image) &&
      _isLocalPath(exercise.targetedMuscles) &&
      _isLocalPath(exercise.video)) {
    return ExerciseCacheStatus.downloaded;
  }

  return ExerciseCacheStatus.notDownloaded;
});

/// Helper function to check if a path is local
bool _isLocalPath(String path) {
  return path.startsWith('/') || path.contains(':\\');
}

/// State notifier for managing cache progress
class CacheProgressNotifier extends Notifier<CacheProgress> {
  late ExerciseCacheManager _cacheManager;
  bool _isListening = false;

  @override
  CacheProgress build() {
    _cacheManager = ref.watch(exerciseCacheManagerProvider);

    // Only set up listener once
    if (!_isListening) {
      _listenToProgress();
      _isListening = true;
    }

    return const CacheProgress(
      totalExercises: 0,
      cachedExercises: 0,
      failedExercises: 0,
      status: CacheStatus.idle,
    );
  }

  /// Reset to idle state
  void reset() {
    state = const CacheProgress(
      totalExercises: 0,
      cachedExercises: 0,
      failedExercises: 0,
      status: CacheStatus.idle,
    );
  }

  /// Start caching exercises
  Future<void> startCaching({
    required List<ExerciseModel> exercises,
    bool force = false,
  }) async {
    if (state.status == CacheStatus.downloading && !force) {
      // Already downloading, skip
      return;
    }

    await _cacheManager.cacheExercises(
      box: HiveManager.exercisesBox,
      exercises: exercises,
    );
  }

  void _listenToProgress() {
    _cacheManager.progressStream.listen((progress) {
      state = progress;
    });
  }
}

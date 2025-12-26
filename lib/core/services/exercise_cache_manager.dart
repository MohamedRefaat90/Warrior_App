import 'dart:async';
import 'dart:io';

import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Progress information for cache operations
class CacheProgress {
  final int totalExercises;
  final int cachedExercises;
  final int failedExercises;
  final CacheStatus status;
  final String? currentExercise;
  final Set<int> downloadingExerciseIds;

  const CacheProgress({
    required this.totalExercises,
    required this.cachedExercises,
    required this.failedExercises,
    required this.status,
    this.currentExercise,
    this.downloadingExerciseIds = const {},
  });

  double get progress =>
      totalExercises > 0 ? cachedExercises / totalExercises : 0.0;

  CacheProgress copyWith({
    int? totalExercises,
    int? cachedExercises,
    int? failedExercises,
    CacheStatus? status,
    String? currentExercise,
    int? currentExerciseId,
    Set<int>? downloadingExerciseIds,
  }) {
    return CacheProgress(
      totalExercises: totalExercises ?? this.totalExercises,
      cachedExercises: cachedExercises ?? this.cachedExercises,
      failedExercises: failedExercises ?? this.failedExercises,
      status: status ?? this.status,
      currentExercise: currentExercise ?? this.currentExercise,
      downloadingExerciseIds:
          downloadingExerciseIds ?? this.downloadingExerciseIds,
    );
  }
}

/// Cache status enum
enum CacheStatus { idle, downloading, completed, failed }

/// Manages caching and persistence of exercise media assets
class ExerciseCacheManager {
  /// Unique cache key for exercise permanent cache
  static const String _cacheKey = 'exercisePermanentCache';

  /// Migration preference key
  static const String _migrationKey = 'exercise_cache_migrated_v1';

  final CacheManager _cacheManager;

  // Prevent concurrent operations on the same resource
  final Map<String, Future<String?>> _pendingDownloads = {};

  // Stream controller for progress updates
  final StreamController<CacheProgress> _progressController =
      StreamController<CacheProgress>.broadcast();

  ExerciseCacheManager()
      : _cacheManager = CacheManager(
          Config(
            _cacheKey,
            // 10 years - effectively permanent caching
            stalePeriod: const Duration(days: 365 * 10),
            // Increased limit: 3 files per exercise (image, video, muscle diagram)
            // 1000 files ≈ 333 exercises
            maxNrOfCacheObjects: 1000,
          ),
        );

  /// Stream of cache progress updates
  Stream<CacheProgress> get progressStream => _progressController.stream;

  /// Caches a single exercise and its media assets (image, video, targeted muscles).
  ///
  /// Returns `true` if the exercise was successfully cached (or already cached),
  /// `false` if caching failed for any asset.
  ///
  /// This method is used to cache individual exercises, particularly useful
  /// when caching exercises from workouts that weren't previously downloaded.
  Future<bool> cacheExercise(
    Box<ExerciseModel> box,
    ExerciseModel exercise,
  ) async {
    try {
      // Skip if already cached and exists in Hive with valid local paths
      if (box.containsKey(exercise.id)) {
        final cachedExercise = box.get(exercise.id);
        if (cachedExercise != null && await _isExerciseCached(cachedExercise)) {
          // TalkerService.debug(
          //     'Exercise ${exercise.id} already cached', 'CACHE');
          return true;
        }
      }

      // Cache all media assets in parallel
      final results = await Future.wait([
        _cacheMedia(exercise.image),
        _cacheMedia(exercise.targetedMuscles),
        _cacheMedia(exercise.video),
      ]);

      final imagePath = results[0];
      final targetedMusclesPath = results[1];
      final videoPath = results[2];

      // Only save if all assets were cached successfully
      if (imagePath == null ||
          targetedMusclesPath == null ||
          videoPath == null) {
        TalkerService.warning(
          'Incomplete cache for exercise ${exercise.id}',
          'CACHE',
        );
        return false;
      }

      // Persist to Hive with local paths
      await box.put(
        exercise.id,
        exercise.copyWith(
          image: imagePath,
          targetedMuscles: targetedMusclesPath,
          video: videoPath,
        ),
      );

      return true;
    } catch (e, stackTrace) {
      TalkerService.error(
        'Failed to cache exercise ${exercise.id}',
        'CACHE',
        e,
        stackTrace,
      );
      return false;
    }
  }

  /// Preloads and caches exercise media assets
  ///
  /// Downloads images, videos, and muscle diagrams for offline use.
  /// Returns the number of successfully cached exercises.
  Future<int> cacheExercises({
    required Box<ExerciseModel> box,
    required List<ExerciseModel> exercises,
    int concurrentDownloads = 3,
  }) async {
    if (exercises.isEmpty) return 0;

    TalkerService.info(
      'Starting cache for ${exercises.length} exercises',
      'CACHE',
    );

    int successCount = 0;
    int failedCount = 0;

    // Emit initial progress
    _progressController.add(CacheProgress(
      totalExercises: exercises.length,
      cachedExercises: 0,
      failedExercises: 0,
      status: CacheStatus.downloading,
    ));

    // Process exercises in batches for controlled concurrency
    for (var i = 0; i < exercises.length; i += concurrentDownloads) {
      final batch = exercises.skip(i).take(concurrentDownloads).toList();
      final batchIds = batch.map((e) => e.id).toSet();

      // Emit that this batch is being processed
      _progressController.add(CacheProgress(
        totalExercises: exercises.length,
        cachedExercises: successCount,
        failedExercises: failedCount,
        status: CacheStatus.downloading,
        currentExercise: batch.first.name,
        downloadingExerciseIds: batchIds,
      ));

      // Process each exercise in the batch sequentially to show progress
      for (final exercise in batch) {
        final success = await cacheExercise(box, exercise);

        if (success) {
          successCount++;
        } else {
          failedCount++;
        }

        // Emit progress update after each exercise
        _progressController.add(CacheProgress(
          totalExercises: exercises.length,
          cachedExercises: successCount,
          failedExercises: failedCount,
          status: CacheStatus.downloading,
          currentExercise: exercise.name,
          downloadingExerciseIds: batchIds,
        ));
      }
    }

    // Emit final progress
    _progressController.add(CacheProgress(
      totalExercises: exercises.length,
      cachedExercises: successCount,
      failedExercises: failedCount,
      status: failedCount > 0 ? CacheStatus.failed : CacheStatus.completed,
    ));

    TalkerService.info(
      'Cache completed: $successCount/${exercises.length} exercises cached, $failedCount failed',
      'CACHE',
    );

    return successCount;
  }

  /// Clears all cached exercise media
  Future<void> clearCache() async {
    try {
      await _cacheManager.emptyCache();
      TalkerService.info('Cache cleared successfully', 'CACHE');
    } catch (e) {
      TalkerService.error('Failed to clear cache', 'CACHE', e);
    }
  }

  /// Dispose resources
  void dispose() {
    _progressController.close();
  }

  /// Gets the current cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final store = _cacheManager.store as dynamic;
      final files = await store.retrieveCacheData() as List?;
      if (files == null) return 0;
      return files.fold<int>(
        0,
        (sum, file) => sum + (((file as dynamic).length ?? 0) as int),
      );
    } catch (e) {
      TalkerService.error('Failed to get cache size', 'CACHE', e);
      return 0;
    }
  }

  /// Checks if a single exercise is cached
  Future<ExerciseCacheStatus> getExerciseCacheStatus(
      ExerciseModel exercise) async {
    if (_pendingDownloads.containsKey(exercise.image) ||
        _pendingDownloads.containsKey(exercise.targetedMuscles) ||
        _pendingDownloads.containsKey(exercise.video)) {
      return ExerciseCacheStatus.downloading;
    }

    final isCached = await _isExerciseCached(exercise);
    return isCached
        ? ExerciseCacheStatus.downloaded
        : ExerciseCacheStatus.notDownloaded;
  }

  /// Caches a single media file and returns its local path
  Future<String?> _cacheMedia(String url) async {
    if (url.isEmpty) return null;

    // If already a local path, validate and return
    if (_isLocalPath(url)) {
      final file = File(url);
      if (await file.exists()) {
        return url;
      }
      return null;
    }

    // Prevent duplicate concurrent downloads
    if (_pendingDownloads.containsKey(url)) {
      return _pendingDownloads[url];
    }

    final downloadFuture = _downloadMedia(url);
    _pendingDownloads[url] = downloadFuture;

    try {
      final path = await downloadFuture;
      return path;
    } finally {
      _pendingDownloads.remove(url);
    }
  }

  /// Downloads or retrieves cached media file
  Future<String?> _downloadMedia(String url) async {
    try {
      // Check if already cached
      final cachedFile = await _cacheManager.getFileFromCache(url);
      if (cachedFile != null && await cachedFile.file.exists()) {
        return cachedFile.file.path;
      }

      // Download if not cached
      final downloadedFile = await _cacheManager.downloadFile(url);
      return downloadedFile.file.path;
    } catch (e) {
      TalkerService.warning('Failed to cache media: $url', 'CACHE', e);
      return null;
    }
  }

  /// Checks if exercise media is already cached
  Future<bool> _isExerciseCached(ExerciseModel exercise) async {
    // Check if paths are local and files exist
    if (_isLocalPath(exercise.image) &&
        _isLocalPath(exercise.targetedMuscles) &&
        _isLocalPath(exercise.video)) {
      final imageFile = File(exercise.image);
      final musclesFile = File(exercise.targetedMuscles);
      final videoFile = File(exercise.video);

      final results = await Future.wait([
        imageFile.exists(),
        musclesFile.exists(),
        videoFile.exists(),
      ]);

      return results.every((exists) => exists);
    }

    // Check cache manager
    final results = await Future.wait([
      _cacheManager.getFileFromCache(exercise.image),
      _cacheManager.getFileFromCache(exercise.targetedMuscles),
      _cacheManager.getFileFromCache(exercise.video),
    ]);

    return results.every((file) => file != null);
  }

  /// Checks if a path is a local file path
  bool _isLocalPath(String path) {
    return path.startsWith('/') || path.contains(':\\');
  }

  /// Migrates from DefaultCacheManager to permanent cache (one-time operation)
  ///
  /// This should be called during app initialization, before any caching operations.
  /// It clears the old DefaultCacheManager cache and Hive exercise data,
  /// allowing fresh downloads into the new permanent cache.
  static Future<void> migrateFromDefaultCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasMigrated = prefs.getBool(_migrationKey) ?? false;

      if (!hasMigrated) {
        TalkerService.info(
          'Starting migration from DefaultCacheManager to permanent cache...',
          'CACHE_MIGRATION',
        );

        // Step 1: Clear the old DefaultCacheManager cache
        await DefaultCacheManager().emptyCache();
        TalkerService.info(
          'Cleared old DefaultCacheManager cache',
          'CACHE_MIGRATION',
        );

        // Step 2: Clear Hive exercise box (old local paths are now invalid)
        await HiveManager.exercisesBox.clear();
        TalkerService.info(
          'Cleared Hive exercises box (old paths invalidated)',
          'CACHE_MIGRATION',
        );

        // Step 3: Mark migration as complete
        await prefs.setBool(_migrationKey, true);

        TalkerService.info(
          'Migration complete! Exercises will use permanent cache on next download.',
          'CACHE_MIGRATION',
        );
      }
    } catch (e, stackTrace) {
      TalkerService.error(
        'Failed to migrate cache (non-fatal, will retry on next launch)',
        'CACHE_MIGRATION',
        e,
        stackTrace,
      );
      // Don't rethrow - migration failure shouldn't crash the app
    }
  }
}

/// Individual exercise cache status
enum ExerciseCacheStatus { notDownloaded, downloading, downloaded }

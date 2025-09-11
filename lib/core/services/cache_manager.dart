import 'dart:async';
import 'dart:collection';
import 'dart:io';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataManager {
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();
  
  // Configuration constants
  static const int _maxConcurrentDownloads = 3;
  static const Duration _downloadTimeout = Duration(seconds: 30);
  static const int _maxRetries = 3;

  /// Preload data (images and videos) and save to Hive with improved error handling and performance
  static Future<void> preloadAndSaveData(
      Box<ExerciseModel> box, List<ExerciseModel> exercises) async {
    
    if (exercises.isEmpty) {
      AppLogger.info('No exercises to preload', 'CACHE');
      return;
    }

    AppLogger.info('Starting preload of ${exercises.length} exercises', 'CACHE');
    
    final List<Future<void>> downloadTasks = [];
    final semaphore = Semaphore(_maxConcurrentDownloads);
    int successCount = 0;
    int failureCount = 0;

    for (var exercise in exercises) {
      // Use semaphore to limit concurrent downloads and prevent memory exhaustion
      downloadTasks.add(
        semaphore.acquire().then((_) async {
          try {
            await _processExerciseWithRetry(box, exercise);
            successCount++;
            AppLogger.debug('Successfully processed exercise: ${exercise.id}', 'CACHE');
          } catch (e) {
            failureCount++;
            AppLogger.error('Failed to process exercise: ${exercise.id}', 'CACHE', e);
          } finally {
            semaphore.release();
          }
        }),
      );
    }

    // Wait for all downloads to complete with timeout
    try {
      await Future.wait(downloadTasks).timeout(
        Duration(minutes: 10), // Overall timeout for all downloads
        onTimeout: () {
          AppLogger.warning('Cache preload timed out', 'CACHE');
          throw TimeoutException('Cache preload timed out', Duration(minutes: 10));
        },
      );
    } catch (e) {
      AppLogger.error('Error during concurrent downloads', 'CACHE', e);
    }

    AppLogger.info('===========================================', 'CACHE');
    AppLogger.info('Cache preload completed: $successCount successful, $failureCount failed', 'CACHE');
    AppLogger.info('===========================================', 'CACHE');
  }

  /// Process a single exercise with retry logic
  static Future<void> _processExerciseWithRetry(
      Box<ExerciseModel> box, ExerciseModel exercise) async {
    
    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        await _processExercise(box, exercise);
        return; // Success, exit retry loop
      } catch (e) {
        if (attempt == _maxRetries) {
          AppLogger.error('Failed to process exercise ${exercise.id} after $_maxRetries attempts', 'CACHE', e);
          rethrow;
        } else {
          AppLogger.warning('Retry attempt $attempt for exercise ${exercise.id}: $e', 'CACHE');
          // Exponential backoff
          await Future.delayed(Duration(seconds: attempt * 2));
        }
      }
    }
  }

  /// Process a single exercise with proper resource management
  static Future<void> _processExercise(
      Box<ExerciseModel> box, ExerciseModel exercise) async {
    
    // Skip if already processed
    if (box.containsKey(exercise.id)) {
      AppLogger.debug('Exercise ${exercise.id} already cached, skipping', 'CACHE');
      return;
    }

    String? imagePath;
    String? targetedMusclesPath;
    String? videoPath;

    try {
      // Download image with timeout and proper error handling
      imagePath = await _downloadOrGetCachedFile(exercise.image, 'image');
      
      // Download targeted muscles image with timeout and proper error handling
      targetedMusclesPath = await _downloadOrGetCachedFile(exercise.targetedMuscles, 'targetedMuscles');
      
      // Download video with timeout and proper error handling
      videoPath = await _downloadOrGetCachedFile(exercise.video, 'video');

      // Only save to Hive if all downloads were successful
      if (imagePath != null && targetedMusclesPath != null && videoPath != null) {
        final updatedExercise = exercise.copyWith(
          image: imagePath,
          targetedMuscles: targetedMusclesPath,
          video: videoPath,
        );
        
        await box.put(exercise.id, updatedExercise);
        AppLogger.debug('Successfully saved exercise ${exercise.id} to Hive', 'CACHE');
      } else {
        throw Exception('One or more downloads failed for exercise ${exercise.id}');
      }
      
    } catch (e) {
      // Clean up any partially downloaded files on error
      await _cleanupPartialDownloads([imagePath, targetedMusclesPath, videoPath]);
      rethrow;
    }
  }

  /// Download or get cached file with proper error handling and timeout
  static Future<String?> _downloadOrGetCachedFile(String url, String type) async {
    if (url.isEmpty) {
      AppLogger.warning('Empty URL provided for $type', 'CACHE');
      return null;
    }

    try {
      AppLogger.debug('Checking cache for $type: $url', 'CACHE');
      
      // Check cache first
      final cachedFile = await _cacheManager.getFileFromCache(url);
      if (cachedFile != null) {
        AppLogger.debug('$type already cached: ${cachedFile.file.path}', 'CACHE');
        return cachedFile.file.path;
      }

      // Download with timeout
      AppLogger.debug('Downloading $type: $url', 'CACHE');
      final downloadedFile = await _cacheManager
          .downloadFile(url)
          .timeout(_downloadTimeout);
      
      return downloadedFile.file.path;
      
    } on TimeoutException catch (e) {
      AppLogger.error('Download timeout for $type: $url', 'CACHE', e);
      rethrow;
    } on SocketException catch (e) {
      AppLogger.error('Network error downloading $type: $url', 'CACHE', e);
      rethrow;
    } on HttpException catch (e) {
      AppLogger.error('HTTP error downloading $type: $url', 'CACHE', e);
      rethrow;
    } catch (e) {
      AppLogger.error('Unexpected error downloading $type: $url', 'CACHE', e);
      rethrow;
    }
  }

  /// Clean up partially downloaded files to prevent storage leaks
  static Future<void> _cleanupPartialDownloads(List<String?> paths) async {
    for (final path in paths) {
      if (path != null) {
        try {
          final file = File(path);
          if (await file.exists()) {
            await file.delete();
            AppLogger.debug('Cleaned up partial download: $path', 'CACHE');
          }
        } catch (e) {
          AppLogger.warning('Failed to cleanup file: $path', 'CACHE', e);
        }
      }
    }
  }
}

/// Simple semaphore implementation to limit concurrent operations
class Semaphore {
  final int maxCount;
  int _currentCount;
  final Queue<Completer<void>> _waitQueue = Queue<Completer<void>>();

  Semaphore(this.maxCount) : _currentCount = maxCount;

  Future<void> acquire() async {
    if (_currentCount > 0) {
      _currentCount--;
      return;
    } else {
      final completer = Completer<void>();
      _waitQueue.add(completer);
      return completer.future;
    }
  }

  void release() {
    if (_waitQueue.isNotEmpty) {
      final completer = _waitQueue.removeFirst();
      completer.complete();
    } else {
      _currentCount++;
    }
  }
}

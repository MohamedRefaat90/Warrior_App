import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:hive_flutter/hive_flutter.dart';

class DataManager {
  static final DefaultCacheManager _cacheManager = DefaultCacheManager();

  /// Preload data (images and videos) and save to Hive
  static Future<void> preloadAndSaveData(
      Box<ExerciseModel> box, List<ExerciseModel> exercises) async {
    for (var exercise in exercises) {
      try {
        // Check if the image Path is already cached
        String? imagePath;
        debugPrint('Checking cache for image: ${exercise.image}');
        final cachedImage =
            await _cacheManager.getFileFromCache(exercise.image);
        if (cachedImage != null) {
          debugPrint('Image already cached: ${cachedImage.file.path}');
          imagePath = cachedImage.file.path;
        } else {
          debugPrint('Downloading image: ${exercise.image}');
          final downloadedImage =
              await _cacheManager.downloadFile(exercise.image);
          imagePath = downloadedImage.file.path;
        }

        // Check if the targetedMusclesPath is already cached
        String? targetedMusclesPath;
        debugPrint(
            'Checking cache for targetedMuscles: ${exercise.targetedMuscles}');
        final cachedTargetedMuscles =
            await _cacheManager.getFileFromCache(exercise.targetedMuscles);
        if (cachedTargetedMuscles != null) {
          debugPrint(
              'targetedMuscles already cached: ${cachedTargetedMuscles.file.path}');
          targetedMusclesPath = cachedTargetedMuscles.file.path;
        } else {
          debugPrint(
              'Downloading targetedMuscles: ${exercise.targetedMuscles}');
          final downloadedImage =
              await _cacheManager.downloadFile(exercise.targetedMuscles);
          targetedMusclesPath = downloadedImage.file.path;
        }

        // Check if the video is already cached
        String? videoPath;
        debugPrint('Checking cache for video: ${exercise.video}');
        final cachedVideo =
            await _cacheManager.getFileFromCache(exercise.video);
        if (cachedVideo != null) {
          debugPrint('Video already cached: ${cachedVideo.file.path}');
          videoPath = cachedVideo.file.path;
        } else {
          debugPrint('Downloading video: ${exercise.video}');
          final downloadedVideo =
              await _cacheManager.downloadFile(exercise.video);
          videoPath = downloadedVideo.file.path;
        }

        // Save to Hive if not already saved
        if (!box.containsKey(exercise.id)) {
          debugPrint('Saving exercise to Hive: ${exercise.id}');
          // Create a new instance of ExerciseModel with updated paths
          final updatedExercise = exercise.copyWith(
            image: imagePath,
            targetedMuscles: targetedMusclesPath,
            video: videoPath,
          );
          await box.put(exercise.id, updatedExercise);
        }
      } catch (e) {
        debugPrint('Error handling exercise data: $e');
      }
    }
    debugPrint('===========================================');
    debugPrint("Data preloading and saving completed");
    debugPrint('===========================================');
  }
}

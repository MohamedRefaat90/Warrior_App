import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
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
        TalkerService.debug(
            'Checking cache for image: ${exercise.image}', 'CACHE');
        final cachedImage =
            await _cacheManager.getFileFromCache(exercise.image);
        if (cachedImage != null) {
          TalkerService.debug(
              'Image already cached: ${cachedImage.file.path}', 'CACHE');
          imagePath = cachedImage.file.path;
        } else {
          TalkerService.debug('Downloading image: ${exercise.image}', 'CACHE');
          final downloadedImage =
              await _cacheManager.downloadFile(exercise.image);
          imagePath = downloadedImage.file.path;
        }

        // Check if the targetedMusclesPath is already cached
        String? targetedMusclesPath;
        TalkerService.debug(
            'Checking cache for targetedMuscles: ${exercise.targetedMuscles}',
            'CACHE');
        final cachedTargetedMuscles =
            await _cacheManager.getFileFromCache(exercise.targetedMuscles);
        if (cachedTargetedMuscles != null) {
          TalkerService.debug(
              'targetedMuscles already cached: ${cachedTargetedMuscles.file.path}',
              'CACHE');
          targetedMusclesPath = cachedTargetedMuscles.file.path;
        } else {
          TalkerService.debug(
              'Downloading targetedMuscles: ${exercise.targetedMuscles}',
              'CACHE');
          final downloadedImage =
              await _cacheManager.downloadFile(exercise.targetedMuscles);
          targetedMusclesPath = downloadedImage.file.path;
        }

        // Check if the video is already cached
        String? videoPath;
        TalkerService.debug(
            'Checking cache for video: ${exercise.video}', 'CACHE');
        final cachedVideo =
            await _cacheManager.getFileFromCache(exercise.video);
        if (cachedVideo != null) {
          TalkerService.debug(
              'Video already cached: ${cachedVideo.file.path}', 'CACHE');
          videoPath = cachedVideo.file.path;
        } else {
          TalkerService.debug('Downloading video: ${exercise.video}', 'CACHE');
          final downloadedVideo =
              await _cacheManager.downloadFile(exercise.video);
          videoPath = downloadedVideo.file.path;
        }

        // Save to Hive if not already saved
        if (!box.containsKey(exercise.id)) {
          TalkerService.debug(
              'Saving exercise to Hive: ${exercise.id}', 'CACHE');
          // Create a new instance of ExerciseModel with updated paths
          final updatedExercise = exercise.copyWith(
            image: imagePath,
            targetedMuscles: targetedMusclesPath,
            video: videoPath,
          );
          await box.put(exercise.id, updatedExercise);
        }
      } catch (e) {
        TalkerService.error('Error handling exercise data', 'CACHE', e);
      }
    }
    TalkerService.info('===========================================', 'CACHE');
    TalkerService.info("Data preloading and saving completed", 'CACHE');
    TalkerService.info('===========================================', 'CACHE');
  }
}

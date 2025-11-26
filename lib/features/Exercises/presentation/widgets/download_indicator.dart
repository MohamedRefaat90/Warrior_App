import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/providers/cache_provider.dart';
import 'package:Warrior/core/services/exercise_cache_manager.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Download indicator banner for exercise cards
///
/// Shows download status with fancy animations:
/// - Not Downloaded: No indicator
/// - Downloading: Animated shimmer with cloud download icon
/// - Downloaded: Static banner with checkmark and "Available Offline" text
class DownloadIndicatorBanner extends ConsumerWidget {
  final ExerciseModel exercise;

  const DownloadIndicatorBanner({
    super.key,
    required this.exercise,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cacheStatus = ref.watch(exerciseCacheStatusProvider(exercise.id));

    // Don't show indicator if not downloaded
    if (cacheStatus == ExerciseCacheStatus.notDownloaded) {
      return const SizedBox.shrink();
    }

    return _buildBanner(context, cacheStatus);
  }

  Widget _buildBanner(BuildContext context, ExerciseCacheStatus status) {
    final isDownloading = status == ExerciseCacheStatus.downloading;

    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: isDownloading ? 110 : 55,
        alignment: Alignment.center,
        padding: EdgeInsets.symmetric(
            horizontal: isDownloading ? 6 : 0, vertical: 3),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: isDownloading
                ? [
                    AppColors.primaryColor.withValues(alpha: 0.7),
                    AppColors.primaryColor.withValues(alpha: 0.9),
                  ]
                : [
                    Colors.green.shade600.withValues(alpha: 0.8),
                    Colors.green.shade700.withValues(alpha: 0.95),
                  ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(8),
            bottomRight: Radius.circular(8),
            topLeft: Radius.circular(8),
            topRight: Radius.circular(8),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: isDownloading
            ? _buildDownloadingIndicator()
            : _buildDownloadedIndicator(),
      )
          .animate()
          .shimmer(
            duration: isDownloading ? 1500.ms : 0.ms,
            color: Colors.white.withValues(alpha: 0.3),
          )
          .slideY(
            begin: 1,
            end: 0,
            duration: 300.ms,
            curve: Curves.easeOut,
          )
          .fadeIn(duration: 300.ms),
    );
  }

  Widget _buildDownloadedIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.check_circle,
          color: Colors.white,
          size: 12,
        ),
        const SizedBox(width: 4),
        Text(
          'Offline',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }

  Widget _buildDownloadingIndicator() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.cloud_download_outlined,
          color: Colors.white,
          size: 12,
        ).animate().scale(
              begin: const Offset(0.8, 0.8),
              end: const Offset(1.2, 1.2),
              duration: 800.ms,
            ),
        const SizedBox(width: 4),
        Text(
          'Downloading...',
          style: TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w600,
            fontFamily: 'Poppins',
          ),
        ),
      ],
    );
  }
}

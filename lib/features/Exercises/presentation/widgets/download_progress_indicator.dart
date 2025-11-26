import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/providers/cache_provider.dart';
import 'package:Warrior/core/services/exercise_cache_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global download progress indicator
///
/// Shows a bottom snackbar with:
/// - Progress bar showing download completion
/// - Text showing "Downloading exercises: X/Y"
/// - Auto-dismisses on completion with success message
class DownloadProgressIndicator extends ConsumerStatefulWidget {
  const DownloadProgressIndicator({super.key});

  @override
  ConsumerState<DownloadProgressIndicator> createState() =>
      _DownloadProgressIndicatorState();
}

class _DownloadProgressIndicatorState
    extends ConsumerState<DownloadProgressIndicator> {
  bool _showSuccessMessage = false;
  bool _hasShownSuccess = false;

  @override
  Widget build(BuildContext context) {
    final cacheProgress = ref.watch(cacheProgressProvider);

    // Reset flags when status is idle
    if (cacheProgress.status == CacheStatus.idle) {
      if (_showSuccessMessage || _hasShownSuccess) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            setState(() {
              _showSuccessMessage = false;
              _hasShownSuccess = false;
            });
          }
        });
      }
      return const SizedBox.shrink();
    }

    // Don't show anything if no exercises
    if (cacheProgress.totalExercises == 0) {
      return const SizedBox.shrink();
    }

    // Handle completion state - only show once per download session
    if (cacheProgress.status == CacheStatus.completed &&
        !_showSuccessMessage &&
        !_hasShownSuccess) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          setState(() {
            _showSuccessMessage = true;
            _hasShownSuccess = true;
          });
          // Auto-dismiss success message after 2 seconds
          Future.delayed(const Duration(seconds: 2), () {
            if (mounted) {
              setState(() {
                _showSuccessMessage = false;
              });
              // Reset cache progress to idle after showing success
              Future.delayed(const Duration(milliseconds: 500), () {
                if (mounted) {
                  ref.read(cacheProgressProvider.notifier).reset();
                }
              });
            }
          });
        }
      });
    }

    // Show success message
    if (_showSuccessMessage &&
        !_hasShownSuccess &&
        cacheProgress.status == CacheStatus.completed) {
      return _buildSuccessMessage(cacheProgress);
    }

    // Show downloading progress
    if (cacheProgress.status == CacheStatus.downloading) {
      return _buildProgressIndicator(cacheProgress);
    }

    return const SizedBox.shrink();
  }

  @override
  void initState() {
    super.initState();
    // Reset flags when widget is created
    _showSuccessMessage = false;
    _hasShownSuccess = false;
  }

  Widget _buildProgressIndicator(CacheProgress progress) {
    final percentage = (progress.progress * 100).toInt();

    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.black.withValues(alpha: 0.3),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.primaryColor.withValues(alpha: 0.3),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.primaryColor.withValues(alpha: 0.1),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.cloud_download,
                    color: AppColors.primaryColor,
                    size: 20,
                  )
                      .animate(
                          // onPlay: (controller) => controller.repeat(),
                          )
                      .scale(
                        begin: const Offset(0.9, 0.9),
                        end: const Offset(1.1, 1.1),
                        duration: 1000.ms,
                      ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Downloading exercises',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black,
                            fontFamily: 'Poppins',
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${progress.cachedExercises}/${progress.totalExercises} completed',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.black.withValues(alpha: 0.6),
                            fontFamily: 'Poppins',
                          ),
                        ),
                      ],
                    ),
                  ),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                      fontFamily: 'Poppins',
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: TweenAnimationBuilder<double>(
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeInOut,
                  tween: Tween<double>(
                    begin: 0,
                    end: progress.progress,
                  ),
                  builder: (context, value, _) => LinearProgressIndicator(
                    value: value,
                    minHeight: 8,
                    backgroundColor:
                        AppColors.primaryColor.withValues(alpha: 0.1),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.primaryColor,
                    ),
                  ),
                ),
              ),
              if (progress.currentExercise != null) ...[
                const SizedBox(height: 8),
                Text(
                  'Downloading: ${progress.currentExercise}',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.black.withValues(alpha: 0.5),
                    fontFamily: 'Poppins',
                    fontStyle: FontStyle.italic,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ],
          ),
        ),
      )
          .animate()
          .slideY(
            begin: 1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          )
          .fadeIn(duration: 300.ms),
    );
  }

  Widget _buildSuccessMessage(CacheProgress progress) {
    return Positioned(
      bottom: 16,
      left: 16,
      right: 16,
      child: Material(
        elevation: 8,
        borderRadius: BorderRadius.circular(12),
        shadowColor: Colors.green.withValues(alpha: 0.3),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.green.shade600,
                Colors.green.shade700,
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.green.withValues(alpha: 0.3),
                blurRadius: 20,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.white,
                size: 24,
              ).animate().scale(
                    begin: const Offset(0, 0),
                    end: const Offset(1, 1),
                    duration: 400.ms,
                    curve: Curves.elasticOut,
                  ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Download Complete!',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        fontFamily: 'Poppins',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${progress.cachedExercises} exercises available offline',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.9),
                        fontFamily: 'Poppins',
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      )
          .animate()
          .slideY(
            begin: 1,
            end: 0,
            duration: 400.ms,
            curve: Curves.easeOutCubic,
          )
          .fadeIn(duration: 300.ms)
          .then(delay: 1500.ms)
          .slideY(
            begin: 0,
            end: 1,
            duration: 400.ms,
            curve: Curves.easeInCubic,
          )
          .fadeOut(duration: 300.ms),
    );
  }
}

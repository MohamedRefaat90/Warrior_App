import 'dart:io';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:video_player/video_player.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  CachedVideoPlayerPlus? _player;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        ),
        leading: Padding(
          padding: const EdgeInsets.all(8),
          child: Material(
            color: isDark
                ? Colors.white.withOpacity(0.1)
                : Colors.black.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => Navigator.of(context).pop(),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: isDark ? Colors.white : Colors.black87,
                size: 20,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          const BannerAdWidget(
              adUnitId: "ca-app-pub-7417773148722475/6306035388"),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                child: Column(
                  children: [
                    _ExerciseVideoPlayer(
                      player: _player,
                      isInitialized: _isVideoInitialized,
                      hasError: _hasVideoError,
                      errorMessage: _videoErrorMessage,
                    ),
                    const SizedBox(height: 20),
                    _ExerciseTitle(name: widget.exercise.name),
                    const SizedBox(height: 24),
                    _TargetedMusclesSection(
                      imageUrl: widget.exercise.targetedMuscles,
                    ),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void deactivate() {
    try {
      if (_player != null && _isVideoInitialized) {
        _player!.controller.pause();
      }
    } catch (e) {
      TalkerService.warning(
        'Error pausing video in deactivate',
        'EXERCISE_DETAILS',
      );
    }
    super.deactivate();
  }

  @override
  void dispose() {
    try {
      if (_player != null && _isVideoInitialized) {
        _player!.controller.pause();
      }
      _player?.dispose();
    } catch (e) {
      TalkerService.warning(
        'Error disposing video player',
        'EXERCISE_DETAILS',
      );
    }
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeLocalVideo() {
    try {
      final file = File(widget.exercise.video);

      _player = CachedVideoPlayerPlus.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _player!.initialize().then((_) {
        if (mounted && _player != null) {
          setState(() => _isVideoInitialized = true);
          try {
            _player!.controller
              ..setVolume(0)
              ..play()
              ..setLooping(true);
            TalkerService.info(
              'Local video initialized successfully',
              'EXERCISE_DETAILS',
            );
          } catch (e) {
            TalkerService.error(
              'Error configuring local video after initialization',
              'EXERCISE_DETAILS',
              e,
            );
          }
        }
      }).catchError((error) {
        TalkerService.error(
          'Local video initialization failed',
          'EXERCISE_DETAILS',
          error,
        );
        if (mounted) {
          setState(() {
            _hasVideoError = true;
            _videoErrorMessage = 'Video not available';
          });
        }
      });
    } catch (e, stackTrace) {
      TalkerService.error(
        'Local video setup failed',
        'EXERCISE_DETAILS',
        e,
        stackTrace,
      );
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage = 'Video file error';
        });
      }
    }
  }

  void _initializeNetworkVideo() {
    try {
      final uri = Uri.tryParse(widget.exercise.video);
      if (uri == null) {
        throw Exception('Invalid video URL: ${widget.exercise.video}');
      }

      _player = CachedVideoPlayerPlus.networkUrl(
        uri,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _player!.initialize().then((_) {
        if (mounted && _player != null) {
          setState(() => _isVideoInitialized = true);
          try {
            _player!.controller
              ..setVolume(0)
              ..play()
              ..setLooping(true);
            TalkerService.info(
              'Network video initialized successfully',
              'EXERCISE_DETAILS',
            );
          } catch (e) {
            TalkerService.error(
              'Error configuring network video after initialization',
              'EXERCISE_DETAILS',
              e,
            );
          }
        }
      }).catchError((error) {
        TalkerService.error(
          'Network video initialization failed',
          'EXERCISE_DETAILS',
          error,
        );
        if (mounted) {
          _initializeLocalVideo();
        }
      });
    } catch (e, stackTrace) {
      TalkerService.error(
        'Network video setup failed',
        'EXERCISE_DETAILS',
        e,
        stackTrace,
      );
      _initializeLocalVideo();
    }
  }

  void _initializeVideoPlayer() {
    try {
      final isOnline = ConnectivityChecker.isOnline;

      if (isOnline == null) {
        TalkerService.warning(
          'Connectivity status unknown, attempting network video',
          'EXERCISE_DETAILS',
        );
      }

      if (isOnline == true || isOnline == null) {
        _initializeNetworkVideo();
      } else {
        _initializeLocalVideo();
      }
    } catch (e, stackTrace) {
      TalkerService.error(
        'Exception in video initialization',
        'EXERCISE_DETAILS',
        e,
        stackTrace,
      );
      if (mounted) {
        setState(() {
          _hasVideoError = true;
          _videoErrorMessage = 'Failed to initialize video';
        });
      }
    }
  }
}

class _ExerciseTitle extends StatelessWidget {
  final String name;

  const _ExerciseTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.2)
                : AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [
                        AppColors.darkSecondary,
                        AppColors.darkPrimary,
                      ]
                    : [
                        AppColors.primaryColor,
                        AppColors.red,
                      ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.fitness_center_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              name,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontFamily: 'Poppins',
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : Colors.black87,
                height: 1.3,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ExerciseVideoPlayer extends StatelessWidget {
  final CachedVideoPlayerPlus? player;
  final bool isInitialized;
  final bool hasError;
  final String? errorMessage;

  const _ExerciseVideoPlayer({
    required this.player,
    required this.isInitialized,
    required this.hasError,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: double.infinity,
      constraints: BoxConstraints(
        minHeight: 200,
        maxHeight: 280,
      ),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.2)
                : AppColors.primaryColor.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: _buildVideoContent(),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (hasError) {
      return _VideoErrorWidget(errorMessage: errorMessage);
    }

    if (!isInitialized || player == null || !player!.isInitialized) {
      return const Center(child: CustomLoadingWidget());
    }

    // Additional safety check for controller initialization
    try {
      final controller = player!.controller;
      final aspectRatio = controller.value.aspectRatio;

      return AspectRatio(
        aspectRatio: aspectRatio,
        child: VideoPlayer(controller),
      );
    } catch (e) {
      // If controller is not properly initialized, show loading
      return const Center(child: CustomLoadingWidget());
    }
  }
}

class _ImageErrorWidget extends StatelessWidget {
  final String imageUrl;

  const _ImageErrorWidget({required this.imageUrl});

  @override
  Widget build(BuildContext context) {
    TalkerService.warning(
      'Failed to load targeted muscles image from network: $imageUrl',
      'EXERCISE_DETAILS',
    );

    final file = File(imageUrl);
    if (file.existsSync()) {
      return Image.file(
        file,
        width: 200,
        errorBuilder: (context, error, stackTrace) => const _ImagePlaceholder(),
      );
    }

    return const _ImagePlaceholder();
  }
}

class _ImagePlaceholder extends StatelessWidget {
  const _ImagePlaceholder();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: isDark
            ? const Color(0xFF1a1a2e).withOpacity(0.5)
            : const Color(0xFFf5f7fa),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image_rounded,
              size: 48,
              color: isDark ? Colors.grey.shade700 : Colors.grey.shade400,
            ),
            const SizedBox(height: 12),
            Text(
              'Image not available',
              style: TextStyle(
                color: isDark ? Colors.grey.shade600 : Colors.grey.shade500,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TargetedMusclesSection extends ConsumerWidget {
  final String imageUrl;

  const _TargetedMusclesSection({required this.imageUrl});

  bool get _isNetworkUrl {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final appSettings = ref.watch(appSettingsProvider.notifier);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? AppColors.darkSecondary.withOpacity(0.3)
              : AppColors.primaryColor.withOpacity(0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? AppColors.darkSecondary.withOpacity(0.15)
                : AppColors.primaryColor.withOpacity(0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [
                            AppColors.darkSecondary,
                            AppColors.darkPrimary,
                          ]
                        : [
                            AppColors.primaryColor,
                            AppColors.red,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.accessibility_new_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                context.l10n.targetedMuscles,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  fontFamily: appSettings.fontFamily(),
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? const Color(0xFF121212).withOpacity(0.5)
                  : const Color(0xFFf5f5f5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isNetworkUrl
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: double.infinity,
                      fit: BoxFit.contain,
                      alignment: Alignment.center,
                      fadeInDuration: const Duration(milliseconds: 200),
                      placeholder: (context, url) => SizedBox(
                        height: 200,
                        child: const Center(child: CustomLoadingWidget()),
                      ),
                      errorWidget: (context, url, error) =>
                          _ImageErrorWidget(imageUrl: imageUrl),
                    )
                  : Image.file(
                      File(imageUrl),
                      width: double.infinity,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) =>
                          const _ImagePlaceholder(),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VideoErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const _VideoErrorWidget({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      color: isDark ? const Color(0xFF2a2a3e) : const Color(0xFFfef2f2),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.videocam_off_rounded,
                size: 40,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Video Unavailable',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Colors.red,
              ),
            ),
            if (errorMessage != null) ...[
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  errorMessage!,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.black54,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

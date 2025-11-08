import 'dart:io';

import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cached_video_player_plus/cached_video_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:video_player/video_player.dart';

class ExerciseDetailsScreen extends StatefulWidget {
  final ExerciseModel exercise;

  const ExerciseDetailsScreen({super.key, required this.exercise});

  @override
  State<ExerciseDetailsScreen> createState() => _ExerciseDetailsScreenState();
}

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen>
    with SingleTickerProviderStateMixin {
  CachedVideoPlayerPlus? _player;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Container(
          margin: EdgeInsets.all(8.w),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.black.withOpacity(0.5)
                : Colors.white.withOpacity(0.9),
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            icon: Icon(
              Icons.arrow_back_ios_new_rounded,
              color: isDark ? Colors.white : Colors.black87,
              size: 20,
            ),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    const Color(0xFF1a1a2e),
                    const Color(0xFF16213e),
                    const Color(0xFF0f3460),
                  ]
                : [
                    const Color(0xFFf5f7fa),
                    const Color(0xFFe8ecf1),
                    const Color(0xFFdde3ea),
                  ],
          ),
        ),
        child: Column(
          children: [
            const BannerAdWidget(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: FadeTransition(
                  opacity: _fadeAnimation,
                  child: SlideTransition(
                    position: _slideAnimation,
                    child: Padding(
                      padding: EdgeInsets.symmetric(
                        horizontal: 16.w,
                        vertical: 20.h,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(height: 60.h),
                          _ExerciseVideoPlayer(
                            player: _player,
                            isInitialized: _isVideoInitialized,
                            hasError: _hasVideoError,
                            errorMessage: _videoErrorMessage,
                          ),
                          SizedBox(height: 24.h),
                          _ExerciseTitle(name: widget.exercise.name),
                          SizedBox(height: 32.h),
                          _TargetedMusclesSection(
                            imageUrl: widget.exercise.targetedMuscles,
                          ),
                          SizedBox(height: 24.h),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void deactivate() {
    _player?.controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _player?.controller.pause();
    _player?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
    _setupAnimations();
  }

  void _initializeLocalVideo() {
    try {
      final file = File(widget.exercise.video);

      _player = CachedVideoPlayerPlus.file(
        file,
        videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true),
      );

      _player!.initialize().then((_) {
        if (mounted) {
          setState(() => _isVideoInitialized = true);
          _player!.controller
            ..setVolume(0)
            ..play()
            ..setLooping(true);
          TalkerService.info(
            'Local video initialized successfully',
            'EXERCISE_DETAILS',
          );
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
        if (mounted) {
          setState(() => _isVideoInitialized = true);
          _player!.controller
            ..setVolume(0)
            ..play()
            ..setLooping(true);
          TalkerService.info(
            'Network video initialized successfully',
            'EXERCISE_DETAILS',
          );
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

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward();
  }
}

class _ExerciseTitle extends StatelessWidget {
  final String name;

  const _ExerciseTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [
                  Colors.deepPurple.withOpacity(0.3),
                  Colors.blue.withOpacity(0.2),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.7),
                ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.deepPurple.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Text(
        name,
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontFamily: 'Poppins',
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: isDark ? Colors.white : Colors.black87,
          letterSpacing: 0.5,
          height: 1.3,
        ),
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

    return Hero(
      tag: 'exercise_video',
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.deepPurple.withOpacity(0.3),
                    Colors.blue.withOpacity(0.2),
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.deepPurple.withOpacity(0.3)
                  : Colors.black.withOpacity(0.15),
              blurRadius: 30,
              offset: const Offset(0, 10),
              spreadRadius: -5,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.blue.withOpacity(0.2)
                  : Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: _buildVideoContent(),
            ),
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: isDark
                        ? Colors.white.withOpacity(0.1)
                        : Colors.black.withOpacity(0.05),
                    width: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVideoContent() {
    if (hasError) {
      return _VideoErrorWidget(errorMessage: errorMessage);
    }

    if (!isInitialized || player == null || !player!.isInitialized) {
      return const CustomLoadingWidget();
    }

    return AspectRatio(
      aspectRatio: player!.controller.value.aspectRatio,
      child: VideoPlayer(player!.controller),
    );
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
        width: 200.w,
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
      width: 220.w,
      height: 180.h,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.grey.shade800,
                  Colors.grey.shade900,
                ]
              : [
                  Colors.grey.shade100,
                  Colors.grey.shade200,
                ],
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image_not_supported_rounded,
            size: 48,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          SizedBox(height: 12.h),
          Text(
            'Image not available',
            style: TextStyle(
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class _TargetedMusclesSection extends StatelessWidget {
  final String imageUrl;

  const _TargetedMusclesSection({required this.imageUrl});

  bool get _isNetworkUrl {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: EdgeInsets.all(20.w),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.deepPurple.withOpacity(0.2),
                  Colors.blue.withOpacity(0.15),
                ]
              : [
                  Colors.white.withOpacity(0.9),
                  Colors.white.withOpacity(0.6),
                ],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: isDark
              ? Colors.white.withOpacity(0.1)
              : Colors.black.withOpacity(0.05),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.deepPurple.withOpacity(0.2)
                : Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fitness_center_rounded,
                color: isDark ? Colors.deepPurpleAccent : Colors.deepPurple,
                size: 24,
              ),
              SizedBox(width: 8.w),
              Text(
                'Targeted Muscles',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.black87,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          SizedBox(height: 20.h),
          Container(
            padding: EdgeInsets.all(12.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.black.withOpacity(0.2)
                  : Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.05)
                    : Colors.black.withOpacity(0.03),
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: _isNetworkUrl
                  ? CachedNetworkImage(
                      imageUrl: imageUrl,
                      width: 220.w,
                      alignment: Alignment.center,
                      memCacheWidth: 300,
                      memCacheHeight: 300,
                      maxWidthDiskCache: 400,
                      maxHeightDiskCache: 400,
                      fadeInDuration: const Duration(milliseconds: 300),
                      placeholder: (context, url) => SizedBox(
                        width: 220.w,
                        height: 180.h,
                        child: const CustomLoadingWidget(),
                      ),
                      errorWidget: (context, url, error) =>
                          _ImageErrorWidget(imageUrl: imageUrl),
                    )
                  : Image.file(
                      File(imageUrl),
                      width: 220.w,
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
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  Colors.red.withOpacity(0.2),
                  Colors.redAccent.withOpacity(0.1),
                ]
              : [
                  Colors.red.shade50,
                  Colors.red.shade100,
                ],
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.all(16.w),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.red.withOpacity(0.2)
                  : Colors.white.withOpacity(0.7),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.error_outline_rounded,
              size: 48,
              color: isDark ? Colors.redAccent : Colors.red.shade700,
            ),
          ),
          SizedBox(height: 12.h),
          Text(
            'Video Error',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white : Colors.red.shade900,
            ),
          ),
          if (errorMessage != null) ...[
            SizedBox(height: 8.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 24.w),
              child: Text(
                errorMessage!,
                style: TextStyle(
                  fontSize: 12,
                  color: isDark ? Colors.white70 : Colors.red.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

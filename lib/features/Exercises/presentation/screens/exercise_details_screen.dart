import 'dart:io';

import 'package:Warrior/core/constants/colors.dart';
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

class _ExerciseDetailsScreenState extends State<ExerciseDetailsScreen> {
  CachedVideoPlayerPlus? _player;
  bool _isVideoInitialized = false;
  bool _hasVideoError = false;
  String? _videoErrorMessage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Column(
        children: [
          const BannerAdWidget(),
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: EdgeInsets.all(10.w),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    _ExerciseVideoPlayer(
                      player: _player,
                      isInitialized: _isVideoInitialized,
                      hasError: _hasVideoError,
                      errorMessage: _videoErrorMessage,
                    ),
                    SizedBox(height: 10.h),
                    _ExerciseTitle(name: widget.exercise.name),
                    SizedBox(height: 40.h),
                    _TargetedMusclesImage(
                      imageUrl: widget.exercise.targetedMuscles,
                    ),
                    SizedBox(height: 10.h),
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
    _player?.controller.pause();
    super.deactivate();
  }

  @override
  void dispose() {
    _player?.controller.pause();
    _player?.dispose();
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
}

class _ExerciseTitle extends StatelessWidget {
  final String name;

  const _ExerciseTitle({required this.name});

  @override
  Widget build(BuildContext context) {
    return Text(
      name,
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
      textAlign: TextAlign.center,
      style: const TextStyle(
        fontFamily: 'Poppins',
        fontSize: 18,
        fontWeight: FontWeight.w600,
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
    return Container(
      width: double.infinity,
      height: 200.h,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.black, width: 3),
        borderRadius: BorderRadius.circular(10),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: _buildVideoContent(),
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
    return Container(
      width: 200.w,
      height: 150.h,
      color: Colors.grey[200],
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
          SizedBox(height: 8),
          Text('Image not available'),
        ],
      ),
    );
  }
}

class _TargetedMusclesImage extends StatelessWidget {
  final String imageUrl;

  const _TargetedMusclesImage({required this.imageUrl});

  bool get _isNetworkUrl {
    return imageUrl.startsWith('http://') || imageUrl.startsWith('https://');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _isNetworkUrl
            ? CachedNetworkImage(
                imageUrl: imageUrl,
                width: 200.w,
                alignment: Alignment.center,
                memCacheWidth: 300,
                memCacheHeight: 300,
                maxWidthDiskCache: 400,
                maxHeightDiskCache: 400,
                fadeInDuration: const Duration(milliseconds: 200),
                placeholder: (context, url) => const CustomLoadingWidget(),
                errorWidget: (context, url, error) =>
                    _ImageErrorWidget(imageUrl: imageUrl),
              )
            : Image.file(
                File(imageUrl),
                width: 200.w,
                errorBuilder: (context, error, stackTrace) =>
                    const _ImagePlaceholder(),
              ),
        const SizedBox(height: 8),
        const Text(
          'Targeted Muscles',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _VideoErrorWidget extends StatelessWidget {
  final String? errorMessage;

  const _VideoErrorWidget({this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 48, color: Colors.red),
          const SizedBox(height: 8),
          const Text('Video Error'),
          if (errorMessage != null) ...[
            const SizedBox(height: 4),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                errorMessage!,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

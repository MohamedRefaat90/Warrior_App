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
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      width: double.infinity,
                      height: 200.h,
                      decoration: BoxDecoration(
                        border: Border.all(color: AppColors.black, width: 3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: _buildVideoWidget(),
                      ),
                    ),
                    10.verticalSpace,
                    Text(
                      widget.exercise.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: "Poppins",
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    40.verticalSpace,
                    _buildTargetedMusclesImage(),
                    const Text(
                      "Targeted Muscles",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    10.verticalSpace,
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
  void dispose() {
    _player?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Widget _buildTargetedMusclesImage() {
    return CachedNetworkImage(
      imageUrl: widget.exercise.targetedMuscles,
      width: 200.w,
      alignment: Alignment.center,
      placeholder: (context, url) => const CustomLoadingWidget(),
      errorWidget: (context, url, error) {
        TalkerService.warning(
          'Failed to load targeted muscles image from network: $url',
          'EXERCISE_DETAILS',
          error,
        );

        // Try to load from local file if network fails
        try {
          return Image.file(
            File(widget.exercise.targetedMuscles),
            width: 200.w,
            errorBuilder: (context, error, stackTrace) {
              TalkerService.error(
                'Failed to load targeted muscles image from file',
                'EXERCISE_DETAILS',
                error,
                stackTrace,
              );
              return Container(
                width: 200.w,
                height: 150.h,
                color: Colors.grey[200],
                child: const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image_not_supported,
                        size: 48, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Image not available'),
                  ],
                ),
              );
            },
          );
        } catch (e) {
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
      },
    );
  }

  Widget _buildVideoWidget() {
    if (_hasVideoError) {
      return Container(
        color: Colors.grey[200],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            const Text('Video Error'),
            if (_videoErrorMessage != null) ...[
              const SizedBox(height: 4),
              Text(
                _videoErrorMessage!,
                style: const TextStyle(fontSize: 12),
                textAlign: TextAlign.center,
              ),
            ],
          ],
        ),
      );
    }

    if (!_isVideoInitialized || _player == null) {
      return const CustomLoadingWidget();
    }

    if (_player!.isInitialized) {
      return AspectRatio(
        aspectRatio: _player!.controller.value.aspectRatio,
        child: VideoPlayer(_player!.controller),
      );
    }

    return const CustomLoadingWidget();
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
          setState(() {
            _isVideoInitialized = true;
          });
          _player!.controller.setVolume(0);
          _player!.controller.play();
          _player!.controller.setLooping(true);
          TalkerService.info(
              'Local video initialized successfully', 'EXERCISE_DETAILS');
        }
      }).catchError((error) {
        TalkerService.error(
            'Local video initialization failed', 'EXERCISE_DETAILS', error);
        if (mounted) {
          setState(() {
            _hasVideoError = true;
            _videoErrorMessage = 'Video not available';
          });
        }
      });
    } catch (e, stackTrace) {
      TalkerService.error(
          'Local video setup failed', 'EXERCISE_DETAILS', e, stackTrace);
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
          setState(() {
            _isVideoInitialized = true;
          });
          _player!.controller.setVolume(0);
          _player!.controller.play();
          _player!.controller.setLooping(true);
          TalkerService.info(
              'Network video initialized successfully', 'EXERCISE_DETAILS');
        }
      }).catchError((error) {
        TalkerService.error(
            'Network video initialization failed', 'EXERCISE_DETAILS', error);
        if (mounted) {
          // Try local video as fallback
          _initializeLocalVideo();
        }
      });
    } catch (e, stackTrace) {
      TalkerService.error(
          'Network video setup failed', 'EXERCISE_DETAILS', e, stackTrace);
      _initializeLocalVideo();
    }
  }

  void _initializeVideoPlayer() {
    try {
      final isOnline = ConnectivityChecker.isOnline;

      if (isOnline == null) {
        TalkerService.warning(
            'Connectivity status unknown, attempting network video',
            'EXERCISE_DETAILS');
      }

      if (isOnline == true || isOnline == null) {
        _initializeNetworkVideo();
      } else {
        _initializeLocalVideo();
      }
    } catch (e, stackTrace) {
      TalkerService.error('Exception in video initialization',
          'EXERCISE_DETAILS', e, stackTrace);
      setState(() {
        _hasVideoError = true;
        _videoErrorMessage = 'Failed to initialize video';
      });
    }
  }
}

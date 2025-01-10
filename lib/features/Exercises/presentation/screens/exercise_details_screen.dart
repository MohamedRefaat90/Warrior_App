import 'dart:io';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
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
  late VideoPlayerController _controller;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(10),
              child: Container(
                width: double.infinity,
                height: 200.h,
                foregroundDecoration: BoxDecoration(
                    border: Border.all(color: AppColors.black, width: 3),
                    borderRadius: BorderRadius.circular(10)),
                child: _controller.value.isInitialized
                    ? AspectRatio(
                        aspectRatio: _controller.value.aspectRatio,
                        child: VideoPlayer(_controller),
                      )
                    : const CustomLoadingWidget(),
              ),
            ),
            Text(
              widget.exercise.name,
              style: const TextStyle(fontFamily: "Poppins"),
            ),
            40.verticalSpace,
            ConnectivityChecker.isOnline!
                ? CachedNetworkImage(
                    imageUrl: widget.exercise.targetedMuscles,
                    width: 200.w,
                    alignment: Alignment.center,
                    // cacheManager: MyCacheManager(),
                    placeholder: (context, url) => const Center(
                      child: CircularProgressIndicator(),
                    ),
                  )
                : Image.file(File(widget.exercise.targetedMuscles)),
            const Text("Targeted Muscles"),
            10.verticalSpace,
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  void _initializeVideoPlayer() {
    try {
      _controller = VideoPlayerController.networkUrl(
          Uri.parse(widget.exercise.video),
          videoPlayerOptions: VideoPlayerOptions(mixWithOthers: true))
        ..initialize().then((_) {
          setState(() {});
          _controller.setVolume(0);
          _controller.play();
          _controller.setLooping(true);
        }).catchError((error) {
          debugPrint("Video initialization error: $error");
        });
    } catch (e) {
      debugPrint("Exception in video initialization: $e");
    }
  }
}

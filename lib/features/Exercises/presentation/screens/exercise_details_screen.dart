import 'package:Warrior/core/services/cache_manager.dart';
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
          children: [
            // Center(
            //   child: _controller.value.isInitialized
            //       ? AspectRatio(
            //           aspectRatio: _controller.value.aspectRatio,
            //           child: VideoPlayer(_controller),
            //         )
            //       : const CircularProgressIndicator(),
            // ),
            Text(
              widget.exercise.name,
              style: const TextStyle(fontFamily: "Poppins"),
            ),
            40.verticalSpace,
            CachedNetworkImage(
              imageUrl: widget.exercise.targetedMuscles,
              width: 200.w,
              cacheManager: MyCacheManager(),
              placeholder: (context, url) => const Center(
                child: CircularProgressIndicator(),
              ),
            ),
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
      _controller =
          VideoPlayerController.contentUri(Uri.parse(widget.exercise.video))
            ..initialize().then((_) {
              setState(() {});
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

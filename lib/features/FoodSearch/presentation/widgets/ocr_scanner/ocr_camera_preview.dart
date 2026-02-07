import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Camera preview widget with proper aspect ratio handling.
class OcrCameraPreview extends StatelessWidget {
  final CameraController? controller;
  final bool isInitialized;
  final String? initError;

  const OcrCameraPreview({
    super.key,
    required this.controller,
    required this.isInitialized,
    this.initError,
  });

  @override
  Widget build(BuildContext context) {
    if (initError != null) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.camera_alt, size: 64, color: Colors.white54),
            const SizedBox(height: 16),
            Text(
              initError!,
              style: const TextStyle(color: Colors.white54),
            ),
          ],
        ),
      );
    }

    // Check if camera is properly initialized and not disposed
    if (!isInitialized ||
        controller == null ||
        !controller!.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(color: Colors.white),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Double-check controller is still valid during build
        if (!controller!.value.isInitialized) {
          return const SizedBox.shrink();
        }

        final size = constraints.biggest;
        final cameraAspectRatio = controller!.value.aspectRatio;
        var scale = size.aspectRatio * cameraAspectRatio;

        if (scale < 1) scale = 1 / scale;

        return ClipRect(
          child: Transform.scale(
            scale: scale,
            child: Center(child: CameraPreview(controller!)),
          ),
        );
      },
    );
  }
}

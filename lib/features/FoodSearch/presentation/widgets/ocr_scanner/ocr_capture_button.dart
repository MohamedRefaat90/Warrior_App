import 'package:flutter/material.dart';

/// Main capture button with loading state.
class OcrCaptureButton extends StatelessWidget {
  final VoidCallback? onPressed;
  final bool isLoading;

  const OcrCaptureButton({
    super.key,
    this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 72,
        height: 72,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 4),
        ),
        child: Container(
          margin: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isLoading ? Colors.grey : Colors.white,
          ),
          child: isLoading
              ? const Padding(
                  padding: EdgeInsets.all(16),
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Icon(Icons.camera_alt, size: 32, color: Colors.black),
        ),
      ),
    );
  }
}

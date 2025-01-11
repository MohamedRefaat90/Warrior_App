import 'package:flutter/material.dart';

class ImageError extends StatelessWidget {
  const ImageError({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Icon(Icons.warning_rounded, color: Colors.amber),
    );
  }
}

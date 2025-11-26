import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class ImageError extends StatelessWidget {
  const ImageError({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.warning_rounded,
        color: Colors.amber,
        size: ResponsiveUtils.value<double>(
          context,
          mobile: 50,
          tablet: 60,
          desktop: 70,
        ),
      ),
    );
  }
}

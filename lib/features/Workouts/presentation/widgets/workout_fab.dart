import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';

/// Animated floating action button for creating new workouts.
class WorkoutFab extends StatelessWidget {
  final Animation<double> scaleAnimation;

  final Animation<double> rotationAnimation;
  final VoidCallback onPressed;
  const WorkoutFab({
    required this.scaleAnimation,
    required this.rotationAnimation,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ScaleTransition(
      scale: scaleAnimation,
      child: RotationTransition(
        turns: rotationAnimation,
        child: FloatingActionButton.extended(
          elevation: 8,
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          icon: const Icon(Icons.add_rounded, size: 28),
          label: Text(
            'newWorkout'.tr(context),
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  color: AppColors.white,
                ),
          ),
          onPressed: onPressed,
        ),
      ),
    );
  }
}

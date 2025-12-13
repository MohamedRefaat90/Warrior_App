import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../providers/body_diagram_provider.dart';

/// Transparent gesture detection layer positioned over body images
class MuscleHotspotLayer extends ConsumerWidget {
  final List<MuscleModel> muscles;
  final bool isComingFromWorkoutScreen;
  final Size imageSize;

  const MuscleHotspotLayer({
    super.key,
    required this.muscles,
    required this.isComingFromWorkoutScreen,
    required this.imageSize,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentView = ref.watch(bodyDiagramProvider);
    final allHotspots = ref.watch(muscleHotspotsProvider);

    // Filter hotspots for current view
    final activeHotspots =
        allHotspots.where((h) => h.bodyView == currentView).toList();

    return GestureDetector(
      onTapUp: (details) {
        // Convert tap position to percentage
        final xPercent = details.localPosition.dx / imageSize.width;
        final yPercent = details.localPosition.dy / imageSize.height;

        // Find the tapped hotspot
        for (final hotspot in activeHotspots) {
          if (hotspot.containsPoint(xPercent, yPercent)) {
            _navigateToMuscle(context, hotspot.muscleKey);
            return;
          }
        }
      },
      behavior: HitTestBehavior.translucent,
      child: Container(
        color: Colors.transparent,
        width: imageSize.width,
        height: imageSize.height,
      ),
    );
  }

  void _navigateToMuscle(BuildContext context, String muscleKey) {
    // Find matching muscle from backend data (case-insensitive)
    final muscle = muscles.firstWhere(
      (m) => m.name.toLowerCase() == muscleKey.toLowerCase(),
      orElse: () => muscles.first, // Fallback to first muscle
    );

    // Navigate using existing pattern
    context.pushNamed(
      AppRouters.exercises,
      extra: {
        'id': muscle.id,
        'name': muscle.name,
        'isComingFromWorkoutScreen': isComingFromWorkoutScreen,
      },
    );
  }
}

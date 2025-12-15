import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/localization/muscle_translations.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Fancy card displaying muscle name and exercise count
class MuscleLabelCard extends StatelessWidget {
  final MuscleModel muscle;
  final bool isComingFromWorkoutScreen;

  const MuscleLabelCard({
    super.key,
    required this.muscle,
    required this.isComingFromWorkoutScreen,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primaryColor = theme.colorScheme.primary;

    return GestureDetector(
      onTap: () => _navigate(context),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.darkPrimary,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Muscle Info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  translateMuscleName(context, muscle.name).capitalizeWord(),
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.3,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 3),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.fitness_center_rounded,
                      size: 10,
                      color: primaryColor,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${muscle.exerciseCount} ${context.l10n.exercise}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(width: 12),

            // Arrow Indicator
            Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.chevron_right_rounded,
                size: 16,
                color: primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigate(BuildContext context) {
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

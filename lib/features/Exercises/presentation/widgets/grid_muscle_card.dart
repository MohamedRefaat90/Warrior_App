import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/widgets/image_error.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GridMuscleCard extends StatelessWidget {
  final MuscleModel muscle;

  final bool? isComingFromWorkoutScreen;
  final bool isDark;
  final Color primaryColor;
  const GridMuscleCard({
    super.key,
    required this.muscle,
    required this.isComingFromWorkoutScreen,
    required this.isDark,
    required this.primaryColor,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(
        AppRouters.exercises,
        extra: {
          'id': muscle.id,
          'name': muscle.name,
          'isComingFromWorkoutScreen': isComingFromWorkoutScreen,
        },
      ),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [
                    Colors.grey.shade900,
                    Colors.grey.shade800,
                  ]
                : [
                    Colors.white,
                    Colors.grey.shade50,
                  ],
          ),
          border: Border.all(
            // color: primaryColor.withOpacity(0.3),
            color: AppColors.primaryColor!.withOpacity(0.3),
            width: 1.5,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Image with gradient overlay
            Flexible(
              flex: 3,
              fit: FlexFit.loose,
              child: Container(
                margin: const EdgeInsets.all(12),
                constraints: const BoxConstraints(
                  maxHeight: 120,
                  minHeight: 80,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      primaryColor.withOpacity(0.1),
                      primaryColor.withOpacity(0.05),
                    ],
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: CachedNetworkImage(
                    imageUrl: muscle.image,
                    fit: BoxFit.cover,
                    placeholder: (context, url) => const CustomLoadingWidget(),
                    errorWidget: (context, url, error) => const ImageError(),
                  ),
                ),
              ),
            ),
            // Muscle name
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                muscle.name,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 4),
            // Exercise count badge
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    primaryColor.withOpacity(0.5),
                    primaryColor,
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Text(
                '${muscle.exerciseCount} Exercises',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

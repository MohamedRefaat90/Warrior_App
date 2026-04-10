import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/muscle_translations.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/image_error.dart';
import 'package:Warrior/core/widgets/loading_widget.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class GridMuscleCard extends StatelessWidget {
  final MuscleModel muscle;

  final bool? isComingFromWorkoutScreen;
  final bool? appendToExistingWorkoutSet;
  final bool isDark;
  final Color primaryColor;
  const GridMuscleCard({
    super.key,
    required this.muscle,
    required this.isComingFromWorkoutScreen,
    this.appendToExistingWorkoutSet,
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
          'appendToExistingWorkoutSet': appendToExistingWorkoutSet,
        },
      ),
      borderRadius: BorderRadius.circular(context.responsiveBorderRadius + 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius:
              BorderRadius.circular(context.responsiveBorderRadius + 8),
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
            color: AppColors.primaryColor.withOpacity(0.3),
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
                margin: EdgeInsets.all(context.smallSpacing),
                constraints: BoxConstraints(
                  maxHeight: ResponsiveUtils.value(context,
                      mobile: 120.0, tablet: 140.0, desktop: 160.0),
                  minHeight: ResponsiveUtils.value(context,
                      mobile: 80.0, tablet: 100.0, desktop: 120.0),
                ),
                decoration: BoxDecoration(
                  borderRadius:
                      BorderRadius.circular(context.responsiveBorderRadius + 4),
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
                  borderRadius:
                      BorderRadius.circular(context.responsiveBorderRadius + 4),
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
              padding: EdgeInsets.symmetric(horizontal: context.smallSpacing),
              child: Text(
                translateMuscleName(context, muscle.name),
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black,
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

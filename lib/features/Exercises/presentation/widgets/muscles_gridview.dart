import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/grid_muscle_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusclesGridView extends ConsumerWidget {
  final List<MuscleModel> muscles;
  final bool? isComingFromWorkoutScreen;
  final bool? appendToExistingWorkoutSet;

  const MusclesGridView({
    super.key,
    required this.muscles,
    this.isComingFromWorkoutScreen,
    this.appendToExistingWorkoutSet,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        children: [
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: ResponsiveUtils.getGridColumns(context),
              childAspectRatio: 0.85,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
            ),
            itemCount: muscles.length - 1,
            padding: EdgeInsets.only(bottom: 12),
            itemBuilder: (context, index) {
              final muscle = muscles[index];
              return TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: Duration(milliseconds: 300 + (index * 50)),
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return Transform.scale(
                    scale: value,
                    child: Opacity(
                      opacity: value,
                      child: child,
                    ),
                  );
                },
                child: GridMuscleCard(
                    muscle: muscle,
                    isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                    isDark: isDark,
                    primaryColor: AppColors.darkPrimary),
              );
            },
          ),
          Center(
            child: GridMuscleCard(
                muscle: muscles.last,
                isComingFromWorkoutScreen: isComingFromWorkoutScreen,
                isDark: isDark,
                primaryColor: AppColors.darkPrimary),
          ),
        ],
      ),
    );
  }
}

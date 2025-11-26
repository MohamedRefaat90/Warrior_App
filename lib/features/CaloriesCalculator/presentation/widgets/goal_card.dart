import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

/// Goal selection card widget
class GoalCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String value;
  final bool isSelected;
  final Color color;
  final VoidCallback onTap;

  const GoalCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    required this.isSelected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: context.cardPadding,
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
          border: Border.all(
            color:
                isSelected ? color : colorScheme.outline.withValues(alpha: 0.3),
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: color.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 6),
                  ),
                ]
              : [],
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              padding: EdgeInsets.all(context.smallSpacing),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 0.3 : 0.2),
                borderRadius:
                    BorderRadius.circular(context.responsiveBorderRadius - 2),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(
                  icon,
                  color: color,
                  size: ResponsiveUtils.iconSize(context,
                      mobile: 24, tablet: 28, desktop: 32),
                ),
              ),
            ),
            SizedBox(width: context.mediumSpacing),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight:
                              isSelected ? FontWeight.bold : FontWeight.w600,
                          color: colorScheme.onSurface,
                        ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                  ),
                ],
              ),
            ),
            AnimatedScale(
              duration: const Duration(milliseconds: 300),
              scale: isSelected ? 1.0 : 0.0,
              child: Icon(
                Icons.check_circle,
                color: color,
                size: ResponsiveUtils.iconSize(context,
                    mobile: 24, tablet: 28, desktop: 32),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

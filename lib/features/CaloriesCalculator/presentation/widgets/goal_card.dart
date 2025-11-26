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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color:
              isSelected ? color.withValues(alpha: 0.1) : colorScheme.surface,
          borderRadius: BorderRadius.circular(15),
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
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withValues(alpha: isSelected ? 0.3 : 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.1 : 1.0,
                child: Icon(icon, color: color, size: 24),
              ),
            ),
            const SizedBox(width: 15),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 300),
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight:
                          isSelected ? FontWeight.bold : FontWeight.w600,
                      color: colorScheme.onSurface,
                    ),
                    child: Text(title),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 12,
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
                size: 24,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

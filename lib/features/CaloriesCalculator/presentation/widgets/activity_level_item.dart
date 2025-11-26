import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Activity level selection item widget
class ActivityLevelItem extends StatelessWidget {
  final String value;
  final String label;
  final String description;
  final bool isSelected;
  final VoidCallback onTap;

  const ActivityLevelItem({
    super.key,
    required this.value,
    required this.label,
    required this.description,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isSelected
                ? AppColors.primaryColor.withValues(alpha: 0.1)
                : isDarkMode
                    ? AppColors.darkSurface
                    : AppColors.white,
            borderRadius: BorderRadius.circular(15),
            border: Border.all(
              color: isSelected
                  ? AppColors.primaryColor
                  : AppColors.black.withValues(alpha: 0.1),
              width: 2,
            ),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                      color: AppColors.primaryColor.withValues(alpha: 0.2),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [],
          ),
          child: Row(
            children: [
              AnimatedScale(
                duration: const Duration(milliseconds: 300),
                scale: isSelected ? 1.2 : 1.0,
                child: Icon(
                  isSelected
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: isSelected
                      ? AppColors.primaryColor
                      : isDarkMode
                          ? AppColors.white.withValues(alpha: 0.5)
                          : AppColors.black.withValues(alpha: 0.3),
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
                        color: isDarkMode ? AppColors.white : AppColors.black,
                      ),
                      child: Text(label),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      description,
                      style: TextStyle(
                        fontSize: 12,
                        color: isDarkMode
                            ? AppColors.white.withValues(alpha: 0.6)
                            : AppColors.black.withValues(alpha: 0.6),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

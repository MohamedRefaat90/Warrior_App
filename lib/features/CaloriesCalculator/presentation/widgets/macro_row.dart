import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

/// Macro row displaying individual macronutrient details
class MacroRow extends StatelessWidget {
  final String label;
  final double grams;
  final double calories;
  final double percentage;
  final Color color;

  const MacroRow({
    super.key,
    required this.label,
    required this.grams,
    required this.calories,
    required this.percentage,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${grams.toStringAsFixed(0)}g • ${calories.toStringAsFixed(0)} kcal',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppColors.black.withValues(alpha: 0.6),
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${percentage.toStringAsFixed(0)}%',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

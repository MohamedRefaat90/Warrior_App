import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/filter_section_header.dart';
import 'package:flutter/material.dart';

class NutriScoreFilter extends StatelessWidget {
  final String? selectedScore;
  final ValueChanged<String?> onSelected;

  const NutriScoreFilter({
    super.key,
    required this.selectedScore,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterSectionHeader(
      title: context.l10n.nutriScore,
      content: Wrap(
        spacing: context.smallSpacing,
        children: ['A', 'B', 'C', 'D', 'E'].map((score) {
          final isSelected = selectedScore == score;
          return FilterChip(
            label: Text(
              score,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            onSelected: (selected) {
              onSelected(selected ? score : null);
            },
            backgroundColor: _getNutriScoreColor(score).withValues(alpha: 0.2),
            selectedColor: _getNutriScoreColor(score),
          );
        }).toList(),
      ),
    );
  }

  Color _getNutriScoreColor(String score) {
    switch (score.toUpperCase()) {
      case 'A':
        return Colors.green;
      case 'B':
        return Colors.lightGreen;
      case 'C':
        return Colors.yellow;
      case 'D':
        return Colors.orange;
      case 'E':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

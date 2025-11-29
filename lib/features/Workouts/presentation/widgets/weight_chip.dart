import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/features/Workouts/data/data_sources/workout_item_weights.dart';
import 'package:flutter/material.dart';

class WeightChip extends StatelessWidget {
  final dynamic type;
  final num weight;
  final num lastWeight;
  final Function(num) onWeightSelected;

  const WeightChip({
    super.key,
    required this.type,
    required this.weight,
    required this.lastWeight,
    required this.onWeightSelected,
  });

  @override
  Widget build(BuildContext context) {
    bool isSelected = weight == lastWeight;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return ChoiceChip(
        selected: isSelected,
        onSelected: (value) {
          if (value) {
            onWeightSelected(weight);
          }
        },
        selectedColor: AppColors.green,
        labelPadding: const EdgeInsets.symmetric(horizontal: 50),
        label: Text.rich(
          TextSpan(
            children: [
              TextSpan(text: "$weight "),
              TextSpan(
                  text: type is MachineWeights
                      ? context.l10n.bar
                      : context.l10n.kg),
            ],
            style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDark
                    ? AppColors.white
                    : (isSelected ? AppColors.white : AppColors.black)),
          ),
        ));
  }
}

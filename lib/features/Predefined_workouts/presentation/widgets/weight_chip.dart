import 'package:Warrior/core/constants/colors.dart';
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
              TextSpan(text: type is MachineWeights ? "bar" : "kg"),
            ],
            style: TextStyle(
                color: isSelected ? AppColors.white : AppColors.black)),
      ),
    );
  }
}

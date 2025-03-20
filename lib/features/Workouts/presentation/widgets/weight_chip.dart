import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/features/Workouts/data/data_sources/workout_item_weights.dart';
import 'package:flutter/material.dart';

class WeightChip extends StatelessWidget {
  final dynamic type;
  final num weight;
  final num lastWeight;
  const WeightChip({
    super.key,
    required this.type,
    required this.weight,
    required this.lastWeight,
  });
  @override
  Widget build(BuildContext context) {
    num? newWeight;
    return ChoiceChip(
        selected: weight == lastWeight,
        onSelected: (value) {
          newWeight = weight;
        },
        selectedColor: AppColors.green,
        labelPadding: EdgeInsets.symmetric(horizontal: 50),
        label: Text.rich(TextSpan(children: [
          TextSpan(text: "$weight "),
          TextSpan(text: type is MachineWeights ? "bar" : "kg")
        ])));
  }
}

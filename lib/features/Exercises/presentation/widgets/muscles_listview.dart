// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusclesListView extends StatelessWidget {
  final List<MuscleModel> muscles;
  const MusclesListView({super.key, required this.muscles});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: ListView.separated(
          shrinkWrap: true,
          itemBuilder: (context, index) => MuscleTile(muscle: muscles[index]),
          separatorBuilder: (context, index) => 10.verticalSpace,
          itemCount: muscles.length),
    );
  }
}

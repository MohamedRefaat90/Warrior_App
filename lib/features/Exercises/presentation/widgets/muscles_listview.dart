// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class MusclesListView extends StatelessWidget {
  final List<MuscleModel> muscles;
  final bool? isComingFromWorkoutScreen;
  const MusclesListView({
    super.key,
    required this.muscles,
    this.isComingFromWorkoutScreen,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 5),
      child: Column(
        children: [
          ListView.separated(
              shrinkWrap: true,
              itemBuilder: (context, index) =>
                  MuscleTile(muscle: muscles[index]),
              separatorBuilder: (context, index) => 10.verticalSpace,
              itemCount: muscles.length),
          if (isComingFromWorkoutScreen ?? false)
            CustomBTN(
                widget: Text("Finish Your Workout Set".capitalizeWord()),
                padding: 15,
                width: 200.w,
                color: AppColors.black,
                press: () {}),
          SizedBox(height: 20.h),
        ],
      ),
    );
  }
}

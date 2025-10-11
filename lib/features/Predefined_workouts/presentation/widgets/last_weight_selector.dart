import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Workouts/data/data_sources/workout_item_weights.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/weight_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class LastWeightSelector extends ConsumerStatefulWidget {
  final WorkoutItemModel workoutExercise;
  final int workoutID;
  const LastWeightSelector(
      {super.key, required this.workoutExercise, required this.workoutID});

  @override
  LastWeightSelectorState createState() => LastWeightSelectorState();
}

class LastWeightSelectorState extends ConsumerState<LastWeightSelector> {
  late num selectedWeight;

  @override
  void initState() {
    super.initState();
    selectedWeight = widget.workoutExercise.lastWeight;
  }

  void updateWeight(num weight) {
    setState(() {
      selectedWeight = weight;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Text(
              "Last Weight for : ${widget.workoutExercise.exercise.name}",
              style: TextStyle(
                fontFamily: "poppins",
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
              ),
            ),
          ),
        ),
        Expanded(
          child: ListView(
            scrollDirection: Axis.vertical,
            shrinkWrap: true,
            children: widget.workoutExercise.exercise.equipmentType == "machine"
                ? MachineWeights.values
                    .map((e) => WeightChip(
                          weight: e.weight,
                          type: e,
                          lastWeight: selectedWeight,
                          onWeightSelected: updateWeight,
                        ))
                    .toList()
                : FreeWeights.values
                    .map((e) => WeightChip(
                          weight: e.weight,
                          type: e,
                          lastWeight: selectedWeight,
                          onWeightSelected: updateWeight,
                        ))
                    .toList(),
          ),
        ),
        CustomBTN(
          widget: Text("Update"),
          padding: 10,
          width: 150.w,
          radius: 8,
          color: Colors.deepPurpleAccent,
          press: () {
            ref.read(workoutsProvider.notifier).updateLastWeight(
                widget.workoutID,
                widget.workoutExercise.exercise.id,
                selectedWeight);
            Navigator.pop(context, selectedWeight);
          },
        ),
      ],
    );
  }
}

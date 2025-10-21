import 'package:Warrior/core/constants/colors.dart';
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
  final TextEditingController _customWeightController = TextEditingController();
  final FocusNode _customWeightFocusNode = FocusNode();
  bool _isCustomWeightSelected = false;

  @override
  void initState() {
    super.initState();
    selectedWeight = widget.workoutExercise.lastWeight;
  }

  @override
  void dispose() {
    _customWeightController.dispose();
    _customWeightFocusNode.dispose();
    super.dispose();
  }

  void updateWeight(num weight) {
    setState(() {
      selectedWeight = weight;
      _isCustomWeightSelected = false;
      _customWeightController.clear();
    });
  }

  void selectCustomWeight() {
    setState(() {
      _isCustomWeightSelected = true;
    });
    // // Delay focus request to ensure keyboard animation completes
    // Future.delayed(const Duration(seconds: 10), () {
    //   if (mounted) {
    //     _customWeightFocusNode.requestFocus();
    //   }
    // });
  }

  void updateCustomWeight(String value) {
    final weight = num.tryParse(value);
    if (weight != null && weight > 0) {
      setState(() {
        selectedWeight = weight;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
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
              children: [
                ...(widget.workoutExercise.exercise.equipmentType == "machine"
                    ? MachineWeights.values
                        .map((e) => WeightChip(
                              weight: e.weight,
                              type: e,
                              lastWeight:
                                  _isCustomWeightSelected ? -1 : selectedWeight,
                              onWeightSelected: updateWeight,
                            ))
                        .toList()
                    : FreeWeights.values
                        .map((e) => WeightChip(
                              weight: e.weight,
                              type: e,
                              lastWeight:
                                  _isCustomWeightSelected ? -1 : selectedWeight,
                              onWeightSelected: updateWeight,
                            ))
                        .toList()),
                // Custom weight input
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Divider(),
                      SizedBox(height: 8.h),
                      Text(
                        "Or Enter Custom Weight:",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 13.sp,
                        ),
                      ),
                      SizedBox(height: 8.h),
                      TextField(
                        controller: _customWeightController,
                        focusNode: _customWeightFocusNode,
                        keyboardType: const TextInputType.numberWithOptions(
                            decimal: true),
                        onTap: selectCustomWeight,
                        onChanged: updateCustomWeight,
                        decoration: InputDecoration(
                          hintText: "Enter Weight",
                          suffixText:
                              widget.workoutExercise.exercise.equipmentType ==
                                      "machine"
                                  ? "Bar"
                                  : "KG",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: _isCustomWeightSelected
                                  ? Colors.deepPurpleAccent
                                  : Colors.grey.shade300,
                              width: _isCustomWeightSelected ? 2 : 1,
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide(
                              color: Colors.lightBlue,
                              width: 2,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                        ),
                      ),
                      SizedBox(height: 16.h),
                    ],
                  ),
                ),
              ],
            ),
          ),
          CustomBTN(
            widget: const Text("Update"),
            padding: 10,
            width: 150.w,
            radius: 8,
            color: AppColors.primaryColor,
            press: () {
              ref.read(workoutsProvider.notifier).updateLastWeight(
                  widget.workoutID,
                  widget.workoutExercise.exercise.id,
                  selectedWeight);
              Navigator.pop(context, selectedWeight);
            },
          ),
        ],
      ),
    );
  }
}

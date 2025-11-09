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
  const LastWeightSelector({
    super.key,
    required this.workoutExercise,
    required this.workoutID,
  });

  @override
  LastWeightSelectorState createState() => LastWeightSelectorState();
}

class LastWeightSelectorState extends ConsumerState<LastWeightSelector>
    with SingleTickerProviderStateMixin {
  late num selectedWeight;
  late final TextEditingController _customWeightController;
  late final FocusNode _customWeightFocusNode;
  late final AnimationController _animationController;
  late final Animation<double> _fadeAnimation;
  bool _isCustomWeightSelected = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final isDark = theme.brightness == Brightness.dark;
    final equipmentType = widget.workoutExercise.exercise.equipmentType;
    final isMachine = equipmentType == "machine";
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      height: keyboardHeight > 0
          ? MediaQuery.of(context).size.height * 0.9
          : MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: isDark
              ? [
                  colorScheme.surface,
                  colorScheme.surface.withOpacity(0.95),
                ]
              : [
                  Colors.white,
                  Colors.grey.shade50,
                ],
        ),
      ),
      child: Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, isDark, colorScheme),
              Expanded(
                child: _buildWeightList(isMachine),
              ),
              _buildCustomWeightSection(
                  context, isDark, colorScheme, isMachine),
              _buildActionButton(context, colorScheme),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _customWeightController.dispose();
    _customWeightFocusNode.dispose();
    _animationController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    selectedWeight = widget.workoutExercise.lastWeight;
    _customWeightController = TextEditingController();
    _customWeightFocusNode = FocusNode();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );

    _animationController.forward();
  }

  void selectCustomWeight() {
    setState(() {
      _isCustomWeightSelected = true;
    });
  }

  void updateCustomWeight(String value) {
    final weight = num.tryParse(value);
    if (weight != null && weight > 0) {
      setState(() {
        selectedWeight = weight;
      });
    }
  }

  void updateWeight(num weight) {
    setState(() {
      selectedWeight = weight;
      _isCustomWeightSelected = false;
      _customWeightController.clear();
    });
  }

  Widget _buildActionButton(BuildContext context, ColorScheme colorScheme) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: CustomBTN(
        widget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20.sp,
            ),
            SizedBox(width: 8.w),
            Text(
              "Update Weight",
              style: TextStyle(
                fontFamily: "poppins",
                fontWeight: FontWeight.bold,
                fontSize: 15.sp,
                color: Colors.white,
                letterSpacing: 0.5,
              ),
            ),
          ],
        ),
        padding: 14,
        width: double.infinity,
        radius: 12,
        color: AppColors.primaryColor,
        press: () {
          ref.read(workoutsProvider.notifier).updateLastWeight(
                widget.workoutID,
                widget.workoutExercise.exercise.id,
                selectedWeight,
              );
          Navigator.pop(context, selectedWeight);
        },
      ),
    );
  }

  Widget _buildCurrentWeightIndicator() {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.history_rounded,
            color: Colors.white,
            size: 16.sp,
          ),
          SizedBox(width: 6.w),
          Text(
            "Last: ${widget.workoutExercise.lastWeight} ${widget.workoutExercise.exercise.equipmentType == "machine" ? "Bar" : "KG"}",
            style: TextStyle(
              fontFamily: "poppins",
              fontWeight: FontWeight.w600,
              fontSize: 12.sp,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomWeightSection(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
    bool isMachine,
  ) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16.w, vertical: 5.h),
      padding: EdgeInsets.all(8.w),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: _isCustomWeightSelected
              ? AppColors.primaryColor!.withOpacity(0.5)
              : Colors.grey.shade200,
          width: _isCustomWeightSelected ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: _isCustomWeightSelected
                ? AppColors.primaryColor!.withOpacity(0.15)
                : Colors.black.withOpacity(0.05),
            blurRadius: _isCustomWeightSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.edit_rounded,
                  color: AppColors.primaryColor,
                  size: 18.sp,
                ),
              ),
              SizedBox(width: 10.w),
              Text(
                "Custom Weight",
                style: TextStyle(
                  fontFamily: "poppins",
                  fontWeight: FontWeight.w700,
                  fontSize: 14.sp,
                  color: isDark ? Colors.white : Colors.grey.shade800,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          SizedBox(height: 12.h),
          TextField(
            controller: _customWeightController,
            focusNode: _customWeightFocusNode,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            onTap: selectCustomWeight,
            onChanged: updateCustomWeight,
            style: TextStyle(
              fontFamily: "poppins",
              fontWeight: FontWeight.w600,
              fontSize: 16.sp,
            ),
            decoration: InputDecoration(
              hintText: "Enter weight value",
              hintStyle: TextStyle(
                fontFamily: "poppins",
                fontSize: 14.sp,
                color: Colors.grey.shade400,
              ),
              suffixIcon: Container(
                margin: const EdgeInsets.all(8),
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor!.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  isMachine ? "Bar" : "KG",
                  style: TextStyle(
                    fontFamily: "poppins",
                    fontWeight: FontWeight.bold,
                    fontSize: 13.sp,
                    color: AppColors.primaryColor,
                  ),
                ),
              ),
              filled: true,
              fillColor: isDark
                  ? Colors.grey.shade800.withOpacity(0.3)
                  : Colors.grey.shade50,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: _isCustomWeightSelected
                      ? AppColors.primaryColor!.withOpacity(0.3)
                      : Colors.transparent,
                  width: 1,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide(
                  color: AppColors.primaryColor!,
                  width: 2,
                ),
              ),
              contentPadding: EdgeInsets.symmetric(
                horizontal: 16.w,
                vertical: 14.h,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    bool isDark,
    ColorScheme colorScheme,
  ) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor!,
            AppColors.primaryColor!.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor!.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.fitness_center_rounded,
                    color: Colors.white,
                    size: 24.sp,
                  ),
                ),
                SizedBox(width: 12.w),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Select Weight",
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontWeight: FontWeight.w600,
                          fontSize: 12.sp,
                          color: Colors.white.withOpacity(0.9),
                          letterSpacing: 0.5,
                        ),
                      ),
                      SizedBox(height: 2.h),
                      Text(
                        widget.workoutExercise.exercise.name,
                        style: TextStyle(
                          fontFamily: "poppins",
                          fontWeight: FontWeight.bold,
                          fontSize: 16.sp,
                          color: Colors.white,
                          letterSpacing: 0.3,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          _buildCurrentWeightIndicator(),
        ],
      ),
    );
  }

  Widget _buildWeightList(bool isMachine) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      itemCount:
          isMachine ? MachineWeights.values.length : FreeWeights.values.length,
      itemBuilder: (context, index) {
        final weight = isMachine
            ? MachineWeights.values[index]
            : FreeWeights.values[index];

        return Padding(
          padding: EdgeInsets.only(bottom: 8.h),
          child: WeightChip(
            weight: isMachine
                ? (weight as MachineWeights).weight
                : (weight as FreeWeights).weight,
            type: weight,
            lastWeight: _isCustomWeightSelected ? -1 : selectedWeight,
            onWeightSelected: updateWeight,
          ),
        );
      },
    );
  }
}

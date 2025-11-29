import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Workouts/data/data_sources/workout_item_weights.dart';
import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
import 'package:Warrior/features/Workouts/presentation/widgets/weight_chip.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

const double _maxWeightValue = 999;

class LastWeightSelector extends ConsumerStatefulWidget {
  final WorkoutItemModel workoutExercise;
  final WorkoutSetModel workout;

  const LastWeightSelector(
      {super.key, required this.workoutExercise, required this.workout});

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
  String? _validationError;

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
              _WeightSelectorHeader(
                exerciseName: widget.workoutExercise.exercise.name,
                lastWeight: widget.workoutExercise.lastWeight,
                equipmentType: equipmentType ?? "free",
              ),
              Expanded(
                child: _WeightList(
                  isMachine: isMachine,
                  selectedWeight: _isCustomWeightSelected ? -1 : selectedWeight,
                  onWeightSelected: _updateWeight,
                ),
              ),
              _CustomWeightInput(
                controller: _customWeightController,
                focusNode: _customWeightFocusNode,
                isMachine: isMachine,
                isDark: isDark,
                isSelected: _isCustomWeightSelected,
                validationError: _validationError,
                onTap: _selectCustomWeight,
                onChanged: _updateCustomWeight,
              ),
              _UpdateWeightButton(
                onPressed: _handleUpdateWeight,
              ),
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

  void _handleUpdateWeight() {
    // Validate before updating
    if (_validationError != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_validationError!),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    ref.read(workoutsProvider.notifier).updateLastWeight(
          widget.workout.id,
          widget.workoutExercise.exercise.id,
          selectedWeight,
          workout: widget.workout,
        );
    Navigator.pop(context, selectedWeight);
  }

  void _selectCustomWeight() {
    setState(() {
      _isCustomWeightSelected = true;
    });
  }

  void _updateCustomWeight(String value) {
    final weight = num.tryParse(value);

    if (weight == null || value.isEmpty) {
      setState(() {
        _validationError = null;
      });
      return;
    }

    if (weight <= 0) {
      setState(() {
        _validationError = 'Weight must be greater than 0';
      });
      return;
    }

    if (weight > _maxWeightValue) {
      setState(() {
        _validationError = 'Weight cannot exceed $_maxWeightValue';
      });
      return;
    }

    setState(() {
      selectedWeight = weight;
      _validationError = null;
    });
  }

  void _updateWeight(num weight) {
    setState(() {
      selectedWeight = weight;
      _isCustomWeightSelected = false;
      _customWeightController.clear();
      _validationError = null;
    });
  }
}

/// Badge showing the current/last weight
class _CurrentWeightIndicator extends ConsumerWidget {
  final num lastWeight;
  final String equipmentType;

  const _CurrentWeightIndicator({
    required this.lastWeight,
    required this.equipmentType,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
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
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            "${context.l10n.lastWeight} $lastWeight ${equipmentType == "machine" ? context.l10n.bar : context.l10n.kg}",
            style: TextStyle(
              fontFamily: appSettings.fontFamily(),
              fontWeight: FontWeight.w600,
              fontSize: 12,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }
}

/// Header for custom weight section
class _CustomWeightHeader extends ConsumerWidget {
  final bool isDark;

  const _CustomWeightHeader({required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider.notifier);
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.edit_rounded,
            color: AppColors.primaryColor,
            size: 18,
          ),
        ),
        const SizedBox(width: 10),
        Text(
          context.l10n.customWeight,
          style: TextStyle(
            fontFamily: appSettings.fontFamily(),
            fontWeight: FontWeight.w900,
            fontSize: 15,
            color: isDark ? Colors.white : Colors.grey.shade800,
            letterSpacing: 0.3,
          ),
        ),
      ],
    );
  }
}

/// Custom weight input field
class _CustomWeightInput extends StatelessWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isMachine;
  final bool isDark;
  final bool isSelected;
  final String? validationError;
  final VoidCallback onTap;
  final void Function(String) onChanged;

  const _CustomWeightInput({
    required this.controller,
    required this.focusNode,
    required this.isMachine,
    required this.isDark,
    required this.isSelected,
    required this.validationError,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surface : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: validationError != null
              ? Colors.red
              : isSelected
                  ? AppColors.primaryColor.withOpacity(0.5)
                  : Colors.grey.shade200,
          width: isSelected || validationError != null ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: validationError != null
                ? Colors.red.withOpacity(0.15)
                : isSelected
                    ? AppColors.primaryColor.withOpacity(0.15)
                    : Colors.black.withOpacity(0.05),
            blurRadius: isSelected ? 12 : 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _CustomWeightHeader(isDark: isDark),
          const SizedBox(height: 12),
          _CustomWeightTextField(
            controller: controller,
            focusNode: focusNode,
            isMachine: isMachine,
            isDark: isDark,
            isSelected: isSelected,
            hasError: validationError != null,
            onTap: onTap,
            onChanged: onChanged,
          ),
          if (validationError != null) ...[
            const SizedBox(height: 8),
            _ValidationErrorText(error: validationError!),
          ],
        ],
      ),
    );
  }
}

/// Text field for custom weight input
class _CustomWeightTextField extends ConsumerWidget {
  final TextEditingController controller;
  final FocusNode focusNode;
  final bool isMachine;
  final bool isDark;
  final bool isSelected;
  final bool hasError;
  final VoidCallback onTap;
  final void Function(String) onChanged;

  const _CustomWeightTextField({
    required this.controller,
    required this.focusNode,
    required this.isMachine,
    required this.isDark,
    required this.isSelected,
    required this.hasError,
    required this.onTap,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return TextField(
      controller: controller,
      focusNode: focusNode,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
      ],
      onTap: onTap,
      onChanged: onChanged,
      style: TextStyle(
        fontFamily: "poppins",
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      decoration: InputDecoration(
        hintText: context.l10n.enterWeightValue,
        hintStyle: TextStyle(
          fontFamily: appSettings.fontFamily(),
          fontSize: 12,
          color: Colors.grey.shade400,
        ),
        suffixIcon: _WeightUnitBadge(isMachine: isMachine),
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
            color: hasError
                ? Colors.red.withOpacity(0.3)
                : isSelected
                    ? AppColors.primaryColor.withOpacity(0.3)
                    : Colors.transparent,
            width: 1,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: hasError ? Colors.red : AppColors.primaryColor,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(
            color: Colors.red,
            width: 2,
          ),
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
      ),
    );
  }
}

/// Icon displayed in the header
class _HeaderIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        Icons.fitness_center_rounded,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}

/// Title section in the header
class _HeaderTitle extends ConsumerWidget {
  final String exerciseName;

  const _HeaderTitle({required this.exerciseName});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          context.l10n.selectWeight,
          style: TextStyle(
            fontFamily: appSettings.fontFamily(),
            fontWeight: FontWeight.w600,
            fontSize: 12,
            color: Colors.white.withOpacity(0.9),
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          exerciseName,
          style: TextStyle(
            fontFamily: appSettings.fontFamily(),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
            letterSpacing: 0.3,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}

/// Update weight button at the bottom
class _UpdateWeightButton extends ConsumerWidget {
  final VoidCallback onPressed;

  const _UpdateWeightButton({required this.onPressed});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colorScheme = Theme.of(context).colorScheme;
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
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
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              context.l10n.updateWeight,
              style: TextStyle(
                fontFamily: appSettings.fontFamily(),
                fontWeight: FontWeight.bold,
                fontSize: 15,
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
        press: onPressed,
      ),
    );
  }
}

/// Validation error message text
class _ValidationErrorText extends StatelessWidget {
  final String error;

  const _ValidationErrorText({required this.error});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 16,
        ),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            error,
            style: TextStyle(
              fontFamily: "poppins",
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

/// List of predefined weights
class _WeightList extends StatelessWidget {
  final bool isMachine;
  final num selectedWeight;
  final void Function(num) onWeightSelected;

  const _WeightList({
    required this.isMachine,
    required this.selectedWeight,
    required this.onWeightSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount:
          isMachine ? MachineWeights.values.length : FreeWeights.values.length,
      itemBuilder: (context, index) {
        final weight = isMachine
            ? MachineWeights.values[index]
            : FreeWeights.values[index];

        return Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: WeightChip(
            weight: isMachine
                ? (weight as MachineWeights).weight
                : (weight as FreeWeights).weight,
            type: weight,
            lastWeight: selectedWeight,
            onWeightSelected: onWeightSelected,
          ),
        );
      },
    );
  }
}

/// Header widget showing exercise name and last weight
class _WeightSelectorHeader extends StatelessWidget {
  final String exerciseName;
  final num lastWeight;
  final String equipmentType;

  const _WeightSelectorHeader({
    required this.exerciseName,
    required this.lastWeight,
    required this.equipmentType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primaryColor,
            AppColors.primaryColor.withOpacity(0.8),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryColor.withOpacity(0.3),
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
                _HeaderIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: _HeaderTitle(exerciseName: exerciseName),
                ),
              ],
            ),
          ),
          _CurrentWeightIndicator(
            lastWeight: lastWeight,
            equipmentType: equipmentType,
          ),
        ],
      ),
    );
  }
}

/// Badge showing the weight unit (KG or Bar)
class _WeightUnitBadge extends ConsumerWidget {
  final bool isMachine;

  const _WeightUnitBadge({required this.isMachine});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        isMachine ? context.l10n.bar : context.l10n.kg,
        style: TextStyle(
          fontFamily: appSettings.fontFamily(),
          fontWeight: FontWeight.bold,
          fontSize: 13,
          color: AppColors.primaryColor,
        ),
      ),
    );
  }
}

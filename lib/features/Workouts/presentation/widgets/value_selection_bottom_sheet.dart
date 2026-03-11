import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Workouts/data/data_sources/workout_item_weights.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ValueSelectionBottomSheet extends ConsumerStatefulWidget {
  final ValueSelectionMode mode;
  final num currentValue;
  final String title;
  final String? subtitle;
  final bool isMachine; // Only relevant for weight mode
  final Color? primaryColor; // distinct color for this sheet
  final String? tooltipMessage; // Dynamic message for the help tooltip

  const ValueSelectionBottomSheet({
    super.key,
    required this.mode,
    required this.currentValue,
    required this.title,
    this.subtitle,
    this.isMachine = false,
    this.primaryColor,
    this.tooltipMessage,
  });

  @override
  ConsumerState<ValueSelectionBottomSheet> createState() =>
      _ValueSelectionBottomSheetState();
}

enum ValueSelectionMode {
  weight,
  reps,
}

class _ValueChip extends StatelessWidget {
  final String value;
  final bool isSelected;
  final Color primaryColor;
  final VoidCallback onTap;

  const _ValueChip({
    required this.value,
    required this.isSelected,
    required this.primaryColor,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isSelected
              ? primaryColor
              : (isDark
                  ? Colors.white.withOpacity(0.08)
                  : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? primaryColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: primaryColor.withOpacity(0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ]
              : [],
        ),
        child: Text(
          value,
          style: TextStyle(
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.white70 : Colors.black87),
            fontWeight: FontWeight.bold,
            fontSize: 16,
            fontFamily: "Poppins",
          ),
        ),
      ),
    );
  }
}

class _ValueSelectionBottomSheetState
    extends ConsumerState<ValueSelectionBottomSheet>
    with SingleTickerProviderStateMixin {
  // Constants
  static const double _maxWeightValue = 999;
  static const double _maxRepsValue = 500; // Reasonable cap for reps
  late num _selectedValue;
  late final TextEditingController _customValueController;
  late final FocusNode _customValueFocusNode;

  bool _isCustomValueSelected = false;
  String? _validationError;

  Color get _primaryColor => widget.primaryColor ?? AppColors.primaryColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final keyboardHeight = MediaQuery.of(context).viewInsets.bottom;
    final double cornerRadius = 8;

    // Dynamic height calculation
    final height = keyboardHeight > 0
        ? MediaQuery.of(context).size.height * 1
        : MediaQuery.of(context).size.height * 0.7;

    return Container(
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(cornerRadius),
          topRight: Radius.circular(cornerRadius),
        ),
        color: isDark ? theme.colorScheme.surface : Colors.white,
      ),
      child: Column(
        children: [
          _buildHeader(context, isDark, cornerRadius),
          Expanded(
            child: SingleChildScrollView(
              physics: keyboardHeight > 0
                  ? AlwaysScrollableScrollPhysics()
                  : NeverScrollableScrollPhysics(),
              padding: EdgeInsets.only(bottom: keyboardHeight + 20),
              child: Column(
                children: [
                  _buildGrid(context),
                  const SizedBox(height: 16),
                  _buildCustomInput(context, isDark),
                  const SizedBox(height: 24),
                  _buildUpdateButton(context),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _customValueController.dispose();
    _customValueFocusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _selectedValue = widget.currentValue;
    _customValueController = TextEditingController();
    _customValueFocusNode = FocusNode();

    // If current value is not in predefined list, treat as custom
    if (!_isPredefined(widget.currentValue)) {
      _isCustomValueSelected = true;
      _customValueController.text = _formatValue(widget.currentValue);
    }
  }

  Widget _buildCurrentValueBadge(BuildContext context, dynamic appSettings) {
    final unit = widget.mode == ValueSelectionMode.weight
        ? (widget.isMachine ? context.l10n.bar : context.l10n.kg)
        : context.l10n.reps;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatValue(_selectedValue),
            style: TextStyle(
              fontFamily: "Poppins", // Numbers look better in Poppins
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            unit,
            style: TextStyle(
              fontFamily: appSettings.fontFamily(),
              fontSize: 12,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCustomInput(BuildContext context, bool isDark) {
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.mode == ValueSelectionMode.weight
                ? context.l10n.customWeight
                : context.l10n.customReps,
            style: TextStyle(
              fontFamily: appSettings.fontFamily(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
              color: isDark ? Colors.white : Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.grey.shade100,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: _isCustomValueSelected
                    ? _primaryColor
                    : (_validationError != null
                        ? Colors.red
                        : Colors.transparent),
                width: 2,
              ),
            ),
            child: TextField(
              controller: _customValueController,
              focusNode: _customValueFocusNode,
              keyboardType:
                  const TextInputType.numberWithOptions(decimal: true),
              onTap: _onCustomValueSelected,
              onChanged: _onCustomValueChanged,
              style: const TextStyle(
                fontFamily: "Poppins",
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              inputFormatters: [
                if (widget.mode == ValueSelectionMode.reps)
                  FilteringTextInputFormatter.digitsOnly
                else
                  FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d{0,2}')),
              ],
              decoration: InputDecoration(
                hintText: context.l10n.enterWeightValue, // Helper text
                hintStyle: TextStyle(
                  color: isDark ? Colors.white30 : Colors.black26,
                  fontSize: 14,
                  fontWeight: FontWeight.normal,
                  fontFamily: appSettings.fontFamily(),
                ),
                contentPadding: const EdgeInsets.all(16),
                border: InputBorder.none,
                suffixIcon: Container(
                  margin: const EdgeInsets.all(8),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: _primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    widget.mode == ValueSelectionMode.weight
                        ? (widget.isMachine
                            ? context.l10n.bar
                            : context.l10n.kg)
                        : context.l10n.reps,
                    style: TextStyle(
                      color: _primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ),
          if (_validationError != null)
            Padding(
              padding: const EdgeInsets.only(top: 8, left: 4),
              child: Text(
                _validationError!,
                style: const TextStyle(
                  color: Colors.red,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildGrid(BuildContext context) {
    if (widget.mode == ValueSelectionMode.weight) {
      return _buildWeightGrid(context);
    } else {
      return _buildRepsGrid(context);
    }
  }

  Widget _buildHeader(BuildContext context, bool isDark, double cornerRadius) {
    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Stack(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24)
              .copyWith(top: 20, bottom: 30),
          decoration: BoxDecoration(
            color: _primaryColor,
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(cornerRadius),
              topRight: Radius.circular(cornerRadius),
            ),
            boxShadow: [
              BoxShadow(
                color: _primaryColor.withOpacity(0.3),
                blurRadius: 15,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  widget.mode == ValueSelectionMode.weight
                      ? Icons.fitness_center_rounded
                      : Icons.refresh_rounded,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.title,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: appSettings.fontFamily(),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        overflow: TextOverflow.ellipsis,
                        color: Colors.white,
                      ),
                    ),
                    if (widget.subtitle != null)
                      Text(
                        widget.subtitle!,
                        style: TextStyle(
                          fontFamily: appSettings.fontFamily(),
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.9),
                        ),
                      ),
                  ],
                ),
              ),
              _buildCurrentValueBadge(context, appSettings),
            ],
          ),
        ),
        if (widget.tooltipMessage != null)
          Positioned(
            bottom: 6,
            left: 10,
            child: Tooltip(
              message: widget.tooltipMessage!,
              triggerMode: TooltipTriggerMode.tap,
              preferBelow: false,
              showDuration: Duration(seconds: 2),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              margin: const EdgeInsets.symmetric(horizontal: 24),
              decoration: BoxDecoration(
                color: isDark ? Colors.grey[850] : Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              textStyle: TextStyle(
                color: isDark ? Colors.white : Colors.black87,
                fontSize: 13,
                fontFamily: appSettings.fontFamily(),
                fontWeight: FontWeight.w500,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white.withOpacity(0.4)),
                ),
                child: const Icon(
                  Icons.question_mark_rounded,
                  color: Colors.white,
                  size: 14,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildRepsGrid(BuildContext context) {
    // Generate 1 to 20
    final values = List.generate(20, (index) => index + 1);

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 5,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final val = values[index];
        final isSelected = !_isCustomValueSelected && val == _selectedValue;

        return _ValueChip(
          value: val.toString(),
          isSelected: isSelected,
          primaryColor: _primaryColor,
          onTap: () => _onPredefinedValueSelected(val),
        );
      },
    );
  }

  Widget _buildUpdateButton(BuildContext context) {
    final isSameValue = _selectedValue == widget.currentValue;
    // We allow update even if same? User requirement: "Disable the confirm/update button if the selected value equals the current value."
    final isDisabled = isSameValue || _validationError != null;

    final appSettings = ref.watch(appSettingsProvider.notifier);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: CustomBTN(
        widget: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.check_circle_rounded,
              color: isDisabled ? Colors.white54 : Colors.white,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              _getButtonText(context),
              style: TextStyle(
                fontFamily: appSettings.fontFamily(),
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDisabled ? Colors.white54 : Colors.white,
              ),
            ),
          ],
        ),
        color: isDisabled ? Colors.grey : _primaryColor,
        padding: 16,
        radius: 16,
        width: double.infinity,
        press: isDisabled ? () {} : _handleUpdate,
      ),
    );
  }

  Widget _buildWeightGrid(BuildContext context) {
    final values = widget.isMachine
        ? MachineWeights.values.map((e) => e.weight.toDouble()).toList()
        : FreeWeights.values.map((e) => e.weight).toList();

    // We can reuse WeightChip or build a generic one.
    // WeightChip seems specific to LastWeightSelector's styling but we can reuse it if it fits.
    // Actually, let's build a grid for better layout than a list.

    return GridView.builder(
      padding: const EdgeInsets.all(20),
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 4,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 1.6,
      ),
      itemCount: values.length,
      itemBuilder: (context, index) {
        final val = values[index];
        final isSelected = !_isCustomValueSelected && val == _selectedValue;

        return _ValueChip(
          value: _formatValue(val),
          isSelected: isSelected,
          primaryColor: _primaryColor,
          onTap: () => _onPredefinedValueSelected(val),
        );
      },
    );
  }

  String _formatValue(num value) {
    return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 2);
  }

  String _getButtonText(BuildContext context) {
    return widget.mode == ValueSelectionMode.weight
        ? context.l10n.updateWeight
        : context.l10n.updateReps;
  }

  void _handleUpdate() {
    if (_validationError != null) return;
    Navigator.pop(context, _selectedValue);
  }

  bool _isPredefined(num value) {
    if (widget.mode == ValueSelectionMode.weight) {
      if (widget.isMachine) {
        return MachineWeights.values.any((e) => e.weight == value);
      } else {
        return FreeWeights.values.any((e) => e.weight == value);
      }
    } else {
      // Reps 1-20 are predefined
      return value >= 1 && value <= 20 && value % 1 == 0;
    }
  }

  void _onCustomValueChanged(String value) {
    final parsed = num.tryParse(value);

    if (parsed == null || value.isEmpty) {
      setState(() {
        _validationError = null;
        // Keep selected value as is or handle empty state?
        // We'll just not update _selectedValue to invalid, but we need to block update.
        // Actually showing error is better if empty? No, just ignore.
      });
      return;
    }

    final max = widget.mode == ValueSelectionMode.weight
        ? _maxWeightValue
        : _maxRepsValue;

    if (parsed < 0) {
      // Allow 0? usually > 0
      setState(() {
        _validationError =
            '${widget.mode == ValueSelectionMode.weight ? "Weight" : "Reps"} must be >= 0';
      });
      return;
    }

    if (parsed > max) {
      setState(() {
        _validationError = 'Max value is $max';
      });
      return;
    }

    setState(() {
      _selectedValue = parsed;
      _validationError = null;
    });
  }

  void _onCustomValueSelected() {
    setState(() {
      _isCustomValueSelected = true;
    });
    // Don't focus immediately to avoid jumpting keyboard on mobile unless intended
    // _customValueFocusNode.requestFocus();
  }

  void _onPredefinedValueSelected(num value) {
    setState(() {
      _selectedValue = value;
      _isCustomValueSelected = false;
      _customValueController.clear();
      _validationError = null;
    });
  }
}

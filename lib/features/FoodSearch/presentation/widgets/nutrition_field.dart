import 'package:Warrior/features/FoodSearch/presentation/widgets/confidence_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Nutrition input field with confidence indicator.
class NutritionField extends StatefulWidget {
  final NutritionFieldData data;
  final ValueChanged<double?>? onChanged;
  final bool readOnly;

  const NutritionField({
    super.key,
    required this.data,
    this.onChanged,
    this.readOnly = false,
  });

  @override
  State<NutritionField> createState() => _NutritionFieldState();
}

/// Data for a single nutrition field.
class NutritionFieldData {
  final String key;
  final String label;
  final String unit;
  final double? value;
  final double confidence;
  final IconData? icon;

  const NutritionFieldData({
    required this.key,
    required this.label,
    required this.unit,
    this.value,
    this.confidence = 0.0,
    this.icon,
  });

  bool get hasValue => value != null;
  bool get isLowConfidence => confidence > 0 && confidence < 0.7;
}

/// Factory for creating common nutrition field data.
class NutritionFields {
  static NutritionFieldData carbohydrates(
          {double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'carbohydrates100g',
        label: 'Carbohydrates',
        unit: 'g',
        value: value,
        confidence: confidence,
        icon: Icons.grain_rounded,
      );

  static NutritionFieldData energy({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'energyKcal100g',
        label: 'Energy',
        unit: 'kcal',
        value: value,
        confidence: confidence,
        icon: Icons.local_fire_department_rounded,
      );

  static NutritionFieldData fat({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'fat100g',
        label: 'Fat',
        unit: 'g',
        value: value,
        confidence: confidence,
        icon: Icons.opacity_rounded,
      );

  static NutritionFieldData fiber({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'fiber100g',
        label: 'Fiber',
        unit: 'g',
        value: value,
        confidence: confidence,
        icon: Icons.grass_rounded,
      );

  static NutritionFieldData proteins({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'proteins100g',
        label: 'Proteins',
        unit: 'g',
        value: value,
        confidence: confidence,
        icon: Icons.fitness_center_rounded,
      );

  static NutritionFieldData salt({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'salt100g',
        label: 'Salt',
        unit: 'g',
        value: value,
        confidence: confidence,
      );

  static NutritionFieldData saturatedFat(
          {double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'saturatedFat100g',
        label: 'Saturated Fat',
        unit: 'g',
        value: value,
        confidence: confidence,
      );

  static NutritionFieldData sodium({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'sodium100g',
        label: 'Sodium',
        unit: 'g',
        value: value,
        confidence: confidence,
      );

  static NutritionFieldData sugars({double? value, double confidence = 0}) =>
      NutritionFieldData(
        key: 'sugars100g',
        label: 'Sugars',
        unit: 'g',
        value: value,
        confidence: confidence,
      );
}

class _NutritionFieldState extends State<NutritionField> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  bool _isFocused = false;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isLow = widget.data.isLowConfidence;
    final hasConfidence = widget.data.confidence > 0;

    return TextFormField(
      controller: _controller,
      focusNode: _focusNode,
      readOnly: widget.readOnly,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'^\d*\.?\d*')),
      ],
      onChanged: _onTextChanged,
      style: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: colorScheme.onSurface,
      ),
      decoration: InputDecoration(
        labelText: widget.data.label,
        labelStyle: TextStyle(
          color: isLow ? Colors.orange : colorScheme.onSurfaceVariant,
        ),
        suffixText: widget.data.unit,
        suffixStyle: TextStyle(
          color: colorScheme.onSurfaceVariant,
          fontSize: 14,
        ),
        prefixIcon: widget.data.icon != null
            ? Icon(widget.data.icon,
                size: 20, color: isLow ? Colors.orange : null)
            : (isLow
                ? const Icon(Icons.warning_amber_rounded,
                    size: 20, color: Colors.orange)
                : null),
        suffixIcon: hasConfidence
            ? Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ConfidenceIndicator(
                  confidence: widget.data.confidence,
                  size: 20,
                ),
              )
            : null,
        filled: true,
        fillColor: _isFocused
            ? colorScheme.primaryContainer.withValues(alpha: 0.3)
            : colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(
            color: isLow
                ? Colors.orange.withValues(alpha: 0.5)
                : colorScheme.outline.withValues(alpha: 0.2),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: colorScheme.primary, width: 2),
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        helperText: isLow ? 'Please verify this value' : null,
        helperStyle: const TextStyle(color: Colors.orange, fontSize: 11),
      ),
    );
  }

  @override
  void didUpdateWidget(NutritionField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data.value != oldWidget.data.value) {
      final newText = widget.data.value?.toString() ?? '';
      if (_controller.text != newText) {
        // Schedule controller update for after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _controller.text != newText) {
            _controller.text = newText;
          }
        });
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(
      text: widget.data.value?.toString() ?? '',
    );
    _focusNode = FocusNode()..addListener(_onFocusChange);
  }

  void _onFocusChange() {
    setState(() => _isFocused = _focusNode.hasFocus);
  }

  void _onTextChanged(String text) {
    widget.onChanged?.call(double.tryParse(text));
  }
}

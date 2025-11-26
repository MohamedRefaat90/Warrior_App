import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

/// Input card for weight, height, age fields
class InputCard extends StatelessWidget {
  final String label;
  final String hint;
  final String suffix;
  final TextEditingController controller;
  final String? Function(String?)? validator;

  const InputCard({
    super.key,
    required this.label,
    required this.hint,
    required this.suffix,
    required this.controller,
    this.validator,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: TextInputType.number,
        validator: validator,
        style: TextStyle(color: colorScheme.onSurface),
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          suffixText: suffix,
          labelStyle:
              TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.7)),
          hintStyle:
              TextStyle(color: colorScheme.onSurface.withValues(alpha: 0.5)),
          suffixStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: colorScheme.primary,
              ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(context.responsiveBorderRadius),
            borderSide: BorderSide(
              color: isDark ? AppColors.darkSecondary : AppColors.black,
              width: 1,
            ),
          ),
          filled: true,
          fillColor: colorScheme.surface,
          contentPadding: EdgeInsets.symmetric(
            horizontal: context.mediumSpacing,
            vertical: context.mediumSpacing,
          ),
        ),
      ),
    );
  }
}

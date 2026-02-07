import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/nutrition_state_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/confidence_indicator.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/nutrition_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Expandable section for nutrition facts input with OCR support.
class NutritionFactsBottomSheet extends ConsumerStatefulWidget {
  final ValueChanged<NutritionFacts?>? onChanged;
  final NutritionFacts? initialFacts;
  final VoidCallback? onScanPressed;

  const NutritionFactsBottomSheet({
    super.key,
    this.onChanged,
    this.initialFacts,
    this.onScanPressed,
  });

  @override
  ConsumerState<NutritionFactsBottomSheet> createState() =>
      _NutritionFactsBottomSheetState();
}

class _Content extends StatelessWidget {
  final NutritionState state;
  final VoidCallback onScan;
  final void Function(String key, double? value) onFieldChanged;
  final ValueChanged<String> onModeChanged;
  final VoidCallback onClearError;

  const _Content({
    required this.state,
    required this.onScan,
    required this.onFieldChanged,
    required this.onModeChanged,
    required this.onClearError,
  });

  @override
  Widget build(BuildContext context) {
    final facts = state.facts;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Controls row
          Row(
            children: [
              Expanded(
                child: _DataModeToggle(
                  mode: state.dataMode,
                  onChanged: onModeChanged,
                ),
              ),
              const SizedBox(width: 12),
              _ScanButton(onTap: onScan),
            ],
          ),
          const SizedBox(height: 16),

          // Fields grid
          _FieldsGrid(facts: facts, onFieldChanged: onFieldChanged),

          // Error
          if (state.error != null) ...[
            const SizedBox(height: 12),
            _ErrorMessage(error: state.error!, onDismiss: onClearError),
          ],
        ],
      ),
    );
  }
}

class _DataModeToggle extends StatelessWidget {
  final String mode;
  final ValueChanged<String> onChanged;

  const _DataModeToggle({required this.mode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      height: 40,
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          _ToggleOption(
            label: 'Per 100g',
            isSelected: mode == '100g',
            onTap: () => onChanged('100g'),
          ),
          _ToggleOption(
            label: 'Per Serving',
            isSelected: mode == 'serving',
            onTap: () => onChanged('serving'),
          ),
        ],
      ),
    );
  }
}

class _ErrorMessage extends StatelessWidget {
  final String error;
  final VoidCallback onDismiss;

  const _ErrorMessage({required this.error, required this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: colorScheme.error.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.error_outline_rounded,
            size: 18,
            color: colorScheme.error,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              error,
              style: TextStyle(
                fontSize: 12,
                color: colorScheme.onErrorContainer,
              ),
            ),
          ),
          IconButton(
            onPressed: onDismiss,
            icon: Icon(
              Icons.close_rounded,
              size: 18,
              color: colorScheme.onErrorContainer,
            ),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _FieldsGrid extends StatelessWidget {
  final NutritionFacts? facts;
  final void Function(String key, double? value) onFieldChanged;

  const _FieldsGrid({required this.facts, required this.onFieldChanged});

  @override
  Widget build(BuildContext context) {
    final fields = [
      NutritionFields.energy(
        value: facts?.energyKcal100g,
        confidence: facts?.getFieldConfidence('energy') ?? 0,
      ),
      NutritionFields.proteins(
        value: facts?.proteins100g,
        confidence: facts?.getFieldConfidence('proteins') ?? 0,
      ),
      NutritionFields.fat(
        value: facts?.fat100g,
        confidence: facts?.getFieldConfidence('fat') ?? 0,
      ),
      NutritionFields.saturatedFat(
        value: facts?.saturatedFat100g,
        confidence: facts?.getFieldConfidence('saturatedFat') ?? 0,
      ),
      NutritionFields.carbohydrates(
        value: facts?.carbohydrates100g,
        confidence: facts?.getFieldConfidence('carbohydrates') ?? 0,
      ),
      NutritionFields.sugars(
        value: facts?.sugars100g,
        confidence: facts?.getFieldConfidence('sugars') ?? 0,
      ),
      NutritionFields.fiber(
        value: facts?.fiber100g,
        confidence: facts?.getFieldConfidence('fiber') ?? 0,
      ),
      NutritionFields.sodium(
        value: facts?.sodium100g,
        confidence: facts?.getFieldConfidence('sodium') ?? 0,
      ),
      NutritionFields.salt(
        value: facts?.salt100g,
        confidence: facts?.getFieldConfidence('salt') ?? 0,
      ),
    ];

    return Column(
      children: [
        for (int i = 0; i < fields.length - 1; i += 2) ...[
          Row(
            children: [
              Expanded(
                child: NutritionField(
                  data: fields[i],
                  onChanged: (v) => onFieldChanged(fields[i].key, v),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: NutritionField(
                  data: fields[i + 1],
                  onChanged: (v) => onFieldChanged(fields[i + 1].key, v),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
        // Last field (salt) - full width
        NutritionField(
          data: fields.last,
          onChanged: (v) => onFieldChanged(fields.last.key, v),
        ),
      ],
    );
  }
}

class _Header extends StatelessWidget {
  final NutritionState state;
  final bool isExpanded;

  const _Header({
    required this.state,
    required this.isExpanded,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [colorScheme.primary, colorScheme.secondary],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.restaurant_menu_rounded,
              color: Colors.white,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Nutrition Facts',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                if (state.hasData)
                  Text(
                    '${state.fieldCount} fields • ${state.dataMode}',
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
              ],
            ),
          ),
          if (state.hasData) ...[
            ConfidenceBadge(
              confidence: state.averageConfidence,
              hasWarnings: state.hasLowConfidenceFields,
            ),
            const SizedBox(width: 8),
          ],
          AnimatedRotation(
            duration: const Duration(milliseconds: 200),
            turns: isExpanded ? 0.5 : 0,
            child: Icon(
              Icons.keyboard_arrow_down_rounded,
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _NutritionFactsBottomSheetState
    extends ConsumerState<NutritionFactsBottomSheet> {
  late final ExpansibleController _controller;

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(nutritionStateProvider);
    final colorScheme = Theme.of(context).colorScheme;

    // Listen for OCR scan results
    ref.listen<OcrScanState>(ocrScannerProvider, (previous, current) {
      if (current is OcrScanSuccess && previous is! OcrScanSuccess) {
        debugPrint(
            'NutritionFactsBottomSheet: Received OCR result with ${current.facts.populatedFieldCount} fields');

        // Schedule state update for after build completes
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          // Update the nutrition state with scanned facts
          ref.read(nutritionStateProvider.notifier).updateFacts(current.facts);

          // Auto-expand to show the data
          if (!ref.read(nutritionStateProvider).isExpanded) {
            ref.read(nutritionStateProvider.notifier).setExpanded(true);
            _controller.expand();
          }

          // Notify parent
          widget.onChanged?.call(current.facts);
        });
      }
    });

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.outline.withValues(alpha: 0.1)),
        boxShadow: [
          BoxShadow(
            color: colorScheme.shadow.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: Colors.transparent,
          splashColor: Colors.transparent,
          highlightColor: Colors.transparent,
        ),
        child: ExpansionTile(
          controller: _controller,
          initiallyExpanded: true,
          tilePadding: EdgeInsets.zero,
          childrenPadding: EdgeInsets.zero,
          showTrailingIcon: false,
          shape: const Border(),
          collapsedShape: const Border(),
          onExpansionChanged: (expanded) {
            if (expanded != state.isExpanded) {
              ref.read(nutritionStateProvider.notifier).setExpanded(expanded);
            }
          },
          title: _Header(
            state: state,
            isExpanded: state.isExpanded,
          ),
          children: [
            _Content(
              state: state,
              onScan: widget.onScanPressed!,
              onFieldChanged: _onFieldChanged,
              onModeChanged: (mode) =>
                  ref.read(nutritionStateProvider.notifier).setDataMode(mode),
              onClearError: () =>
                  ref.read(nutritionStateProvider.notifier).clearError(),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void didUpdateWidget(NutritionFactsBottomSheet oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Update state when initialFacts changes (e.g., after OCR scan)
    if (widget.initialFacts != oldWidget.initialFacts &&
        widget.initialFacts != null) {
      debugPrint(
          'NutritionFactsBottomSheet: initialFacts updated with ${widget.initialFacts!.populatedFieldCount} fields');

      // Schedule state update for after build completes
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        ref
            .read(nutritionStateProvider.notifier)
            .updateFacts(widget.initialFacts!);
        // Auto-expand when data is received
        if (!ref.read(nutritionStateProvider).isExpanded) {
          ref.read(nutritionStateProvider.notifier).setExpanded(true);
          _controller.expand();
        }
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = ExpansibleController();

    if (widget.initialFacts != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref
            .read(nutritionStateProvider.notifier)
            .updateFacts(widget.initialFacts!);
      });
    }
  }

  // Future<void> _launchScanner() async {
  //   if (widget.onScanPressed == null) return;

  //   // Just navigate to scanner - the ref.listen above will handle the result
  //   widget.onScanPressed();
  // }

  void _onFieldChanged(String key, double? value) {
    final facts = ref.read(nutritionStateProvider).facts;
    if (facts == null) return;

    final updated = _updateField(facts, key, value);
    ref.read(nutritionStateProvider.notifier).updateFacts(updated);
    widget.onChanged?.call(updated);
  }

  NutritionFacts _updateField(NutritionFacts facts, String key, double? value) {
    return switch (key) {
      'energyKcal100g' => facts.copyWith(energyKcal100g: value),
      'fat100g' => facts.copyWith(fat100g: value),
      'saturatedFat100g' => facts.copyWith(saturatedFat100g: value),
      'carbohydrates100g' => facts.copyWith(carbohydrates100g: value),
      'sugars100g' => facts.copyWith(sugars100g: value),
      'fiber100g' => facts.copyWith(fiber100g: value),
      'proteins100g' => facts.copyWith(proteins100g: value),
      'sodium100g' => facts.copyWith(sodium100g: value),
      'salt100g' => facts.copyWith(salt100g: value),
      _ => facts,
    };
  }
}

class _ScanButton extends StatelessWidget {
  final VoidCallback onTap;

  const _ScanButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [colorScheme.tertiary, colorScheme.secondary],
            ),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.document_scanner_rounded,
                color: colorScheme.onTertiary,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                context.l10n.scan,
                style: TextStyle(
                  color: colorScheme.onTertiary,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _ToggleOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _ToggleOption({
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.all(3),
          decoration: BoxDecoration(
            color: isSelected ? colorScheme.primary : Colors.transparent,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child: Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                color: isSelected
                    ? colorScheme.onPrimary
                    : colorScheme.onSurfaceVariant,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

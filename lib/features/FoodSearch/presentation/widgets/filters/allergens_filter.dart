import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/filter_section_header.dart';
import 'package:flutter/material.dart';

class AllergensFilter extends StatelessWidget {
  final List<String> excludedAllergens;
  final ValueChanged<String> onToggleAllergen;

  const AllergensFilter({
    super.key,
    required this.excludedAllergens,
    required this.onToggleAllergen,
  });

  @override
  Widget build(BuildContext context) {
    return FilterSectionHeader(
      title: context.l10n.excludeAllergens,
      content: Wrap(
        spacing: context.smallSpacing,
        children: {
          'milk': context.l10n.milk,
          'eggs': context.l10n.eggs,
          'peanuts': context.l10n.peanuts,
          'tree nuts': context.l10n.treeNuts,
          'soy': context.l10n.soy,
          'wheat': context.l10n.wheat,
          'fish': context.l10n.fish,
          'shellfish': context.l10n.shellfish,
        }.entries.map((entry) {
          final isSelected = excludedAllergens.contains(entry.key);
          return FilterChip(
            label: Text(entry.value),
            selected: isSelected,
            onSelected: (_) => onToggleAllergen(entry.key),
          );
        }).toList(),
      ),
    );
  }
}

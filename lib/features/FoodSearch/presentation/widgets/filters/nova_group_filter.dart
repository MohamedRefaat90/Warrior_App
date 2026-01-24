import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/filter_section_header.dart';
import 'package:flutter/material.dart';

class NovaGroupFilter extends StatelessWidget {
  final int? selectedGroup;
  final ValueChanged<int?> onSelected;

  const NovaGroupFilter({
    super.key,
    required this.selectedGroup,
    required this.onSelected,
  });

  @override
  Widget build(BuildContext context) {
    return FilterSectionHeader(
      title: context.l10n.novaGroup,
      content: Wrap(
        spacing: context.smallSpacing,
        children: [1, 2, 3, 4].map((group) {
          final isSelected = selectedGroup == group;
          return FilterChip(
            label: Text('${context.l10n.group} $group'),
            selected: isSelected,
            onSelected: (selected) {
              onSelected(selected ? group : null);
            },
          );
        }).toList(),
      ),
    );
  }
}

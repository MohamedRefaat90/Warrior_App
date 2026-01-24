import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/filters/filter_section_header.dart';
import 'package:flutter/material.dart';

class DietaryPreferencesFilter extends StatelessWidget {
  final bool veganOnly;
  final bool vegetarianOnly;
  final bool palmOilFree;
  final VoidCallback onToggleVegan;
  final VoidCallback onToggleVegetarian;
  final VoidCallback onTogglePalmOilFree;

  const DietaryPreferencesFilter({
    super.key,
    required this.veganOnly,
    required this.vegetarianOnly,
    required this.palmOilFree,
    required this.onToggleVegan,
    required this.onToggleVegetarian,
    required this.onTogglePalmOilFree,
  });

  @override
  Widget build(BuildContext context) {
    return FilterSectionHeader(
      title: context.l10n.dietaryPreferences,
      content: Column(
        children: [
          SwitchListTile(
            title: Text('veganOnly'.tr(context)),
            value: veganOnly,
            onChanged: (_) => onToggleVegan(),
          ),
          SwitchListTile(
            title: Text('vegetarianOnly'.tr(context)),
            value: vegetarianOnly,
            onChanged: (_) => onToggleVegetarian(),
          ),
          SwitchListTile(
            title: Text(context.l10n.palmOilFree),
            value: palmOilFree,
            onChanged: (_) => onTogglePalmOilFree(),
          ),
        ],
      ),
    );
  }
}

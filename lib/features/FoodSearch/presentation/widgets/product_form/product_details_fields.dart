import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';

/// Product details fields (serving size, ingredients, countries).
class ProductDetailsFields extends StatelessWidget {
  final TextEditingController servingSizeController;
  final TextEditingController ingredientsController;
  final TextEditingController countriesController;

  const ProductDetailsFields({
    super.key,
    required this.servingSizeController,
    required this.ingredientsController,
    required this.countriesController,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Serving size field
        TextFormField(
          controller: servingSizeController,
          decoration: InputDecoration(
            labelText: context.l10n.servingSize,
            hintText: context.l10n.servingSizeExample,
            prefixIcon: const Icon(Icons.restaurant),
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),

        // Ingredients field
        TextFormField(
          controller: ingredientsController,
          decoration: InputDecoration(
            labelText: context.l10n.ingredients,
            hintText: context.l10n.ingredientsHint,
            prefixIcon: const Icon(Icons.list),
            border: const OutlineInputBorder(),
          ),
          maxLines: 4,
          textCapitalization: TextCapitalization.sentences,
        ),
        const SizedBox(height: 16),

        // Countries field
        TextFormField(
          controller: countriesController,
          decoration: InputDecoration(
            labelText: context.l10n.countries,
            hintText: context.l10n.countriesHint,
            prefixIcon: const Icon(Icons.public),
            border: const OutlineInputBorder(),
          ),
          textCapitalization: TextCapitalization.words,
        ),
      ],
    );
  }
}

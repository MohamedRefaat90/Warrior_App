import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class FilterSectionHeader extends StatelessWidget {
  final String title;
  final Widget content;

  const FilterSectionHeader({
    super.key,
    required this.title,
    required this.content,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        SizedBox(height: context.smallSpacing),
        content,
      ],
    );
  }
}

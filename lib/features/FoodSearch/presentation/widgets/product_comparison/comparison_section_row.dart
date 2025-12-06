import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

/// A row widget for comparing a single attribute across multiple products.
class ComparisonSectionRow extends StatelessWidget {
  final String title;
  final List<Widget> values;

  const ComparisonSectionRow({
    super.key,
    required this.title,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: context.smallSpacing,
        horizontal: context.mediumSpacing,
      ),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              title,
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
          ),
          ...values.map((value) => Expanded(
                flex: 1,
                child: Center(child: value),
              )),
        ],
      ),
    );
  }
}

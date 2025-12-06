import 'package:flutter/material.dart';

/// A row widget for comparing nutrition values with best/worst highlighting.
class NutritionComparisonRow extends StatelessWidget {
  final String label;
  final List<String> values;

  const NutritionComparisonRow({
    super.key,
    required this.label,
    required this.values,
  });

  @override
  Widget build(BuildContext context) {
    // Find the best and worst values
    final numericValues = values
        .map((v) => double.tryParse(v.replaceAll(RegExp(r'[^0-9.]'), '')))
        .toList();
    final validValues =
        numericValues.where((v) => v != null).cast<double>().toList();

    double? minValue;
    double? maxValue;
    if (validValues.isNotEmpty) {
      minValue = validValues.reduce((a, b) => a < b ? a : b);
      maxValue = validValues.reduce((a, b) => a > b ? a : b);
    }

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
            flex: 4,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          ...List.generate(values.length, (index) {
            final value = values[index];
            final numericValue = numericValues[index];
            final isBest = numericValue != null &&
                minValue != null &&
                numericValue == minValue &&
                label.toLowerCase().contains('energy') == false;
            final isWorst = numericValue != null &&
                maxValue != null &&
                numericValue == maxValue &&
                validValues.length > 1;

            return Expanded(
              flex: 3,
              child: Center(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isBest
                        ? Colors.green.withValues(alpha: 0.2)
                        : isWorst
                            ? Colors.red.withValues(alpha: 0.2)
                            : null,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    value,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight:
                              isBest || isWorst ? FontWeight.bold : null,
                          color: isBest
                              ? Colors.green[700]
                              : isWorst
                                  ? Colors.red[700]
                                  : null,
                        ),
                  ),
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';

/// Widget to display NOVA group (1-4 circles)
/// NOVA classification indicates level of food processing
class NovaGroupIndicator extends StatelessWidget {
  final int? novaGroup;
  final double size;

  const NovaGroupIndicator({
    super.key,
    required this.novaGroup,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (novaGroup == null || novaGroup! < 1 || novaGroup! > 4) {
      return const SizedBox.shrink();
    }

    return Tooltip(
      message: _getNovaDescription(novaGroup!),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(4, (index) {
          final isFilled = index < novaGroup!;
          return Padding(
            padding: EdgeInsets.only(right: index < 3 ? 4 : 0),
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: isFilled ? _getNovaColor(novaGroup!) : Colors.grey[300],
                shape: BoxShape.circle,
                border: Border.all(
                  color: isFilled
                      ? _getNovaColor(novaGroup!)
                      : Colors.grey[400]!,
                  width: 1,
                ),
              ),
            ),
          );
        }),
      ),
    );
  }

  Color _getNovaColor(int group) {
    switch (group) {
      case 1:
        return const Color(0xFF038141); // Green
      case 2:
        return const Color(0xFF85BB2F); // Light Green
      case 3:
        return const Color(0xFFEE8100); // Orange
      case 4:
        return const Color(0xFFE63E11); // Red
      default:
        return Colors.grey;
    }
  }

  String _getNovaDescription(int group) {
    switch (group) {
      case 1:
        return 'NOVA 1: Unprocessed or minimally processed foods';
      case 2:
        return 'NOVA 2: Processed culinary ingredients';
      case 3:
        return 'NOVA 3: Processed foods';
      case 4:
        return 'NOVA 4: Ultra-processed foods';
      default:
        return 'Unknown NOVA group';
    }
  }
}


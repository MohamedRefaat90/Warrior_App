import 'package:flutter/material.dart';

/// Returns confidence level from a 0.0-1.0 score.
ConfidenceLevel getConfidenceLevel(double confidence) {
  if (confidence >= 0.7) return ConfidenceLevel.high;
  if (confidence >= 0.4) return ConfidenceLevel.medium;
  return ConfidenceLevel.low;
}

/// Badge showing average confidence with optional warning.
class ConfidenceBadge extends StatelessWidget {
  final double confidence;
  final bool hasWarnings;

  const ConfidenceBadge({
    super.key,
    required this.confidence,
    this.hasWarnings = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ConfidenceIndicator(confidence: confidence, showPercentage: true),
        if (hasWarnings) ...[
          const SizedBox(width: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: Colors.orange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              'Review',
              style: TextStyle(
                color: Colors.orange,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// Visual indicator showing OCR confidence level.
class ConfidenceIndicator extends StatefulWidget {
  final double confidence;
  final double size;
  final bool showPercentage;

  const ConfidenceIndicator({
    super.key,
    required this.confidence,
    this.size = 24.0,
    this.showPercentage = false,
  });

  @override
  State<ConfidenceIndicator> createState() => _ConfidenceIndicatorState();
}

/// Confidence level categories.
enum ConfidenceLevel { high, medium, low }

class _ConfidenceIndicatorState extends State<ConfidenceIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  Color get _color => switch (_level) {
        ConfidenceLevel.high => const Color(0xFF4CAF50),
        ConfidenceLevel.medium => const Color(0xFFFFA726),
        ConfidenceLevel.low => const Color(0xFFEF5350),
      };

  IconData get _icon => switch (_level) {
        ConfidenceLevel.high => Icons.check_circle_rounded,
        ConfidenceLevel.medium => Icons.info_rounded,
        ConfidenceLevel.low => Icons.warning_rounded,
      };

  ConfidenceLevel get _level => getConfidenceLevel(widget.confidence);

  @override
  Widget build(BuildContext context) {
    final percentage = (widget.confidence * 100).round();

    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final scale =
            _level == ConfidenceLevel.low ? _scaleAnimation.value : 1.0;

        return Transform.scale(
          scale: scale,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(4),
              border: Border.all(color: _color.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(_icon, size: 14, color: _color),
                if (widget.showPercentage) ...[
                  const SizedBox(width: 4),
                  Text(
                    '$percentage%',
                    style: TextStyle(
                      color: _color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  void didUpdateWidget(ConfidenceIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.confidence != widget.confidence) {
      _updateAnimation();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    _updateAnimation();
  }

  void _updateAnimation() {
    if (_level == ConfidenceLevel.low) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.value = 0;
    }
  }
}

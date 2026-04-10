import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../providers/body_diagram_provider.dart';
import 'muscle_label_card.dart';

/// Overlay that draws arrows and positions label cards on body diagram
class MuscleLabelsOverlay extends StatefulWidget {
  final List<MuscleModel> muscles;
  final bool isComingFromWorkoutScreen;
  final bool? appendToExistingWorkoutSet;
  final Size containerSize; // Full container size
  final Size imageSize; // Actual rendered image size
  final BodyView bodyView;

  const MuscleLabelsOverlay({
    super.key,
    required this.muscles,
    required this.isComingFromWorkoutScreen,
    this.appendToExistingWorkoutSet,
    required this.containerSize,
    required this.imageSize,
    required this.bodyView,
  });

  @override
  State<MuscleLabelsOverlay> createState() => _MuscleLabelsOverlayState();
}

class _ArrowPainter extends CustomPainter {
  final List<MuscleLabel> labels;
  final Size imageSize;
  final Offset imageOffset;
  final bool isDark;
  final Map<String, Offset> draggedPositions;

  _ArrowPainter({
    required this.labels,
    required this.imageSize,
    required this.imageOffset,
    required this.isDark,
    required this.draggedPositions,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      // ..color = isDark ? Colors.white : Colors.black
      ..color = Colors.amberAccent
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    for (final label in labels) {
      final labelPos = draggedPositions[label.muscleKey] ??
          Offset(label.labelX, label.labelY);

      // Calculate positions relative to centered image
      final startX = imageOffset.dx + (labelPos.dx * imageSize.width);
      final startY = imageOffset.dy + (labelPos.dy * imageSize.height);
      final endX = imageOffset.dx + (label.anchorX * imageSize.width);
      final endY = imageOffset.dy + (label.anchorY * imageSize.height);

      final path = Path();
      path.moveTo(startX, startY);

      final ctrlX = (startX + endX) / 2;
      final ctrlY = (startY + endY) / 2 - 20;

      path.quadraticBezierTo(ctrlX, ctrlY, endX, endY);
      canvas.drawPath(path, paint);

      _drawArrowHead(canvas, paint, endX, endY, startX, startY);
    }
  }

  @override
  bool shouldRepaint(covariant _ArrowPainter oldDelegate) =>
      oldDelegate.labels.length != labels.length ||
      oldDelegate.isDark != isDark ||
      !identical(oldDelegate.draggedPositions, draggedPositions) ||
      oldDelegate.imageSize != imageSize ||
      oldDelegate.imageOffset != imageOffset;

  void _drawArrowHead(Canvas canvas, Paint paint, double x, double y,
      double fromX, double fromY) {
    const arrowSize = 8.0;
    final dx = x - fromX;
    final dy = y - fromY;
    final lenSquared = (dx * dx + dy * dy);
    if (lenSquared < 1) return;

    final distance = lenSquared.clamp(1.0, double.infinity);
    final unitX = dx / distance;
    final unitY = dy / distance;

    final arrowPath = Path();
    arrowPath.moveTo(x, y);
    arrowPath.lineTo(x - arrowSize * unitX + arrowSize * 0.4 * unitY,
        y - arrowSize * unitY - arrowSize * 0.4 * unitX);
    arrowPath.moveTo(x, y);
    arrowPath.lineTo(x - arrowSize * unitX - arrowSize * 0.4 * unitY,
        y - arrowSize * unitY + arrowSize * 0.4 * unitX);

    canvas.drawPath(arrowPath, paint);
  }
}

class _MuscleLabelsOverlayState extends State<MuscleLabelsOverlay> {
  final Map<String, Offset> _draggedPositions = {};

  // Calculate image offset (horizontally centered, bottom aligned)
  Offset get _imageOffset => Offset(
        (widget.containerSize.width - widget.imageSize.width) / 2,
        widget.containerSize.height - widget.imageSize.height, // Bottom aligned
      );

  @override
  Widget build(BuildContext context) {
    final labels = MuscleLabelsData.forView(widget.bodyView);

    return SizedBox(
      width: widget.containerSize.width,
      height: widget.containerSize.height,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Draw arrows
          Positioned.fill(
            child: CustomPaint(
              painter: _ArrowPainter(
                labels: labels,
                imageSize: widget.imageSize,
                imageOffset: _imageOffset,
                isDark: Theme.of(context).brightness == Brightness.dark,
                draggedPositions: _draggedPositions,
              ),
            ),
          ),
          // Position label cards
          ...labels.map((label) => _buildDraggableCard(label)),
        ],
      ),
    );
  }

  Widget _buildDraggableCard(MuscleLabel label) {
    // Safe muscle lookup - return empty widget if not found
    final muscle = widget.muscles.cast<MuscleModel?>().firstWhere(
          (m) => m?.name.toLowerCase() == label.muscleKey.toLowerCase(),
          orElse: () => null,
        );

    if (muscle == null) return const SizedBox.shrink();

    final position = _draggedPositions[label.muscleKey] ??
        Offset(label.labelX, label.labelY);

    // Calculate actual position relative to centered image
    final x = _imageOffset.dx + (position.dx * widget.imageSize.width);
    final y = _imageOffset.dy + (position.dy * widget.imageSize.height);

    return Positioned(
      left: x,
      top: y,
      child: FractionalTranslation(
        translation: const Offset(-0.5, -0.5), // Center the card on position
        child: GestureDetector(
          onPanUpdate: (details) {
            setState(() {
              final newX = (x + details.delta.dx - _imageOffset.dx) /
                  widget.imageSize.width;
              final newY = (y + details.delta.dy - _imageOffset.dy) /
                  widget.imageSize.height;
              _draggedPositions[label.muscleKey] =
                  Offset(newX.clamp(0.0, 1.0), newY.clamp(0.0, 1.0));
            });
          },
          onPanEnd: (_) {
            if (kDebugMode) {
              final pos = _draggedPositions[label.muscleKey]!;
              debugPrint(
                  '${label.muscleKey}: labelX: ${pos.dx.toStringAsFixed(2)}, labelY: ${pos.dy.toStringAsFixed(2)}');
            }
          },
          child: MuscleLabelCard(
            muscle: muscle,
            isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
            appendToExistingWorkoutSet: widget.appendToExistingWorkoutSet,
          ),
        ),
      ),
    );
  }
}

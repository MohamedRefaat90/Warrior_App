import 'package:flutter/material.dart';

import '../providers/body_diagram_provider.dart';

/// Debug overlay to visualize hotspot boundaries for coordinate tuning
class HotspotDebugPainter extends CustomPainter {
  final List<MuscleHotspot> hotspots;
  final Size imageSize;

  HotspotDebugPainter({required this.hotspots, required this.imageSize});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = Colors.red.withOpacity(0.3)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = Colors.red
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    for (final hotspot in hotspots) {
      if (hotspot.shape == HotspotShape.rect) {
        _drawRect(canvas, hotspot, fillPaint, borderPaint);
      } else {
        _drawPolygon(canvas, hotspot, fillPaint, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant HotspotDebugPainter oldDelegate) {
    return oldDelegate.hotspots != hotspots ||
        oldDelegate.imageSize != imageSize;
  }

  void _drawPolygon(
    Canvas canvas,
    MuscleHotspot hotspot,
    Paint fillPaint,
    Paint borderPaint,
  ) {
    final path = Path();
    for (int i = 0; i < hotspot.coordinates.length; i += 2) {
      final x = hotspot.coordinates[i] * imageSize.width;
      final y = hotspot.coordinates[i + 1] * imageSize.height;
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();
    canvas.drawPath(path, fillPaint);
    canvas.drawPath(path, borderPaint);

    // Draw label at centroid
    final bounds = path.getBounds();
    final textPainter = TextPainter(
      text: TextSpan(
        text: hotspot.muscleKey,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
        canvas,
        Offset(bounds.center.dx - textPainter.width / 2,
            bounds.center.dy - textPainter.height / 2));
  }

  void _drawRect(
    Canvas canvas,
    MuscleHotspot hotspot,
    Paint fillPaint,
    Paint borderPaint,
  ) {
    final rect = Rect.fromLTWH(
      hotspot.coordinates[0] * imageSize.width,
      hotspot.coordinates[1] * imageSize.height,
      hotspot.coordinates[2] * imageSize.width,
      hotspot.coordinates[3] * imageSize.height,
    );
    canvas.drawRect(rect, fillPaint);
    canvas.drawRect(rect, borderPaint);

    // Draw label
    final textPainter = TextPainter(
      text: TextSpan(
        text: hotspot.muscleKey,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(rect.left + 4, rect.top + 4));
  }
}

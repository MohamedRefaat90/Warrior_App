import 'dart:math' as math;

import 'package:flutter/material.dart';

/// Instructions widget for scanner.
class ScannerInstructions extends StatelessWidget {
  final String text;

  const ScannerInstructions({
    super.key,
    this.text = 'Position the nutrition label within the frame',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(24),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.center_focus_weak_rounded,
            color: Colors.white.withValues(alpha: 0.9),
            size: 20,
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.9),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }
}

/// Animated scanning overlay widget.
class ScanningOverlay extends StatefulWidget {
  final bool isScanning;
  final Color accentColor;
  final Widget? child;

  const ScanningOverlay({
    super.key,
    this.isScanning = true,
    this.accentColor = const Color(0xFF4CAF50),
    this.child,
  });

  @override
  State<ScanningOverlay> createState() => _ScanningOverlayState();
}

/// Custom painter for scanner overlay with animated scan line.
class ScanningOverlayPainter extends CustomPainter {
  final double scanLineProgress;
  final Color accentColor;

  ScanningOverlayPainter({
    required this.scanLineProgress,
    this.accentColor = const Color(0xFF4CAF50),
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final cutoutWidth = size.width * 0.85;
    final cutoutHeight = cutoutWidth * 0.85;

    final cutoutRect = Rect.fromCenter(
      center: center,
      width: cutoutWidth,
      height: cutoutHeight,
    );

    // Dark overlay with cutout
    final overlayPath = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)))
      ..fillType = PathFillType.evenOdd;

    canvas.drawPath(
      overlayPath,
      Paint()..color = Colors.black.withValues(alpha: 0.6),
    );

    // Frame border
    canvas.drawRRect(
      RRect.fromRectAndRadius(cutoutRect, const Radius.circular(16)),
      Paint()
        ..color = Colors.white.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1,
    );

    // Corner markers
    _drawCorners(canvas, cutoutRect);

    // Scan line
    _drawScanLine(canvas, cutoutRect);
  }

  @override
  bool shouldRepaint(ScanningOverlayPainter oldDelegate) =>
      oldDelegate.scanLineProgress != scanLineProgress ||
      oldDelegate.accentColor != accentColor;

  void _drawCorners(Canvas canvas, Rect rect) {
    final paint = Paint()
      ..color = accentColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const length = 25.0;
    final corners = [
      (rect.topLeft, 0.0),
      (rect.topRight, math.pi / 2),
      (rect.bottomRight, math.pi),
      (rect.bottomLeft, -math.pi / 2),
    ];

    for (final (pos, rotation) in corners) {
      canvas.save();
      canvas.translate(pos.dx, pos.dy);
      canvas.rotate(rotation);
      canvas.drawPath(
        Path()
          ..moveTo(0, length)
          ..lineTo(0, 0)
          ..lineTo(length, 0),
        paint,
      );
      canvas.restore();
    }
  }

  void _drawScanLine(Canvas canvas, Rect rect) {
    final scanY = rect.top + (rect.height * scanLineProgress);

    // Main line with gradient
    final linePaint = Paint()
      ..shader = LinearGradient(
        colors: [
          accentColor.withValues(alpha: 0),
          accentColor,
          accentColor.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromLTWH(rect.left, scanY - 1, rect.width, 2))
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
      Offset(rect.left + 16, scanY),
      Offset(rect.right - 16, scanY),
      linePaint,
    );

    // Subtle glow
    canvas.drawLine(
      Offset(rect.left + 16, scanY),
      Offset(rect.right - 16, scanY),
      Paint()
        ..color = accentColor.withValues(alpha: 0.3)
        ..strokeWidth = 6
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
    );
  }
}

class _ScanningOverlayState extends State<ScanningOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (widget.child != null) widget.child!,
          AnimatedBuilder(
            animation: _controller,
            builder: (context, _) => CustomPaint(
              painter: ScanningOverlayPainter(
                scanLineProgress: _controller.value,
                accentColor: widget.accentColor,
              ),
              size: Size.infinite,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void didUpdateWidget(ScanningOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isScanning != oldWidget.isScanning) {
      widget.isScanning ? _controller.repeat() : _controller.stop();
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
      duration: const Duration(milliseconds: 2000),
    );
    if (widget.isScanning) _controller.repeat();
  }
}

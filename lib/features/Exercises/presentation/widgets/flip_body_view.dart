import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/body_diagram_provider.dart';

/// 3D flip animation widget using Matrix4.rotationY()
class FlipBodyView extends ConsumerStatefulWidget {
  final Widget frontWidget;
  final Widget backWidget;

  const FlipBodyView({
    super.key,
    required this.frontWidget,
    required this.backWidget,
  });

  @override
  ConsumerState<FlipBodyView> createState() => _FlipBodyViewState();
}

class _FlipBodyViewState extends ConsumerState<FlipBodyView>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showFront = true;

  @override
  Widget build(BuildContext context) {
    // Listen to external toggle requests from provider
    ref.listen<BodyView>(bodyDiagramProvider, (previous, next) {
      if (previous != next) {
        if (next == BodyView.back &&
            _controller.status != AnimationStatus.completed) {
          _controller.forward();
        } else if (next == BodyView.front &&
            _controller.status == AnimationStatus.completed) {
          _controller.reverse();
        }
      }
    });

    return GestureDetector(
      onDoubleTap: () {
        ref.read(bodyDiagramProvider.notifier).toggleView();
      },
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          // Calculate rotation angle (0 to π for full 180° flip)
          final angle = _animation.value * math.pi;

          // Determine which side is showing
          final isShowingFront = angle < math.pi / 2;

          // Apply 3D transform with perspective
          final transform = Matrix4.identity()
            ..setEntry(3, 2, 0.001) // Perspective
            ..rotateY(isShowingFront ? angle : angle - math.pi);

          return Transform(
            alignment: Alignment.center,
            transform: transform,
            child: isShowingFront ? widget.frontWidget : widget.backWidget,
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();

    // Sync initial animation state with provider
    final currentView = ref.read(bodyDiagramProvider);
    final initialValue = currentView == BodyView.back ? 1.0 : 0.0;
    _showFront = currentView == BodyView.front;

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
      value: initialValue, // Start at correct position based on provider state
    );

    _animation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOutQuad),
    );

    _animation.addListener(() {
      // Switch content at midpoint of animation (when card is edge-on)
      if (_animation.value >= 0.5 && _showFront) {
        setState(() => _showFront = false);
      } else if (_animation.value < 0.5 && !_showFront) {
        setState(() => _showFront = true);
      }
    });
  }
}

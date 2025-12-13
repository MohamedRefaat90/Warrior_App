import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/body_diagram_provider.dart';
import 'flip_body_view.dart';
import 'hotspot_debug_painter.dart';
import 'muscle_hotspot_layer.dart';

/// Stateless toggle button widget (Flutter best practice)
class BodyViewToggleButton extends ConsumerWidget {
  final BodyView currentView;

  const BodyViewToggleButton({super.key, required this.currentView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<BodyView>(
        segments: const [
          ButtonSegment(value: BodyView.front, label: Text('Front')),
          ButtonSegment(value: BodyView.back, label: Text('Back')),
        ],
        selected: {currentView},
        onSelectionChanged: (selection) {
          ref.read(bodyDiagramProvider.notifier).setView(selection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedBackgroundColor: Theme.of(context).colorScheme.primary,
          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
        ),
      ),
    );
  }
}

/// Debug mode toggle widget (only shown in debug builds)
class DebugModeToggle extends ConsumerWidget {
  const DebugModeToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDebugMode = ref.watch(hotspotDebugModeProvider);
    return SwitchListTile.adaptive(
      title: const Text('Show Hotspot Debug Overlay'),
      value: isDebugMode,
      onChanged: (value) =>
          ref.read(hotspotDebugModeProvider.notifier).setEnabled(value),
      dense: true,
    );
  }
}

/// Main widget combining body image with hotspot layer
class MuscleBodyView extends ConsumerStatefulWidget {
  final List<MuscleModel> muscles;
  final bool isComingFromWorkoutScreen;
  final bool appendToExistingWorkoutSet;

  const MuscleBodyView({
    super.key,
    required this.muscles,
    required this.isComingFromWorkoutScreen,
    required this.appendToExistingWorkoutSet,
  });

  @override
  ConsumerState<MuscleBodyView> createState() => _MuscleBodyViewState();
}

class _MuscleBodyViewState extends ConsumerState<MuscleBodyView> {
  Size _imageSize = Size.zero;
  final GlobalKey _frontImageKey = GlobalKey();
  final GlobalKey _backImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentView = ref.watch(bodyDiagramProvider);

    return Column(
      children: [
        // Toggle button
        BodyViewToggleButton(currentView: currentView),

        // Debug toggle (only in debug builds)
        if (kDebugMode) const DebugModeToggle(),

        const SizedBox(height: 16),

        // Body diagram with hotspots
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return FlipBodyView(
                frontWidget: _buildBodyStack(
                  AppAssets.frontBody,
                  constraints,
                  BodyView.front,
                  _frontImageKey,
                ),
                backWidget: _buildBodyStack(
                  AppAssets.backBody,
                  constraints,
                  BodyView.back,
                  _backImageKey,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  @override
  void initState() {
    super.initState();
    // Precache images for smooth flip animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(AppAssets.frontBody), context);
      precacheImage(const AssetImage(AppAssets.backBody), context);
    });
  }

  Widget _buildBodyStack(
    String imagePath,
    BoxConstraints constraints,
    BodyView view,
    GlobalKey imageKey,
  ) {
    final showDebug = ref.watch(hotspotDebugModeProvider);
    final hotspots = ref
        .watch(muscleHotspotsProvider)
        .where((h) => h.bodyView == view)
        .toList();

    return Stack(
      alignment: Alignment.center,
      children: [
        // Body image
        Image.asset(
          imagePath,
          key: imageKey,
          fit: BoxFit.contain,
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateImageSize(imageKey);
            });
            return child;
          },
        ),

        // Debug overlay to visualize hotspots
        if (showDebug && _imageSize != Size.zero)
          Positioned.fill(
            child: CustomPaint(
              painter: HotspotDebugPainter(
                hotspots: hotspots,
                imageSize: _imageSize,
              ),
            ),
          ),

        // Hotspot detection layer
        if (_imageSize != Size.zero)
          Positioned.fill(
            child: MuscleHotspotLayer(
              muscles: widget.muscles,
              isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
              imageSize: _imageSize,
            ),
          ),
      ],
    );
  }

  void _updateImageSize(GlobalKey key) {
    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && _imageSize == Size.zero) {
      setState(() => _imageSize = renderBox.size);
    }
  }
}

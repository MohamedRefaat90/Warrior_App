import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/body_diagram_provider.dart';
import 'flip_body_view.dart';
import 'muscle_labels_overlay.dart';

/// Main widget combining body image with label cards and arrows
class MuscleBodyView extends ConsumerStatefulWidget {
  final List<MuscleModel> muscles;
  final bool isComingFromWorkoutScreen;
  final bool appendToExistingWorkoutSet;
  final bool hasBannerAd;

  const MuscleBodyView({
    super.key,
    required this.muscles,
    required this.isComingFromWorkoutScreen,
    required this.appendToExistingWorkoutSet,
    this.hasBannerAd = false,
  });

  @override
  ConsumerState<MuscleBodyView> createState() => _MuscleBodyViewState();
}

/// Toggle button for front/back body view
class _BodyViewToggle extends ConsumerWidget {
  final BodyView currentView;

  const _BodyViewToggle({required this.currentView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fontFamily = ref.watch(appSettingsProvider.notifier).fontFamily();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: SegmentedButton<BodyView>(
        selectedIcon: const Icon(Icons.check_circle),
        segments: [
          ButtonSegment(
            value: BodyView.front,
            label: Text(context.l10n.bodyViewFront),
          ),
          ButtonSegment(
            value: BodyView.back,
            label: Text(context.l10n.bodyViewBack),
          ),
        ],
        selected: {currentView},
        onSelectionChanged: (selection) {
          ref.read(bodyDiagramProvider.notifier).setView(selection.first);
        },
        style: SegmentedButton.styleFrom(
          backgroundColor: Theme.of(context).colorScheme.surface,
          selectedBackgroundColor: const Color(0xffEA2253),
          selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
          textStyle: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDarkMode ? Colors.white : Colors.black,
            fontFamily: fontFamily,
          ),
          iconColor: Colors.white,
        ),
      ),
    );
  }
}

class _MuscleBodyViewState extends ConsumerState<MuscleBodyView> {
  Size _imageSize = Size.zero;
  final GlobalKey _frontImageKey = GlobalKey();
  final GlobalKey _backImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentView = ref.watch(bodyDiagramProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        // Calculate responsive sizes based on available space
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final toggleHeight = 48.0;
        // Adjust spacing based on banner ad presence
        final spacing = widget.hasBannerAd
            ? availableHeight * 0.07
            : availableHeight * 0.13;
        final bodyHeight = availableHeight - toggleHeight - spacing;

        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _BodyViewToggle(currentView: currentView),
            SizedBox(height: spacing),
            SizedBox(
              height: bodyHeight,
              width: availableWidth,
              child: FlipBodyView(
                frontWidget: _buildBodyStack(
                  imagePath: AppAssets.frontBody,
                  imageKey: _frontImageKey,
                  view: BodyView.front,
                  maxHeight: bodyHeight,
                  maxWidth: availableWidth,
                ),
                backWidget: _buildBodyStack(
                  imagePath: AppAssets.backBody,
                  imageKey: _backImageKey,
                  view: BodyView.back,
                  maxHeight: bodyHeight,
                  maxWidth: availableWidth,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      precacheImage(const AssetImage(AppAssets.frontBody), context);
      precacheImage(const AssetImage(AppAssets.backBody), context);
    });
  }

  Widget _buildBodyStack({
    required String imagePath,
    required GlobalKey imageKey,
    required BodyView view,
    required double maxHeight,
    required double maxWidth,
  }) {
    return Stack(
      alignment: Alignment.center,
      children: [
        Image.asset(
          imagePath,
          key: imageKey,
          fit: BoxFit.contain,
          height: maxHeight,
          width: maxWidth,
          frameBuilder: (context, child, frame, wasSynchronouslyLoaded) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _updateImageSize(imageKey);
            });
            return child;
          },
        ),
        if (_imageSize != Size.zero)
          Positioned.fill(
            child: MuscleLabelsOverlay(
              muscles: widget.muscles,
              isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
              containerSize: Size(maxWidth, maxHeight),
              imageSize: _imageSize,
              bodyView: view,
            ),
          ),
      ],
    );
  }

  void _updateImageSize(GlobalKey key) {
    if (!mounted) return;

    final renderBox = key.currentContext?.findRenderObject() as RenderBox?;
    if (renderBox != null && renderBox.hasSize && _imageSize == Size.zero) {
      setState(() => _imageSize = renderBox.size);
    }
  }
}

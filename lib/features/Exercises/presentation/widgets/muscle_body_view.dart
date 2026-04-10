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
  // Natural image dimensions (loaded once)
  Size? _frontNaturalSize;
  Size? _backNaturalSize;
  final GlobalKey _frontImageKey = GlobalKey();
  final GlobalKey _backImageKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final currentView = ref.watch(bodyDiagramProvider);

    return LayoutBuilder(
      builder: (context, constraints) {
        final availableHeight = constraints.maxHeight;
        final availableWidth = constraints.maxWidth;
        final toggleHeight = 48.0;
        final bodyHeight = availableHeight - toggleHeight;

        return Stack(
          children: [
            // Toggle button at the top
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: _BodyViewToggle(currentView: currentView),
            ),
            // Body diagram anchored to the bottom
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: bodyHeight,
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
    _loadImageDimensions();
  }

  Widget _buildBodyStack({
    required String imagePath,
    required GlobalKey imageKey,
    required BodyView view,
    required double maxHeight,
    required double maxWidth,
  }) {
    // Get natural size for this view
    final naturalSize =
        view == BodyView.front ? _frontNaturalSize : _backNaturalSize;

    // Calculate actual rendered size based on BoxFit.contain
    final renderedSize = naturalSize != null
        ? _calculateRenderedSize(naturalSize, maxWidth, maxHeight)
        : Size.zero;

    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Image.asset(
          imagePath,
          key: imageKey,
          fit: BoxFit.contain,
          height: maxHeight,
          width: maxWidth,
          alignment: Alignment.bottomCenter,
        ),
        if (renderedSize != Size.zero)
          Positioned.fill(
            child: MuscleLabelsOverlay(
              muscles: widget.muscles,
              isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
              appendToExistingWorkoutSet: widget.appendToExistingWorkoutSet,
              containerSize: Size(maxWidth, maxHeight),
              imageSize: renderedSize,
              bodyView: view,
            ),
          ),
      ],
    );
  }

  /// Calculate actual rendered size after BoxFit.contain is applied
  Size _calculateRenderedSize(
      Size naturalSize, double maxWidth, double maxHeight) {
    final imageAspect = naturalSize.width / naturalSize.height;
    final containerAspect = maxWidth / maxHeight;

    if (imageAspect > containerAspect) {
      // Image is wider than container - width limited
      return Size(maxWidth, maxWidth / imageAspect);
    } else {
      // Image is taller than container - height limited
      return Size(maxHeight * imageAspect, maxHeight);
    }
  }

  /// Load natural image dimensions for accurate BoxFit.contain calculations
  Future<void> _loadImageDimensions() async {
    // Load front image dimensions
    final frontImage = AssetImage(AppAssets.frontBody);
    final frontStream = frontImage.resolve(ImageConfiguration.empty);
    frontStream.addListener(ImageStreamListener((info, _) {
      if (mounted && _frontNaturalSize == null) {
        setState(() {
          _frontNaturalSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }
    }));

    // Load back image dimensions
    final backImage = AssetImage(AppAssets.backBody);
    final backStream = backImage.resolve(ImageConfiguration.empty);
    backStream.addListener(ImageStreamListener((info, _) {
      if (mounted && _backNaturalSize == null) {
        setState(() {
          _backNaturalSize = Size(
            info.image.width.toDouble(),
            info.image.height.toDouble(),
          );
        });
      }
    }));
  }
}

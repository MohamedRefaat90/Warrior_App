import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/extensions/translation_ext.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/FinishBTN.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/create_workout_warning.dart';
import 'package:Warrior/features/Workouts/presentation/providers/workout_provider.dart';
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

  const MuscleBodyView({
    super.key,
    required this.muscles,
    required this.isComingFromWorkoutScreen,
    required this.appendToExistingWorkoutSet,
  });

  @override
  ConsumerState<MuscleBodyView> createState() => _MuscleBodyViewState();
}

// Toggle button for front/back view
class _BodyViewToggle extends ConsumerWidget {
  final BodyView currentView;

  const _BodyViewToggle({required this.currentView});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final fontFamily = ref.watch(appSettingsProvider.notifier).fontFamily();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
      child: SegmentedButton<BodyView>(
        selectedIcon: Icon(Icons.check_circle),
        segments: [
          ButtonSegment(
              value: BodyView.front,
              label: Text(
                context.l10n.bodyViewFront,
              )),
          ButtonSegment(
              value: BodyView.back,
              label: Text(
                context.l10n.bodyViewBack,
              )),
        ],
        selected: {currentView},
        onSelectionChanged: (selection) {
          ref.read(bodyDiagramProvider.notifier).setView(selection.first);
        },
        style: SegmentedButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.surface,
            selectedBackgroundColor: Color(0xffEA2253),
            selectedForegroundColor: Theme.of(context).colorScheme.onPrimary,
            textStyle: TextStyle(
                fontWeight: FontWeight.bold,
                color: isDarkMode ? Colors.white : Colors.black,
                fontFamily: fontFamily),
            iconColor: Colors.white),
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
    final workoutNotifier = ref.read(workoutsProvider.notifier);

    return Stack(
      alignment: Alignment.topCenter,
      children: [
        Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            const Spacer(),

            // Body diagram with labels
            Expanded(
              flex: 5,
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

            if (widget.isComingFromWorkoutScreen == true &&
                (workoutNotifier.newWorkout.workoutItems == null ||
                    workoutNotifier.newWorkout.workoutItems!.isEmpty)) ...[
              const SizedBox(height: 16),
              CreateWorkoutWarning()
            ],

            if (widget.isComingFromWorkoutScreen) ...[
              FinishBTN(
                  primaryColor: AppColors.darkPrimary,
                  appendToExistingWorkoutSet:
                      widget.appendToExistingWorkoutSet),
              const SizedBox(height: 16),
            ]
          ],
        ),
        // Toggle button
        Positioned(top: 20, child: _BodyViewToggle(currentView: currentView)),
      ],
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

  Widget _buildBodyStack(
    String imagePath,
    BoxConstraints constraints,
    BodyView view,
    GlobalKey imageKey,
  ) {
    final containerSize = Size(constraints.maxWidth, constraints.maxHeight);

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

        // Labels and arrows overlay
        if (_imageSize != Size.zero)
          Positioned.fill(
            child: MuscleLabelsOverlay(
              muscles: widget.muscles,
              isComingFromWorkoutScreen: widget.isComingFromWorkoutScreen,
              containerSize: containerSize,
              imageSize: _imageSize,
              bodyView: view,
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

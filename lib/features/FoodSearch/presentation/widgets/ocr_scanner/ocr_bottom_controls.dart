import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_action_button.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/ocr_scanner/ocr_capture_button.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class OcrBottomControls extends StatelessWidget {
  final bool isLoading;
  final bool isInitialized;
  final VoidCallback onGalleryPressed;
  final VoidCallback onCapturePressed;

  const OcrBottomControls({
    super.key,
    required this.isLoading,
    required this.isInitialized,
    required this.onGalleryPressed,
    required this.onCapturePressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(context.largeSpacing),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.transparent,
            Colors.black.withValues(alpha: 0.8),
          ],
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              context.l10n.captureAndCropInstructions,
              style: Theme.of(context)
                  .textTheme
                  .bodyLarge
                  ?.copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.largeSpacing),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                OcrActionButton(
                  icon: Icons.photo_library,
                  label: 'gallery'.tr(context),
                  onPressed: isLoading ? null : onGalleryPressed,
                ),
                OcrCaptureButton(
                  onPressed:
                      (isLoading || !isInitialized) ? null : onCapturePressed,
                  isLoading: isLoading,
                ),
                OcrActionButton(
                  icon: Icons.edit,
                  label: 'manual'.tr(context),
                  onPressed: isLoading ? null : () => context.pop(null),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

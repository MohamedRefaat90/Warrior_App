import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart';
import 'package:flutter/material.dart';

class OcrLoadingOverlay extends StatelessWidget {
  final OcrScanState state;

  const OcrLoadingOverlay({
    super.key,
    required this.state,
  });

  @override
  Widget build(BuildContext context) {
    final message = state is OcrScanLoading
        ? (state as OcrScanLoading).message
        : 'Processing...';

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: Colors.white),
            SizedBox(height: context.mediumSpacing),
            Text(
              message,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                  ),
            ),
          ],
        ),
      ),
    );
  }
}

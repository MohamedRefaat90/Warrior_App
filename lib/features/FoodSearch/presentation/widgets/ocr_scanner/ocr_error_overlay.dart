import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

class OcrErrorOverlay extends ConsumerWidget {
  final OcrScanError error;
  final VoidCallback onRetry;

  const OcrErrorOverlay({
    super.key,
    required this.error,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);

    return Container(
      color: Colors.black.withValues(alpha: 0.7),
      child: Center(
        child: Padding(
          padding: EdgeInsets.all(context.extraLargeSpacing),
          child: Card(
            child: Padding(
              padding: EdgeInsets.all(context.largeSpacing),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: theme.colorScheme.error,
                  ),
                  SizedBox(height: context.mediumSpacing),
                  Text(
                    'ocrFailed'.tr(context),
                    style: theme.textTheme.titleLarge,
                  ),
                  SizedBox(height: context.smallSpacing),
                  Text(
                    error.message,
                    style: theme.textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: context.largeSpacing),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      if (error.canRetry)
                        OutlinedButton.icon(
                          onPressed: onRetry,
                          icon: const Icon(Icons.refresh),
                          label: Text('retake'.tr(context)),
                        ),
                      ElevatedButton.icon(
                        onPressed: () => context.pop(null),
                        icon: const Icon(Icons.edit),
                        label: Text('manualEntry'.tr(context)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

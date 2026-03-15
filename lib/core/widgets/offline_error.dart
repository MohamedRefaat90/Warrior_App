import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class OfflineError extends ConsumerWidget {
  final bool isOffline;
  final AsyncNotifierProvider provider;
  const OfflineError(
      {super.key, required this.isOffline, required this.provider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: context.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              isOffline ? Icons.wifi_off : Icons.error_outline,
              size: ResponsiveUtils.value<double>(
                context,
                mobile: 48,
                tablet: 56,
                desktop: 64,
              ),
              color: isOffline ? Colors.orange : Colors.red,
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              isOffline
                  ? context.l10n.youAreOffline
                  : context.l10n.somethingWentWrong,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              isOffline
                  ? context.l10n.noCachedWorkoutsAvailable
                  : context.l10n.failedToLoadPredefinedWorkouts,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            SizedBox(height: context.mediumSpacing),
            ElevatedButton(
              onPressed: () => ref.invalidate(provider),
              child: Text('retry'.tr(context)),
            ),
          ],
        ),
      ),
    );
  }
}

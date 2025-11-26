import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ErrorCard extends ConsumerWidget {
  const ErrorCard({super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Container(
        margin: EdgeInsets.all(context.largeSpacing),
        padding: EdgeInsets.all(context.extraLargeSpacing),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(context.largeSpacing),
          gradient: LinearGradient(
            colors: [
              Colors.red.shade400.withOpacity(0.1),
              Colors.orange.shade400.withOpacity(0.1),
            ],
          ),
          border: Border.all(
            color: Colors.red.shade300.withOpacity(0.3),
            width: 2,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: context.largeIconSize,
              color: Colors.red.shade400,
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              'Something went wrong!',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            SizedBox(height: context.largeSpacing),
            ElevatedButton.icon(
              onPressed: () => ref.invalidate(musclesProvider, asReload: true),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                padding: ResponsiveUtils.buttonPadding(context),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(context.responsiveBorderRadius),
                ),
                elevation: 8,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

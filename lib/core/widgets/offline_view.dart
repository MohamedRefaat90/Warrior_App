import 'package:Warrior/core/extensions/string.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:flutter/material.dart';

class OfflineView extends StatelessWidget {
  final String title;

  final String subtitle;
  const OfflineView({
    super.key,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: context.screenPadding,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.wifi_off,
              size: context.largeIconSize,
              color: Colors.grey,
            ),
            SizedBox(height: context.mediumSpacing),
            Text(
              title.capitalizeWord(),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: context.smallSpacing),
            Text(
              subtitle.capitalizeWord(),
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.grey[600],
                  ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

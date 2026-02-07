import 'package:flutter/material.dart';

/// Widget that displays cache status and age information.
///
/// Shows "Offline - Cached Data" with timestamp indicating when data was cached.
/// Displays cache age in human-readable format (e.g., "Cached 2 minutes ago").
class CacheIndicatorWidget extends StatelessWidget {
  /// The timestamp when the data was cached.
  final DateTime cachedAt;

  /// Whether to show this indicator (typically true when offline or viewing cached data).
  final bool isVisible;

  /// Optional custom text color for the indicator.
  final Color? textColor;

  /// Optional custom icon color.
  final Color? iconColor;

  /// Whether to show the icon alongside the text.
  final bool showIcon;

  const CacheIndicatorWidget({
    super.key,
    required this.cachedAt,
    this.isVisible = true,
    this.textColor,
    this.iconColor,
    this.showIcon = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible) {
      return const SizedBox.shrink();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.cloud_off_outlined,
              size: 16,
              color: iconColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 6),
          ],
          Flexible(
            child: Text(
              'Offline - Cached ${_getTimeAgo()}',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: textColor ?? Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  /// Calculates human-readable time difference between cached time and now.
  String _getTimeAgo() {
    final now = DateTime.now();
    final difference = now.difference(cachedAt);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else {
      // For older than a week, show the actual date
      return 'on ${cachedAt.month}/${cachedAt.day}';
    }
  }
}

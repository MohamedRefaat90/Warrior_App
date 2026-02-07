import 'package:flutter/material.dart';

/// Widget that displays a badge showing pending upload count.
///
/// Shows a circular badge with the count of pending uploads waiting to sync.
/// Only visible when count > 0.
class PendingUploadBadge extends StatelessWidget {
  /// The number of pending uploads.
  final int pendingCount;

  /// Optional callback when the badge is tapped.
  final VoidCallback? onTap;

  /// Whether the badge should be visible (typically true when count > 0).
  final bool isVisible;

  /// Background color of the badge.
  final Color? backgroundColor;

  /// Text color for the count number.
  final Color? textColor;

  /// Size of the badge.
  final double badgeSize;

  const PendingUploadBadge({
    super.key,
    required this.pendingCount,
    this.onTap,
    this.isVisible = true,
    this.backgroundColor,
    this.textColor,
    this.badgeSize = 24,
  });

  @override
  Widget build(BuildContext context) {
    if (!isVisible || pendingCount <= 0) {
      return const SizedBox.shrink();
    }

    final badgeColor = backgroundColor ?? Theme.of(context).colorScheme.error;
    final displayCount = pendingCount > 99 ? '99+' : '$pendingCount';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: badgeSize,
        height: badgeSize,
        decoration: BoxDecoration(
          color: badgeColor,
          shape: BoxShape.circle,
        ),
        child: Center(
          child: Text(
            displayCount,
            style: TextStyle(
              color: textColor ?? Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

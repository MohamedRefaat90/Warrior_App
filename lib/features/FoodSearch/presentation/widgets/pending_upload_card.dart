import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_upload_status.dart';
import 'package:flutter/material.dart';

/// Widget displaying a single pending product upload in the queue.
///
/// Shows product details, retry count, failure reason, and action buttons
/// for retrying or deleting the pending upload.
class PendingUploadCard extends StatelessWidget {
  /// The pending upload to display
  final PendingProductUpload upload;

  /// Callback when the retry button is tapped
  final VoidCallback? onRetry;

  /// Callback when the delete button is tapped
  final VoidCallback? onDelete;

  /// Whether a retry operation is in progress
  final bool isRetrying;

  const PendingUploadCard({
    super.key,
    required this.upload,
    this.onRetry,
    this.onDelete,
    this.isRetrying = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Product name and status
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        upload.product.productName ?? 'Unknown Product',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Barcode: ${upload.product.barcode}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusBadge(context, isDarkMode),
              ],
            ),
            const SizedBox(height: 12),

            // Retry count display
            Row(
              children: [
                Icon(
                  Icons.repeat,
                  size: 16,
                  color: Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  'Attempt ${upload.retryCount + 1}/3',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Failure reason (if failed)
            if (upload.status == PendingUploadStatus.failed &&
                upload.failureReason != null) ...[
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: Colors.red.withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 16,
                      color: Colors.red,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        upload.failureReason!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.red,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Queued time
            Text(
              'Queued: ${_formatTime(upload.queuedAt)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 12),

            // Action buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: onDelete,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
                const SizedBox(width: 8),
                if (upload.canRetry)
                  ElevatedButton.icon(
                    onPressed: isRetrying ? null : onRetry,
                    icon: isRetrying
                        ? SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                theme.primaryColor,
                              ),
                            ),
                          )
                        : const Icon(Icons.refresh),
                    label: Text(isRetrying ? 'Retrying...' : 'Retry'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: theme.primaryColor,
                      foregroundColor: Colors.white,
                    ),
                  )
                else
                  Tooltip(
                    message: 'Maximum retries exceeded',
                    child: ElevatedButton.icon(
                      onPressed: null,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Retry'),
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Builds a status badge widget
  Widget _buildStatusBadge(BuildContext context, bool isDarkMode) {
    final theme = Theme.of(context);
    Color badgeColor;
    IconData badgeIcon;
    String badgeLabel;

    switch (upload.status) {
      case PendingUploadStatus.pending:
        badgeColor = Colors.blue;
        badgeIcon = Icons.schedule;
        badgeLabel = 'Pending';
        break;
      case PendingUploadStatus.uploading:
        badgeColor = Colors.amber;
        badgeIcon = Icons.cloud_upload;
        badgeLabel = 'Uploading';
        break;
      case PendingUploadStatus.failed:
        badgeColor = Colors.red;
        badgeIcon = Icons.error;
        badgeLabel = 'Failed';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: badgeColor,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            badgeIcon,
            size: 14,
            color: badgeColor,
          ),
          const SizedBox(width: 4),
          Text(
            badgeLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// Formats a DateTime to a readable string
  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }
}

import 'package:Warrior/core/services/sync.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Badge showing pending sync count.
class PendingSyncBadge extends ConsumerWidget {
  final Widget child;
  final bool showZero;

  const PendingSyncBadge({
    super.key,
    required this.child,
    this.showZero = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);
    final count = syncState.totalPending;

    if (count == 0 && !showZero) return child;

    return Badge(
      label: Text(count.toString()),
      isLabelVisible: count > 0 || showZero,
      backgroundColor: syncState.isLoading
          ? Theme.of(context).colorScheme.tertiary
          : Theme.of(context).colorScheme.error,
      child: child,
    );
  }
}

/// Indicator showing sync status with optional tap to trigger sync.
class SyncStatusIndicator extends ConsumerWidget {
  final bool compact;

  const SyncStatusIndicator({super.key, this.compact = false});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncState = ref.watch(syncServiceProvider);
    final colorScheme = Theme.of(context).colorScheme;

    if (!syncState.hasPendingItems && !syncState.isLoading) {
      return const SizedBox.shrink();
    }

    if (compact) {
      return _buildCompact(context, ref, syncState, colorScheme);
    }

    return _buildFull(context, ref, syncState, colorScheme);
  }

  Widget _buildCompact(
    BuildContext context,
    WidgetRef ref,
    SyncState syncState,
    ColorScheme colorScheme,
  ) {
    return GestureDetector(
      onTap: syncState.isLoading
          ? null
          : () =>
              ref.read(syncServiceProvider.notifier).syncPendingOperations(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: syncState.isLoading
              ? colorScheme.tertiaryContainer
              : colorScheme.errorContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (syncState.isLoading)
              SizedBox(
                width: 12,
                height: 12,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: colorScheme.onTertiaryContainer,
                ),
              )
            else
              Icon(
                Icons.cloud_upload_outlined,
                size: 14,
                color: colorScheme.onErrorContainer,
              ),
            const SizedBox(width: 4),
            Text(
              syncState.isLoading ? 'Syncing...' : '${syncState.totalPending}',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: syncState.isLoading
                    ? colorScheme.onTertiaryContainer
                    : colorScheme.onErrorContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFull(
    BuildContext context,
    WidgetRef ref,
    SyncState syncState,
    ColorScheme colorScheme,
  ) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: syncState.isLoading
            ? colorScheme.tertiaryContainer.withValues(alpha: 0.5)
            : colorScheme.errorContainer.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: syncState.isLoading
              ? colorScheme.tertiary.withValues(alpha: 0.3)
              : colorScheme.error.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          if (syncState.isLoading)
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: colorScheme.tertiary,
              ),
            )
          else
            Icon(
              Icons.cloud_off_rounded,
              size: 20,
              color: colorScheme.error,
            ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  syncState.isLoading
                      ? 'Syncing changes...'
                      : 'Changes pending sync',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.onSurface,
                  ),
                ),
                Text(
                  _buildStatusText(syncState),
                  style: TextStyle(
                    fontSize: 12,
                    color: colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (!syncState.isLoading)
            TextButton(
              onPressed: () => ref
                  .read(syncServiceProvider.notifier)
                  .syncPendingOperations(),
              child: const Text('Sync Now'),
            ),
        ],
      ),
    );
  }

  String _buildStatusText(SyncState state) {
    final parts = <String>[];
    if (state.pendingWorkouts > 0) {
      parts.add(
          '${state.pendingWorkouts} workout${state.pendingWorkouts > 1 ? 's' : ''}');
    }
    if (state.pendingProducts > 0) {
      parts.add(
          '${state.pendingProducts} product${state.pendingProducts > 1 ? 's' : ''}');
    }
    return parts.join(', ');
  }
}

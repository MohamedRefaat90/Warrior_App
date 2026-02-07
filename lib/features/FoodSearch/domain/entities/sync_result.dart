import 'package:equatable/equatable.dart';

/// Result of a synchronization operation.
///
/// Captures the outcome of syncing pending uploads, including counts of
/// successful/failed operations and any errors encountered.
class SyncResult extends Equatable {
  /// Total number of items synced.
  final int totalSynced;

  /// Number of items successfully synced.
  final int successCount;

  /// Number of items that failed to sync.
  final int failureCount;

  /// Whether the sync operation succeeded overall.
  final bool isSuccess;

  /// Error messages from failed syncs (if any).
  final List<String> errors;

  /// Timestamp when sync started.
  final DateTime startedAt;

  /// Timestamp when sync completed.
  final DateTime completedAt;

  const SyncResult({
    required this.totalSynced,
    required this.successCount,
    required this.failureCount,
    required this.isSuccess,
    List<String>? errors,
    required this.startedAt,
    required this.completedAt,
  }) : errors = errors ?? const [];

  /// Creates a successful sync result.
  factory SyncResult.success({
    required int totalSynced,
    required DateTime startedAt,
    required DateTime completedAt,
  }) {
    return SyncResult(
      totalSynced: totalSynced,
      successCount: totalSynced,
      failureCount: 0,
      isSuccess: true,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Creates a failed sync result.
  factory SyncResult.failure({
    required int successCount,
    required int failureCount,
    required List<String> errors,
    required DateTime startedAt,
    required DateTime completedAt,
  }) {
    return SyncResult(
      totalSynced: successCount + failureCount,
      successCount: successCount,
      failureCount: failureCount,
      isSuccess: false,
      errors: errors,
      startedAt: startedAt,
      completedAt: completedAt,
    );
  }

  /// Duration of the sync operation.
  Duration get duration => completedAt.difference(startedAt);

  /// Success rate as percentage (0-100).
  int get successPercentage =>
      totalSynced == 0 ? 0 : ((successCount / totalSynced) * 100).round();

  @override
  List<Object?> get props => [
        totalSynced,
        successCount,
        failureCount,
        isSuccess,
        errors,
        startedAt,
        completedAt
      ];
}

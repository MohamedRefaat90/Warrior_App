import 'package:hive_ce/hive.dart';

part 'pending_upload_status.g.dart';

/// Status enumeration for pending product uploads.
///
/// This Hive-compatible enum tracks the lifecycle of products being
/// uploaded when offline, allowing resume/retry logic.
@HiveType(typeId: 8)
enum PendingUploadStatus {
  /// Upload is queued and waiting to be sent.
  @HiveField(0)
  pending,

  /// Upload is currently in progress.
  @HiveField(1)
  uploading,

  /// Upload failed (eligible for retry if within retry limit).
  @HiveField(2)
  failed,
}

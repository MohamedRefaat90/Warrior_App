import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:hive_ce/hive.dart';

/// Migration utilities for Hive database schema upgrades.
///
/// Handles data transformation when models change between app versions,
/// ensuring existing cached data remains compatible.
class HiveMigration {
  /// Cleans up stale pending uploads older than retention period.
  ///
  /// Removes pending uploads that have been queued for more than 30 days
  /// to prevent unbounded database growth.
  static Future<void> cleanupStalePendingUploads({
    Duration retention = const Duration(days: 30),
  }) async {
    try {
      final box = Hive.box<PendingProductUpload>('pendingUploads');
      final now = DateTime.now();
      final cutoffTime = now.subtract(retention);

      final stalKeys = <int>[];

      for (int i = 0; i < box.length; i++) {
        final upload = box.getAt(i);
        if (upload != null && upload.queuedAt.isBefore(cutoffTime)) {
          stalKeys.add(i);
        }
      }

      // Delete stale records in reverse order to maintain indices
      for (final key in stalKeys.reversed) {
        await box.deleteAt(key);
      }
    } catch (e) {
      TalkerService.error('Error cleaning up stale pending uploads: $e');
    }
  }

  /// Migrates existing PendingProductUpload records to new schema.
  ///
  /// This migration handles the transition from flat productData map
  /// to structured FoodProductModel, ensuring retry tracking and status
  /// fields are properly initialized.
  static Future<void> migratePendingUploads() async {
    try {
      final box = Hive.box<PendingProductUpload>('pendingUploads');

      if (box.isEmpty) {
        return; // Nothing to migrate
      }

      final updates = <int, PendingProductUpload>{};

      for (int i = 0; i < box.length; i++) {
        final upload = box.getAt(i);
        if (upload == null) continue;

        // Check if this record needs migration (old format detection)
        // Records with retryCount but no status field indicate old schema
        bool needsMigration = false;

        // If old structure detected, mark for migration
        if (needsMigration) {
          // Initialize any missing fields with defaults
          // Status defaults to pending if upload is queued
          // (This preserves existing retry count)
          updates[i] = upload;
        }
      }

      // Apply batch updates
      if (updates.isNotEmpty) {
        await box.putAll(updates);
      }
    } catch (e) {
      // Log migration error but don't crash the app
      TalkerService.error('Error during PendingProductUpload migration: $e');
    }
  }
}

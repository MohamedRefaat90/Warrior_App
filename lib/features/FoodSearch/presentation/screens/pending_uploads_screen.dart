import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/data/repositories/food_repositories_provider.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/delete_pending_upload_usecase.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/get_pending_uploads_usecase.dart';
import 'package:Warrior/features/FoodSearch/domain/usecases/retry_pending_upload_usecase.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/empty_pending_uploads_widget.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/pending_upload_card.dart';

/// Provider for GetPendingUploadsUseCase
final getPendingUploadsUseCaseProvider =
    Provider<GetPendingUploadsUseCase>((ref) {
  final repository = ref.watch(productWriteRepositoryProvider);
  return GetPendingUploadsUseCase(repository: repository);
});

/// Provider for RetryPendingUploadUseCase
final retryPendingUploadUseCaseProvider =
    Provider<RetryPendingUploadUseCase>((ref) {
  final repository = ref.watch(productWriteRepositoryProvider);
  return RetryPendingUploadUseCase(repository: repository);
});

/// Provider for DeletePendingUploadUseCase
final deletePendingUploadUseCaseProvider =
    Provider<DeletePendingUploadUseCase>((ref) {
  final repository = ref.watch(productWriteRepositoryProvider);
  return DeletePendingUploadUseCase(repository: repository);
});

/// Async provider that fetches pending uploads
final pendingUploadsProvider =
    FutureProvider<List<PendingProductUpload>>((ref) async {
  final useCase = ref.watch(getPendingUploadsUseCaseProvider);
  return useCase();
});

/// Screen for viewing and managing pending product uploads.
///
/// Allows users to:
/// - View all queued products waiting to be synchronized
/// - Manually retry failed uploads
/// - Delete uploads from the queue
/// - Retry all eligible uploads at once
class PendingUploadsScreen extends ConsumerStatefulWidget {
  const PendingUploadsScreen({super.key});

  @override
  ConsumerState<PendingUploadsScreen> createState() =>
      _PendingUploadsScreenState();
}

class _PendingUploadsScreenState extends ConsumerState<PendingUploadsScreen> {
  final Set<String> _retryngUploads = {};

  @override
  Widget build(BuildContext context) {
    final pendingUploads = ref.watch(pendingUploadsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pending Uploads'),
        elevation: 0,
        actions: [
          // Retry All button
          pendingUploads.whenData((uploads) {
                final eligibleForRetry =
                    uploads.where((u) => u.canRetry).toList();
                final isAnyRetrying = _retryngUploads.isNotEmpty;

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Center(
                    child: eligibleForRetry.isNotEmpty && !isAnyRetrying
                        ? ElevatedButton.icon(
                            onPressed: () =>
                                _retryAll(context, ref, eligibleForRetry),
                            icon: const Icon(Icons.refresh),
                            label: const Text('Retry All'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blue,
                              foregroundColor: Colors.white,
                            ),
                          )
                        : isAnyRetrying
                            ? SizedBox(
                                width: 120,
                                child: Center(
                                  child: SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Theme.of(context).primaryColor,
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : const SizedBox.shrink(),
                  ),
                );
              }).value ??
              const SizedBox.shrink(),
        ],
      ),
      body: pendingUploads.when(
        data: (uploads) {
          if (uploads.isEmpty) {
            return const EmptyPendingUploadsWidget();
          }

          // Sort uploads by status (uploading first, then failed, then pending)
          final sortedUploads = _sortUploads(uploads);

          return ListView.builder(
            itemCount: sortedUploads.length,
            itemBuilder: (context, index) {
              final upload = sortedUploads[index];
              final isRetrying = _retryngUploads.contains(upload.id);

              return PendingUploadCard(
                upload: upload,
                isRetrying: isRetrying,
                onRetry: upload.canRetry
                    ? () => _handleRetry(context, ref, upload)
                    : null,
                onDelete: () => _handleDelete(context, ref, upload),
              );
            },
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stackTrace) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.error_outline,
                  size: 48,
                  color: Colors.red,
                ),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Uploads',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  error.toString(),
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () => ref.refresh(pendingUploadsProvider),
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Sorts uploads by status priority
  List<PendingProductUpload> _sortUploads(
    List<PendingProductUpload> uploads,
  ) {
    final sorted = [...uploads];
    sorted.sort((a, b) {
      // Priority: uploading > failed > pending
      const priorityMap = {
        PendingUploadStatus.uploading: 0,
        PendingUploadStatus.failed: 1,
        PendingUploadStatus.pending: 2,
      };

      final priorityA = priorityMap[a.status] ?? 3;
      final priorityB = priorityMap[b.status] ?? 3;

      if (priorityA != priorityB) {
        return priorityA.compareTo(priorityB);
      }

      // Within same status, sort by queued time (oldest first)
      return a.queuedAt.compareTo(b.queuedAt);
    });
    return sorted;
  }

  /// Handles retry for a single upload
  Future<void> _handleRetry(
    BuildContext context,
    WidgetRef ref,
    PendingProductUpload upload,
  ) async {
    try {
      setState(() {
        _retryngUploads.add(upload.id);
      });

      final retryUseCase = ref.read(retryPendingUploadUseCaseProvider);
      await retryUseCase(upload.id);

      // Refresh the list after retry
      // ignore: unawaited_futures,unused_result
      ref.refresh(pendingUploadsProvider);

      setState(() {
        _retryngUploads.remove(upload.id);
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Retrying "${upload.product.productName ?? 'Unknown Product'}"...',
          ),
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      setState(() {
        _retryngUploads.remove(upload.id);
      });
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Failed to retry upload'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Handles deletion with confirmation dialog
  Future<void> _handleDelete(
    BuildContext context,
    WidgetRef ref,
    PendingProductUpload upload,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove from Queue?'),
        content: Text(
          'Are you sure you want to remove "${upload.product.productName ?? 'Unknown Product'}" '
          'from the upload queue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );

    if (shouldDelete == true) {
      try {
        final deleteUseCase = ref.read(deletePendingUploadUseCaseProvider);
        await deleteUseCase(upload.id);

        // Refresh the list after deletion
        // ignore: unawaited_futures,unused_result
        ref.refresh(pendingUploadsProvider);

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Upload removed from queue'),
            duration: Duration(seconds: 2),
          ),
        );
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Failed to remove upload'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Handles retry for all eligible uploads
  Future<void> _retryAll(
    BuildContext context,
    WidgetRef ref,
    List<PendingProductUpload> uploads,
  ) async {
    final retryUseCase = ref.read(retryPendingUploadUseCaseProvider);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Retrying ${uploads.length} upload${uploads.length == 1 ? '' : 's'}...',
        ),
        duration: const Duration(seconds: 3),
      ),
    );

    int succeeded = 0;
    int failed = 0;

    for (final upload in uploads) {
      try {
        setState(() {
          _retryngUploads.add(upload.id);
        });
        await retryUseCase(upload.id);
        succeeded++;
      } catch (e) {
        failed++;
      } finally {
        setState(() {
          _retryngUploads.remove(upload.id);
        });
      }
    }

    // Refresh the list after all retries
    // ignore: unawaited_futures,unused_result
    ref.refresh(pendingUploadsProvider);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Completed: $succeeded succeeded${failed > 0 ? ', $failed failed' : ''}',
        ),
        backgroundColor: failed == 0 ? Colors.green : Colors.orange,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

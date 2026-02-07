import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';

/// Use case for retrying a pending product upload.
///
/// Attempts to resend a previously failed product upload to the server.
/// Increments the retry count and updates the status accordingly.
class RetryPendingUploadUseCase {
  final ProductWriteRepository repository;

  RetryPendingUploadUseCase({required this.repository});

  /// Retries uploading the specified pending upload.
  ///
  /// Parameters:
  ///   - [uploadId]: The unique identifier of the pending upload to retry
  ///
  /// Returns the updated [PendingProductUpload] after retry attempt.
  ///
  /// Throws [Exception] if the upload doesn't exist or has exceeded max retries.
  Future<PendingProductUpload> call(String uploadId) async {
    return repository.retryPendingUpload(uploadId);
  }
}

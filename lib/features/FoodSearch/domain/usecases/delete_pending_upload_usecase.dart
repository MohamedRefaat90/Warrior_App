import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';

/// Use case for deleting a pending product upload.
///
/// Removes a queued product submission from the upload queue, typically
/// when a user decides not to sync a particular product anymore.
class DeletePendingUploadUseCase {
  final ProductWriteRepository repository;

  DeletePendingUploadUseCase({required this.repository});

  /// Deletes the specified pending upload from the queue.
  ///
  /// Parameters:
  ///   - [uploadId]: The unique identifier of the pending upload to delete
  ///
  /// Throws [Exception] if the upload doesn't exist.
  Future<void> call(String uploadId) async {
    return repository.deletePendingUpload(uploadId);
  }
}

import 'package:Warrior/features/FoodSearch/data/models/pending_product_upload.dart';
import 'package:Warrior/features/FoodSearch/domain/repositories/product_write_repository.dart';

/// Use case for retrieving pending product uploads.
///
/// Fetches all products in the upload queue that are waiting to be
/// synchronized to the server.
class GetPendingUploadsUseCase {
  final ProductWriteRepository repository;

  GetPendingUploadsUseCase({required this.repository});

  /// Retrieves all pending uploads from the repository.
  ///
  /// Returns a list of [PendingProductUpload] objects sorted by
  /// queue time (oldest first).
  Future<List<PendingProductUpload>> call() async {
    return repository.getPendingProductUploads();
  }
}

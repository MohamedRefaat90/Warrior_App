import 'package:hive/hive.dart';

part 'product_data_source.g.dart';

/// Source enumeration for product data.
///
/// Tracks where product information came from, enabling intelligent
/// prioritization and conflict resolution in the offline-first system.
@HiveType(typeId: 9)
enum ProductDataSource {
  /// Product fetched from OpenFoodFacts API.
  @HiveField(0)
  openFoodFacts,

  /// Product manually entered by user.
  @HiveField(1)
  userManual,

  /// Product extracted from image OCR.
  @HiveField(2)
  ocrExtracted,

  /// Product data cached locally.
  @HiveField(3)
  cached,
}

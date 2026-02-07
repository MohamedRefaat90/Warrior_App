# Contract: OpenFoodFacts API Integration

**Feature**: 001-food-search-polish  
**Version**: 1.0.0  
**Date**: 2026-02-07  
**API Documentation**: https://wiki.openfoodfacts.org/API  
**Package**: [openfoodfacts ^3.27.0](https://pub.dev/packages/openfoodfacts)

## Overview

This contract defines the integration requirements with OpenFoodFacts API using the **existing `openfoodfacts` Dart package** (v3.27.0) already in the project. The package provides `OpenFoodAPIClient`, `Product`, `User`, `Status`, and other models - we leverage these rather than creating custom implementations.

---

## Package Usage

### Already Integrated

The project uses `openfoodfacts: ^3.27.0` in `pubspec.yaml` and throughout the FoodSearch feature:

**Existing Usage**:
- `FoodRemoteDataSource`: Uses `OpenFoodAPIClient` for all API calls
- `FoodProductModel`: Has `fromOpenFoodFactsProduct()` and `toOpenFoodFactsProduct()` converters
- `ProductWriteRepositoryImpl`: Converts domain entities to `Product` from package

**Key Package Classes**:
```dart
import 'package:openfoodfacts/openfoodfacts.dart';

// Already used in codebase:
- OpenFoodAPIClient           // API client
- Product                     // Product model
- User                        // User credentials
- Status                      // Response status
- ProductSearchQueryConfiguration
- SearchResult
- ProductField                // Field selection
- OpenFoodFactsLanguage       // Language codes
- ImageField                  // Image upload types
```

---

## API Contract: Get Product by Barcode

### Using OpenFoodAPIClient.getProductV3()

**Package Method**: `OpenFoodAPIClient.getProductV3()`

```dart
import 'package:openfoodfacts/openfoodfacts.dart';

Future<Product?> getProductByBarcode(String barcode) async {
  final ProductQueryConfiguration configuration = ProductQueryConfiguration(
    barcode,
    language: OpenFoodFactsLanguage.ENGLISH,
    fields: [ProductField.ALL], // Or specify needed fields
    version: ProductQueryVersion.v3,
  );
  
  final ProductResultV3 result = 
      await OpenFoodAPIClient.getProductV3(configuration);
  
  if (result.status == ProductResultV3.statusSuccess && result.product != null) {
    return result.product;
  }
  
  return null; // Product not found or error
}
```

### Response Handling

**Success**: `result.status == ProductResultV3.statusSuccess` and `result.product != null`  
**Not Found**: `result.status != ProductResultV3.statusSuccess` or `result.product == null`  
**Error**: Check `result.statusVerbose` for error message

**Product Model** (from package):
```dart
class Product {
  String? barcode;           // EAN/UPC code
  String? productName;       // Product name
  String? brands;            // Brand names
  String? quantity;          // Quantity (e.g., "330ml")
  String? imageFrontUrl;     // Product image URL
  Nutriments? nutriments;    // Nutrition data
  // ... many other fields
}
```

---

## API Contract: Add/Update Product

### Using OpenFoodAPIClient.saveProduct()

**Package Method**: `OpenFoodAPIClient.saveProduct()`

```dart
import 'package:openfoodfacts/openfoodfacts.dart';

Future<bool> addOrUpdateProduct(Product product, User user) async {
  final Status result = await OpenFoodAPIClient.saveProduct(user, product);
  
  if (result.status == 1) {
    // Success
    return true;
  } else {
    // Failure - check result.error for details
    throw Exception(result.error ?? 'Failed to save product');
  }
}
```

### User Credentials

**Package Model**: `User` class

```dart
// Get user from credentials service (already implemented)
final User user = await OpenFoodFactsCredentialsService.getUser();

// User model contains:
// - userId: String
// - password: String
// - comment: String? (optional)
```

### Product Model Setup

```dart
// Convert from domain entity to openfoodfacts Product
final Product product = Product(
  barcode: '5449000000996',
  productName: 'Coca-Cola',
  brands: 'Coca-Cola',
  quantity: '330ml',
  // Nutrition data
  nutriments: Nutriments(
    energyKcal100g: 42,
    proteins100g: 0,
    carbohydrates100g: 10.6,
    sugars100g: 10.6,
    fat100g: 0,
    fiber100g: 0,
    sodium100g: 0.01,
  ),
);

// Already implemented in FoodProductModel:
// - fromOpenFoodFactsProduct(Product product)
// - toOpenFoodFactsProduct() -> Product
```

### Image Upload

**Package Method**: `OpenFoodAPIClient.addProductImage()`

```dart
Future<void> uploadProductImage({
  required String barcode,
  required String imagePath,
  required ImageField imageField, // FRONT, INGREDIENTS, NUTRITION, etc.
  required User user,
}) async {
  final SendImage image = SendImage(
    lang: OpenFoodFactsLanguage.ENGLISH,
    barcode: barcode,
    imageField: imageField,
    imageUri: Uri.file(imagePath),
  );
  
  final Status result = await OpenFoodAPIClient.addProductImage(user, image);
  
  if (result.status != 1) {
    throw Exception(result.error ?? 'Failed to upload image');
  }
}
```

### Status Response

**Package Model**: `Status` class

```dart
class Status {
  int? status;        // 1 = success, 0 = error
  String? error;      // Error message if status == 0
  String? statusVerbose; // Detailed status message
}
```

---

## Error Handling Contract

### Error Categories

The `openfoodfacts` package uses standard Dart/Flutter error handling. We wrap it with our domain-specific failures:

| Category | Detection | Handling Strategy | User Message |
|----------|-----------|-------------------|--------------|
| Network Error | `SocketException`, `DioException` | Queue for retry | "No internet connection. Changes saved offline." |
| Timeout | HTTP timeout, `DioException` | Queue for retry | "Request timed out. Will retry automatically." |
| Not Found | `result.product == null` | Allow user to add | "Product not found. Would you like to add it?" |
| Invalid Input | `result.status == 0` | Show validation errors | "Invalid data: {result.error}" |
| Server Error | HTTP 500-599 | Queue for retry | "Server error. Will retry automatically." |
| Rate Limited | HTTP 429 | Exponential backoff | "Too many requests. Please wait." |

### Implementation

**Already Implemented Error Handling** in `ProductWriteRepositoryImpl`:

```dart
// From existing codebase
Future<bool> submitProduct({
  required ProductEntity product,
  required User user,
  String? imagePath,
  bool isUpdate = false,
}) async {
  try {
    // Convert to openfoodfacts Product
    final Product offProduct = 
        FoodProductModel.fromEntity(product).toOpenFoodFactsProduct();
    
    if (ConnectivityChecker.isOnline == true) {
      final success = isUpdate
          ? await _remoteDataSource.updateProduct(offProduct, user)
          : await _remoteDataSource.addNewProduct(offProduct, user);
      
      if (success) {
        return true;
      }
      
      // Failed - queue for retry
      await _enqueuePendingProduct(
        product: offProduct,
        imagePath: imagePath,
        isUpdate: isUpdate,
      );
      return false;
    } else {
      // Offline - queue immediately
      await _enqueuePendingProduct(
        product: offProduct,
        imagePath: imagePath,
        isUpdate: isUpdate,
      );
      return false;
    }
  } catch (e, stackTrace) {
    TalkerService.error(
      'Error submitting product',
      'FOOD_WRITE_REPO',
      e,
      stackTrace,
    );
    
    // Queue on any error
    await _enqueuePendingProduct(
      product: FoodProductModel.fromEntity(product).toOpenFoodFactsProduct(),
      imagePath: imagePath,
      isUpdate: isUpdate,
    );
    return false;
  }
}
```

### Enhanced Error Handler (for polish)

Add granular error categorization:

```dart
class OpenFoodFactsErrorHandler {
  static ProductSubmissionFailure handleError(Object error, StackTrace stackTrace) {
    if (error is SocketException || error.toString().contains('Network')) {
      return ProductSubmissionFailure.network(
        message: 'No internet connection. Changes saved offline.',
        canRetry: true,
      );
    }
    
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.connectionTimeout:
        case DioExceptionType.sendTimeout:
        case DioExceptionType.receiveTimeout:
          return ProductSubmissionFailure.timeout(
            message: 'Request timed out. Will retry automatically.',
            canRetry: true,
          );
        
        case DioExceptionType.connectionError:
          return ProductSubmissionFailure.network(
            message: 'No internet connection. Changes saved offline.',
            canRetry: true,
          );
        
        case DioExceptionType.badResponse:
          final statusCode = error.response?.statusCode;
          if (statusCode == 429) {
            return ProductSubmissionFailure.rateLimited(
              message: 'Too many requests. Please wait.',
              canRetry: true,
            );
          }
          if (statusCode != null && statusCode >= 500) {
            return ProductSubmissionFailure.serverError(
              message: 'Server error. Will retry automatically.',
              canRetry: true,
            );
          }
          break;
        
        default:
          break;
      }
    }
    
    // Check if Status response indicates error
    if (error is Exception && error.toString().contains('status')) {
      return ProductSubmissionFailure.invalidInput(
        message: error.toString(),
        canRetry: false,
      );
    }
    
    return ProductSubmissionFailure.unknown(
      message: error.toString(),
      canRetry: false,
    );
  }
}

class ProductSubmissionFailure {
  final String message;
  final bool canRetry;
  final String errorType;
  
  const ProductSubmissionFailure({
    required this.message,
    required this.canRetry,
    required this.errorType,
  });
  
  factory ProductSubmissionFailure.network({
    required String message,
    required bool canRetry,
  }) =>
      ProductSubmissionFailure(
        message: message,
        canRetry: canRetry,
        errorType: 'network',
      );
  
  factory ProductSubmissionFailure.timeout({
    required String message,
    required bool canRetry,
  }) =>
      ProductSubmissionFailure(
        message: message,
        canRetry: canRetry,
        errorType: 'timeout',
      );
  
  factory ProductSubmissionFailure.serverError({
    required String message,
    required bool canRetry,
  }) =>
      ProductSubmissionFailure(
        message: message,
        canRetry: canRetry,
        errorType: 'server',
      );
  
  factory ProductSubmissionFailure.rateLimited({
    required String message,
    required bool canRetry,
  }) =>
      ProductSubmissionFailure(
        message: message,
        canRetry: canRetry,
        errorType: 'rate_limited',
      );
  
  factory ProductSubmissionFailure.invalidInput({
    required String message,
    required bool canRetry,
  }) =>
      ProductSubmissionFailure(
        message: message,
        canRetry: canRetry,
        errorType: 'invalid_input',
      );
  
  factory ProductSubmissionFailure.unknown({
    required String message,
    required bool canRetry,
  }) =>
      ProductSubmissionFailure(
        message: message,
        canRetry: canRetry,
        errorType: 'unknown',
      );
}
```

---

## Offline Behavior Contract

### Queue Management

**Already Implemented** in `ProductWriteRepositoryImpl` using `PendingProductUpload` model and Hive storage.

**Rule 1**: All product submissions when offline are queued in Hive ✅

```dart
// From existing codebase
Future<void> _enqueuePendingProduct({
  required Product product,
  NutritionValuesModel? nutrition,
  String? imagePath,
  bool isUpdate = false,
}) async {
  final pending = PendingProductUpload(
    product: FoodProductModel.fromOpenFoodFactsProduct(product),
    queuedAt: DateTime.now(),
    imagePath: imagePath,
    isUpdate: isUpdate,
  );
  
  final box = await HiveManager.getPendingProductUploadsBox();
  await box.add(pending);
  
  TalkerService.info(
    'Product queued for upload: ${product.barcode}',
    'FOOD_WRITE_REPO',
  );
}
```

**Rule 2**: Queued items persist across app restarts (Hive storage) ✅

**Rule 3**: Max 3 retry attempts per queued item ⚠️ **TO BE IMPLEMENTED** in polish

### Retry Strategy

**TO BE IMPLEMENTED** - Add retry tracking to `PendingProductUpload`:

```dart
// Enhancement to existing model
@HiveType(typeId: 7)
class PendingProductUpload extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final FoodProductModel product;
  
  @HiveField(2)
  final DateTime queuedAt;
  
  @HiveField(3)
  final String? imagePath;
  
  @HiveField(4)
  final bool isUpdate;
  
  @HiveField(5) // NEW
  int retryCount; // 0-3
  
  @HiveField(6) // NEW
  PendingUploadStatus status; // pending, uploading, failed
  
  @HiveField(7) // NEW
  DateTime? lastAttemptAt;
  
  @HiveField(8) // NEW
  String? failureReason;
  
  bool get canRetry => retryCount < 3;
}
```

**Exponential Backoff**:
- Attempt 1: Immediate (when connectivity restored)
- Attempt 2: After 5 seconds
- Attempt 3: After 15 seconds
- After 3 failures: Mark as permanently failed, notify user

### Cache Strategy

**Already Implemented** in existing repositories with Hive caching.

**Rule 1**: Cache GET responses for 7 days ✅ (check TTL implementation)

**Rule 2**: Show cached data immediately, then refresh ✅

**Rule 3**: Display cache age indicator ⚠️ **TO BE IMPLEMENTED** in polish

**Enhancement for Polish**:

```dart
// Add to FoodProductModel
@HiveField(20) // NEW
DateTime? cachedAt;

@HiveField(21) // NEW
ProductDataSource source; // cache, remote, local_submission

bool get isCacheFresh {
  if (cachedAt == null) return false;
  final age = DateTime.now().difference(cachedAt!);
  return age.inDays <= 7;
}

Duration? get cacheAge {
  if (cachedAt == null) return null;
  return DateTime.now().difference(cachedAt!);
}
```

---

## Manual Sync Contract

### Trigger

**Method**: User taps "Sync Pending Uploads" button in Pending Uploads screen (new screen to be added).

**Pre-conditions**:
- At least 1 pending upload exists
- No sync currently in progress

### Process (To Be Implemented)

1. **Check connectivity**: Abort if offline with error message
2. **Lock sync**: Prevent concurrent sync operations
3. **Process queue**: Iterate through pending uploads (FIFO order)
4. **Upload each item**:
   - Convert `PendingProductUpload.product` (FoodProductModel) to `Product` using `.toOpenFoodFactsProduct()`
   - Call `OpenFoodAPIClient.saveProduct(user, product)`
   - If `result.status == 1`: Remove from queue
   - If failure: Increment retry count, update status
   - If retry count >= 3: Mark as permanently failed
5. **Release lock**: Allow future syncs
6. **Notify user**: Show local notification with results

### Implementation

```dart
class SyncPendingUploadsUseCase {
  final FoodRemoteDataSource _remoteDataSource;
  final User _user;
  bool _syncInProgress = false;
  
  Future<SyncResult> execute() async {
    final startTime = DateTime.now();
    
    // 1. Check connectivity
    if (!ConnectivityChecker.isOnline) {
      throw SyncException('No internet connection');
    }
    
    // 2. Check sync lock
    if (_syncInProgress) {
      throw SyncException('Sync already in progress');
    }
    
    _syncInProgress = true;
    
    try {
      // 3. Get pending uploads
      final pendingUploads = HiveManager.getPendingProductUploads();
      final results = <String, bool>{};
      final failedUploads = <PendingProductUpload>[];
      
      // 4. Process each upload
      for (final upload in pendingUploads) {
        if (!upload.canRetry) {
          // Skip items that exceeded retry limit
          failedUploads.add(upload);
          continue;
        }
        
        try {
          // Convert to openfoodfacts Product
          final Product product = upload.product.toOpenFoodFactsProduct();
          
          // Attempt upload using package
          final Status status = upload.isUpdate
              ? await _remoteDataSource.updateProduct(product, _user)
              : await _remoteDataSource.addNewProduct(product, _user);
          
          if (status.status == 1) {
            // Success - remove from queue
            await upload.delete();
            results[upload.id] = true;
            
            // Upload image if present
            if (upload.imagePath != null) {
              await _uploadImage(
                barcode: product.barcode!,
                imagePath: upload.imagePath!,
                user: _user,
              );
            }
          } else {
            throw Exception(status.error ?? 'Upload failed');
          }
        } catch (e) {
          // Failure - increment retry count
          upload.retryCount++;
          upload.status = PendingUploadStatus.failed;
          upload.lastAttemptAt = DateTime.now();
          upload.failureReason = e.toString();
          await upload.save();
          
          results[upload.id] = false;
          failedUploads.add(upload);
        }
      }
      
      // 5. Calculate summary
      final successCount = results.values.where((success) => success).length;
      final failureCount = results.values.where((success) => !success).length;
      
      final syncDuration = DateTime.now().difference(startTime);
      
      return SyncResult(
        totalAttempted: pendingUploads.length,
        successCount: successCount,
        failureCount: failureCount,
        failedUploads: failedUploads,
        syncDuration: syncDuration,
      );
    } finally {
      _syncInProgress = false;
    }
  }
  
  Future<void> _uploadImage({
    required String barcode,
    required String imagePath,
    required User user,
  }) async {
    final SendImage image = SendImage(
      lang: OpenFoodFactsLanguage.ENGLISH,
      barcode: barcode,
      imageField: ImageField.FRONT,
      imageUri: Uri.file(imagePath),
    );
    
    await OpenFoodAPIClient.addProductImage(user, image);
  }
}
```

---

## Test Requirements

### Integration Test: Full Upload Flow with openfoodfacts Package

```dart
testWidgets('Product upload queues offline and syncs when online', (tester) async {
  // Setup: Mock user
  final mockUser = User(userId: 'test_user', password: '');
  
  // 1. Setup: Go offline
  ConnectivityChecker.isOnline = false;
  
  // 2. Act: Submit product
  await tester.pumpWidget(MyApp());
  await tester.enterText(find.byKey(Key('barcode_field')), '5449000000996');
  await tester.enterText(find.byKey(Key('name_field')), 'Test Product');
  await tester.tap(find.byKey(Key('submit_button')));
  await tester.pumpAndSettle();
  
  // 3. Assert: Product queued in Hive
  final pendingUploads = HiveManager.getPendingProductUploads();
  expect(pendingUploads.length, 1);
  expect(pendingUploads.first.product.barcode, '5449000000996');
  
  // 4. Act: Go online and sync
  ConnectivityChecker.isOnline = true;
  await tester.tap(find.byKey(Key('pending_uploads_tab')));
  await tester.pumpAndSettle();
  await tester.tap(find.byKey(Key('sync_button')));
  await tester.pumpAndSettle();
  
  // 5. Assert: Queue empty (upload succeeded)
  final afterSync = HiveManager.getPendingProductUploads();
  expect(afterSync.length, 0);
  
  // 6. Assert: Success notification shown
  expect(find.text('1 product uploaded successfully'), findsOneWidget);
});
```

### Unit Test: Product Conversion

```dart
test('FoodProductModel converts to openfoodfacts Product correctly', () {
  // Arrange
  final foodModel = FoodProductModel(
    barcode: '5449000000996',
    productName: 'Test Product',
    brand: 'Test Brand',
    quantity: '330ml',
    // ... other fields
  );
  
  // Act
  final Product offProduct = foodModel.toOpenFoodFactsProduct();
  
  // Assert
  expect(offProduct.barcode, '5449000000996');
  expect(offProduct.productName, 'Test Product');
  expect(offProduct.brands, 'Test Brand');
  expect(offProduct.quantity, '330ml');
});

test('FoodProductModel creates from openfoodfacts Product correctly', () {
  // Arrange
  final Product offProduct = Product(
    barcode: '5449000000996',
    productName: 'Test Product',
    brands: 'Test Brand',
    quantity: '330ml',
  );
  
  // Act
  final foodModel = FoodProductModel.fromOpenFoodFactsProduct(offProduct);
  
  // Assert
  expect(foodModel.barcode, '5449000000996');
  expect(foodModel.productName, 'Test Product');
  expect(foodModel.brand, 'Test Brand');
  expect(foodModel.quantity, '330ml');
});
```

---

## Summary

| Contract | Package Integration | Key Requirements |
|----------|---------------------|------------------|
| Get Product | `OpenFoodAPIClient.getProductV3()` | Uses `ProductQueryConfiguration`, returns `Product` |
| Add Product | `OpenFoodAPIClient.saveProduct()` | Uses `Product` and `User` models, returns `Status` |
| Image Upload | `OpenFoodAPIClient.addProductImage()` | Uses `SendImage` model with `ImageField` |
| Error Handling | Wrap package exceptions | 5 error types, retry strategy, user messages |
| Offline Queue | Existing Hive implementation | Enhance with retry tracking (3 max) |
| Cache Strategy | Existing repositories | Add cache metadata (cachedAt, source) |
| Manual Sync | New use case | Leverage existing conversions (toOpenFoodFactsProduct) |

**Package Dependency**: ✅ `openfoodfacts: ^3.27.0` (already in pubspec.yaml)

**Existing Integrations to Leverage**:
- ✅ `FoodRemoteDataSource` uses `OpenFoodAPIClient`
- ✅ `FoodProductModel` has conversion methods
- ✅ `ProductWriteRepositoryImpl` has queue logic
- ✅ `OpenFoodFactsCredentialsService.getUser()` provides `User`

**Enhancements Required**:
- Add retry tracking to `PendingProductUpload`
- Add cache metadata to `FoodProductModel`
- Create `SyncPendingUploadsUseCase`
- Add `ProductSubmissionFailure` error types
- Add offline indicator UI components

**Next**: Reference this contract when implementing FoodSearch polish feature.

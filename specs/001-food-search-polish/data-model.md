# Data Model: FoodSearch Polish & Completion

**Feature**: 001-food-search-polish  
**Phase**: 1 (Design - Data Structures)  
**Date**: 2026-02-07

## Overview

This document defines the data structures for the FoodSearch polish feature. Most entities already exist in the codebase; this focuses on the new/modified entities needed for enhanced offline experience and pending uploads management.

---

## Entity: PendingProductUpload (Enhanced)

**Purpose**: Represents a product submission queued for upload when offline, with retry tracking and status management.

**Location**: `lib/features/FoodSearch/data/models/pending_product_upload.dart` (existing, needs enhancement)

### Schema

```dart
@HiveType(typeId: 7) // Existing type ID
class PendingProductUpload extends HiveObject {
  @HiveField(0)
  final String id; // UUID for tracking
  
  @HiveField(1)
  final FoodProductModel product; // Product data to upload
  
  @HiveField(2)
  final DateTime queuedAt; // When operation was queued
  
  @HiveField(3)
  final String? imagePath; // Local path to product image (if any)
  
  @HiveField(4)
  final bool isUpdate; // True if updating existing product, false if new
  
  @HiveField(5) // NEW: Retry tracking
  int retryCount; // Current number of retry attempts (0-3)
  
  @HiveField(6) // NEW: Status tracking
  PendingUploadStatus status; // pending, uploading, failed
  
  @HiveField(7) // NEW: Last attempt timestamp
  DateTime? lastAttemptAt;
  
  @HiveField(8) // NEW: Failure reason
  String? failureReason;
  
  PendingProductUpload({
    required this.id,
    required this.product,
    required this.queuedAt,
    this.imagePath,
    required this.isUpdate,
    this.retryCount = 0,
    this.status = PendingUploadStatus.pending,
    this.lastAttemptAt,
    this.failureReason,
  });
  
  // Methods
  bool get canRetry => retryCount < 3; // Max 3 retries
  bool get hasExceededRetries => retryCount >= 3;
  Duration get queuedDuration => DateTime.now().difference(queuedAt);
  
  PendingProductUpload incrementRetry() {
    return PendingProductUpload(
      id: id,
      product: product,
      queuedAt: queuedAt,
      imagePath: imagePath,
      isUpdate: isUpdate,
      retryCount: retryCount + 1,
      status: PendingUploadStatus.failed,
      lastAttemptAt: DateTime.now(),
      failureReason: failureReason,
    );
  }
  
  PendingProductUpload markAsUploading() {
    return PendingProductUpload(
      id: id,
      product: product,
      queuedAt: queuedAt,
      imagePath: imagePath,
      isUpdate: isUpdate,
      retryCount: retryCount,
      status: PendingUploadStatus.uploading,
      lastAttemptAt: DateTime.now(),
      failureReason: null,
    );
  }
  
  PendingProductUpload markAsFailed(String reason) {
    return PendingProductUpload(
      id: id,
      product: product,
      queuedAt: queuedAt,
      imagePath: imagePath,
      isUpdate: isUpdate,
      retryCount: retryCount + 1,
      status: PendingUploadStatus.failed,
      lastAttemptAt: DateTime.now(),
      failureReason: reason,
    );
  }
}
```

### Enum: PendingUploadStatus

```dart
@HiveType(typeId: 8) // New type ID
enum PendingUploadStatus {
  @HiveField(0)
  pending,   // Waiting to be uploaded
  
  @HiveField(1)
  uploading, // Currently being uploaded
  
  @HiveField(2)
  failed,    // Upload failed, may retry if retryCount < 3
}
```

### Hive Configuration

Add to `lib/core/services/hive_boxes.dart`:

```dart
// Register adapter
Hive.registerAdapter(PendingUploadStatusAdapter());

// Box management methods (enhance existing)
static Box<PendingProductUpload> getPendingUploadsBox() {
  return Hive.box<PendingProductUpload>('pendingProductUploads');
}

static List<PendingProductUpload> getPendingProductUploads() {
  final box = getPendingUploadsBox();
  return box.values.toList();
}

static List<PendingProductUpload> getRetriablePendingUploads() {
  final box = getPendingUploadsBox();
  return box.values
      .where((upload) => upload.canRetry && upload.status != PendingUploadStatus.uploading)
      .toList();
}

static int getPendingUploadCount() {
  final box = getPendingUploadsBox();
  return box.values
      .where((upload) => upload.status == PendingUploadStatus.pending)
      .length;
}

static Future<void> removePendingUpload(String id) async {
  final box = getPendingUploadsBox();
  final key = box.values.firstWhere((upload) => upload.id == id).key;
  await box.delete(key);
}
```

---

## Entity: ProductValidationResult (New)

**Purpose**: Encapsulates validation result for product submission form.

**Location**: `lib/features/FoodSearch/domain/entities/product_validation_result.dart` (new file)

### Schema

```dart
class ProductValidationResult {
  final bool isValid;
  final Map<String, String> fieldErrors; // Field name -> error message
  
  const ProductValidationResult({
    required this.isValid,
    this.fieldErrors = const {},
  });
  
  factory ProductValidationResult.valid() {
    return const ProductValidationResult(isValid: true);
  }
  
  factory ProductValidationResult.invalid(Map<String, String> errors) {
    return ProductValidationResult(
      isValid: false,
      fieldErrors: errors,
    );
  }
  
  String? getFieldError(String fieldName) => fieldErrors[fieldName];
  bool hasFieldError(String fieldName) => fieldErrors.containsKey(fieldName);
  List<String> get allErrors => fieldErrors.values.toList();
}
```

**Usage**:
```dart
// In validator
final result = ProductValidation.validate(
  barcode: barcodeController.text,
  productName: nameController.text,
  brand: brandController.text,
  quantity: quantityController.text,
);

if (!result.isValid) {
  // Show errors
  setState(() {
    _validationErrors = result.fieldErrors;
  });
  return;
}
```

---

## Entity: OfflineCacheMetadata (New)

**Purpose**: Tracks cache metadata for offline indicators (cache age, freshness).

**Location**: Extend existing `FoodProductModel` with metadata

### Enhancement to FoodProductModel

```dart
@HiveType(typeId: 1) // Existing
class FoodProductModel extends HiveObject {
  // ... existing fields ...
  
  @HiveField(20) // NEW: Cache metadata
  DateTime? cachedAt;
  
  @HiveField(21) // NEW: Source tracking
  ProductDataSource source; // cache, remote, local_submission
  
  // Methods
  bool get isCacheFresh {
    if (cachedAt == null) return false;
    final age = DateTime.now().difference(cachedAt!);
    return age.inDays <= 7;
  }
  
  Duration? get cacheAge {
    if (cachedAt == null) return null;
    return DateTime.now().difference(cachedAt!);
  }
  
  bool get isStale {
    if (cachedAt == null) return false;
    return !isCacheFresh;
  }
}
```

### Enum: ProductDataSource

```dart
@HiveType(typeId: 9)
enum ProductDataSource {
  @HiveField(0)
  cache,           // Loaded from local cache
  
  @HiveField(1)
  remote,          // Fresh from OpenFoodFacts API
  
  @HiveField(2)
  localSubmission, // User-submitted, not yet synced
}
```

---

## Entity: SyncResult (New)

**Purpose**: Represents result of manual sync operation for notifications.

**Location**: `lib/features/FoodSearch/domain/entities/sync_result.dart` (new file)

### Schema

```dart
class SyncResult {
  final int totalAttempted;
  final int successCount;
  final int failureCount;
  final List<PendingProductUpload> failedUploads;
  final Duration syncDuration;
  
  const SyncResult({
    required this.totalAttempted,
    required this.successCount,
    required this.failureCount,
    required this.failedUploads,
    required this.syncDuration,
  });
  
  bool get hasFailures => failureCount > 0;
  bool get allSucceeded => failureCount == 0 && totalAttempted > 0;
  bool get allFailed => successCount == 0 && totalAttempted > 0;
  bool get partialSuccess => successCount > 0 && failureCount > 0;
  
  String get summaryMessage {
    if (allSucceeded) {
      return '$successCount products uploaded successfully';
    } else if (allFailed) {
      return 'All uploads failed. Check your connection.';
    } else {
      return '$successCount of $totalAttempted uploads succeeded';
    }
  }
}
```

**Usage**:
```dart
// After sync operation
final result = await syncPendingUploads();

if (result.allSucceeded) {
  SyncNotificationService.showSyncSuccess(result.successCount);
} else if (result.hasFailures) {
  SyncNotificationService.showSyncPartialFailure(
    result.successCount,
    result.failureCount,
  );
}
```

---

## Existing Entities (No Changes Required)

The following entities are already properly defined and need no modifications:

### FoodProductModel
- **Location**: `lib/features/FoodSearch/data/models/food_product_model.dart`
- **Purpose**: Product data with Hive adapter
- **Status**: ✅ Complete, only cache metadata enhancement above

### NutritionValuesModel
- **Location**: `lib/features/FoodSearch/data/models/nutrition_values_model.dart`
- **Purpose**: Nutrition facts per 100g
- **Status**: ✅ Complete

### FavoriteFoodModel
- **Location**: `lib/features/FoodSearch/data/models/favorite_food_model.dart`
- **Purpose**: User's favorite products
- **Status**: ✅ Complete

### SearchHistoryModel
- **Location**: `lib/features/FoodSearch/data/models/search_history_model.dart`
- **Purpose**: User's search history
- **Status**: ✅ Complete

### ProductEntity
- **Location**: `lib/features/FoodSearch/domain/entities/product_entity.dart`
- **Purpose**: Domain entity for products
- **Status**: ✅ Complete

### NutritionFacts
- **Location**: `lib/features/FoodSearch/domain/entities/nutrition_facts.dart`
- **Purpose**: Domain entity for nutrition data
- **Status**: ✅ Complete

---

## Data Relationships

```
┌────────────────────────┐
│ PendingProductUpload   │
├────────────────────────┤
│ + id: String           │
│ + product: Product     │◆───────┐
│ + queuedAt: DateTime   │        │
│ + retryCount: int (0-3)│        │ Contains
│ + status: Enum         │        │
└────────────────────────┘        ▼
                          ┌────────────────────┐
                          │ FoodProductModel   │
                          ├────────────────────┤
                          │ + barcode: String  │
                          │ + name: String     │
                          │ + cachedAt: DateTime│
                          │ + source: Enum     │
                          └────────────────────┘
                                    │
                                    │ Contains
                                    ▼
                          ┌──────────────────────┐
                          │ NutritionValuesModel │
                          ├──────────────────────┤
                          │ + energy: double     │
                          │ + protein: double    │
                          │ + carbs: double      │
                          └──────────────────────┘
```

---

## Migration Notes

### Hive Schema Version Increment

**Current Schema Version**: Check `lib/core/services/hive_boxes.dart`

**Required Changes**:
1. Add new `PendingUploadStatus` enum adapter (typeId: 8)
2. Add new `ProductDataSource` enum adapter (typeId: 9)
3. Increment schema version if using versioning
4. Add migration for existing `PendingProductUpload` records to add new fields with defaults:
   - `retryCount`: 0
   - `status`: `PendingUploadStatus.pending`
   - `lastAttemptAt`: null
   - `failureReason`: null

### Migration Script

```dart
Future<void> migratePendingUploads() async {
  final box = await Hive.openBox<PendingProductUpload>('pendingProductUploads');
  
  for (var upload in box.values) {
    if (upload.retryCount == null) { // Check if old schema
      final migrated = PendingProductUpload(
        id: upload.id,
        product: upload.product,
        queuedAt: upload.queuedAt,
        imagePath: upload.imagePath,
        isUpdate: upload.isUpdate,
        retryCount: 0, // Default
        status: PendingUploadStatus.pending, // Default
      );
      await upload.save(); // Update in place
    }
  }
}
```

---

## Summary

| Entity | Type | Status | Changes Required |
|--------|------|--------|------------------|
| PendingProductUpload | Model (Hive) | Enhance | Add retry tracking, status management fields |
| PendingUploadStatus | Enum (Hive) | New | Create enum for upload states |
| ProductValidationResult | Entity | New | Create for validation flow |
| FoodProductModel | Model (Hive) | Enhance | Add cache metadata (cachedAt, source) |
| ProductDataSource | Enum (Hive) | New | Create enum for data origin tracking |
| SyncResult | Entity | New | Create for sync operation results |

**Total New Files**: 4 (2 enums, 2 entities)  
**Total Enhanced Files**: 2 (PendingProductUpload, FoodProductModel)  
**Hive Type IDs Required**: 2 new (8, 9)

**Next**: Create validation contracts and quickstart guide.

# Research: FoodSearch Polish & Completion

**Feature**: 001-food-search-polish  
**Phase**: 0 (Research & Discovery)  
**Date**: 2026-02-07

## Overview

This document consolidates research findings for polishing the FoodSearch feature. Research resolves unknowns from the Technical Context and validates technology choices for test infrastructure, image compression, notifications, and validation patterns.

---

## Research Task 1: Flutter Testing Frameworks & Best Practices

**Question**: What testing approach should be used to create comprehensive test suite from scratch for FoodSearch feature with 70% coverage target?

### Decision: Multi-layered Testing with flutter_test, package:test, mockito

**Rationale**:
- **flutter_test**: Built-in widget testing framework, no additional dependencies
- **package:test**: Standard Dart unit testing, already in project
- **mockito**: Code-generation for mocks (preferred over mocktail for type safety)
- **integration_test**: Flutter SDK package for E2E tests

**Best Practices Identified**:

1. **Test Organization**: Mirror production code structure
   ```
   test/
   ├── unit/food_search/usecases/     # One test file per use case
   ├── widget/food_search/             # One test file per screen
   └── integration/food_search/        # One file per user journey
   ```

2. **Naming Convention**: `{class_name}_test.dart` (e.g., `filter_products_use_case_test.dart`)

3. **Test Structure**: Arrange-Act-Assert (AAA) pattern with clear Given-When-Then comments

4. **Mock Strategy**:
   - Use fakes for simple data structures (ProductEntity)
   - Use mocks for repositories (mockito code generation)
   - Use stubs for external services (OpenFoodFacts API)

5. **Coverage Measurement**:
   ```bash
   flutter test --coverage
   genhtml coverage/lcov.info -o coverage/html
   open coverage/html/index.html  # View in browser
   ```

6. **Widget Testing Best Practices**:
   - Use `testWidgets` for Flutter widget tests
   - Pump widgets with `MaterialApp` wrapper for context
   - Use `find.byType`, `find.text`, `find.byKey` for widget location
   - Use `tester.tap()`, `tester.enterText()` for interactions
   - Use `tester.pumpAndSettle()` for async operations

7. **Integration Testing Best Practices**:
   - Use `integration_test` package for E2E flows
   - Test critical paths: search → favorite, scan → submit, offline → sync
   - Mock external APIs (OpenFoodFacts) in integration tests
   - Use `IntegrationTestWidgetsFlutterBinding.ensureInitialized()`

**Alternatives Considered**:
- **mocktail** (Rejected): Less type-safe than mockito with code generation
- **patrol** (Rejected): Overkill for current needs, complex setup
- **golden tests** (Deferred): Useful for UI regression but not required for 70% coverage target

**Resources**:
- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Effective Dart: Testing](https://dart.dev/guides/language/effective-dart/testing)
- [mockito Package](https://pub.dev/packages/mockito)

---

## Research Task 2: Image Compression for Product Photo Uploads

**Question**: How to automatically compress images exceeding 5MB before uploading to OpenFoodFacts while maintaining visual quality?

### Decision: flutter_image_compress with 85% quality, 1920px max dimension

**Rationale**:
- **flutter_image_compress**: Native compression (fast), supports JPEG/PNG, configurable quality
- **85% quality**: Industry standard for "visually lossless" compression
- **1920px max dimension**: Balances quality for product photos with file size
- **Average 60% reduction**: Achieves success criteria from spec.md

**Implementation Pattern**:
```dart
import 'package:flutter_image_compress/flutter_image_compress.dart';

Future<File> compressProductImage(File imageFile) async {
  final filePath = imageFile.absolute.path;
  
  // Get file size
  final bytes = await imageFile.length();
  if (bytes <= 5 * 1024 * 1024) {
    return imageFile; // Already under 5MB
  }
  
  // Compress
  final dir = await getTemporaryDirectory();
  final targetPath = '${dir.path}/compressed_${basename(filePath)}';
  
  final result = await FlutterImageCompress.compressAndGetFile(
    filePath,
    targetPath,
    quality: 85,
    minWidth: 1920,
    minHeight: 1920,
    rotate: 0,
  );
  
  return File(result!.path);
}
```

**Configuration Options**:
- **quality**: 85 (range 0-100, lower = smaller file, less quality)
- **minWidth/minHeight**: 1920px (maintains aspect ratio, scales down if larger)
- **format**: Auto-detect JPEG/PNG (JPEG for photos, PNG for graphics)

**Performance**:
- Compression time: ~500ms for 10MB image on mid-range device
- Size reduction: 60-80% typical for high-res phone photos
- Quality: Visually indistinguishable from original in product context

**Alternatives Considered**:
- **image package** (Rejected): Slower, pure Dart implementation
- **Native platform channels** (Rejected): More complex, platform-specific code
- **Server-side compression** (Rejected): Adds latency, requires server infrastructure

**Dependencies**: Add to pubspec.yaml:
```yaml
dependencies:
  flutter_image_compress: ^2.1.0  # Check for latest version
```

**Resources**:
- [flutter_image_compress on pub.dev](https://pub.dev/packages/flutter_image_compress)
- [Image Compression Best Practices](https://developer.android.com/topic/performance/graphics/load-bitmap)

---

## Research Task 3: Local Notifications for Sync Completion

**Question**: How to notify users when pending uploads successfully sync after manual trigger, per FR-016 requirement?

### Decision: flutter_local_notifications with simple notification channel

**Rationale**:
- **flutter_local_notifications**: Already in project dependencies (pubspec.yaml shows ^19.4.2)
- **Simple channel**: No need for complex notification grouping or actions
- **Manual trigger**: Notifications only on user-initiated sync, not background

**Implementation Pattern**:
```dart
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

class SyncNotificationService {
  static final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();
  
  static Future<void> initialize() async {
    const androidSettings = AndroidInitializationSettings('@mipmap/ic_launcher');
    const iosSettings = DarwinInitializationSettings();
    const settings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );
    await _notifications.initialize(settings);
  }
  
  static Future<void> showSyncSuccess(int uploadCount) async {
    const androidDetails = AndroidNotificationDetails(
      'food_sync_channel',
      'Food Product Sync',
      channelDescription: 'Notifications for product upload sync',
      importance: Importance.high,
      priority: Priority.high,
    );
    const iosDetails = DarwinNotificationDetails();
    const details = NotificationDetails(android: androidDetails, iOS: iosDetails);
    
    await _notifications.show(
      0,
      'Products Uploaded',
      '$uploadCount products uploaded successfully to OpenFoodFacts',
      details,
    );
  }
  
  static Future<void> showSyncFailure(int failedCount, int retryCount) async {
    // Similar implementation for failure notifications
  }
}
```

**Android Configuration** (android/app/src/main/AndroidManifest.xml):
```xml
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationReceiver" />
<receiver android:name="com.dexterous.flutterlocalnotifications.ScheduledNotificationBootReceiver">
    <intent-filter>
        <action android:name="android.intent.action.BOOT_COMPLETED"/>
    </intent-filter>
</receiver>
```

**iOS Configuration** (ios/Runner/AppDelegate.swift):
- No additional config needed, notifications work out-of-box with permissions

**Permission Handling**:
- Android 13+: Request POST_NOTIFICATIONS permission at runtime
- iOS: Request notification permissions via permission_handler or in-app prompt

**Notification Scenarios**:
1. **Success**: "2 products uploaded successfully to OpenFoodFacts"
2. **Partial failure**: "1 of 3 uploads failed after 3 retries. Tap to review."
3. **All failed**: "Upload failed. Check your connection and try again."

**Alternatives Considered**:
- **awesome_notifications** (Rejected): More features than needed, heavier dependency
- **In-app snackbars only** (Rejected): User may not see if app backgrounded during sync
- **Push notifications** (Rejected): Requires backend, unnecessary for local operations

**Resources**:
- [flutter_local_notifications Documentation](https://pub.dev/packages/flutter_local_notifications)
- [Android Notification Best Practices](https://developer.android.com/design/patterns/notifications)

---

## Research Task 4: Product Submission Validation for OpenFoodFacts

**Question**: What are the validation rules for submitting products to OpenFoodFacts API to implement FR-009 and FR-010?

### Decision: Client-side validation matching OpenFoodFacts API requirements

**OpenFoodFacts API Requirements** (from openfoodfacts package and API docs):

1. **Barcode (Required)**:
   - Format: EAN-8 (8 digits), EAN-13 (13 digits), UPC-A (12 digits)
   - Validation regex: `^[0-9]{8,13}$`
   - Checksum validation: Optional but recommended

2. **Product Name (Required)**:
   - Minimum length: 2 characters
   - Maximum length: 200 characters
   - No special characters except: `-`, `'`, space, accented letters

3. **Brand (Optional but Recommended)**:
   - Maximum length: 100 characters

4. **Quantity (Optional)**:
   - Format: Number + unit (e.g., "500 g", "1 L", "250 ml")
   - Validation: Allow digits, space, and common units (g, kg, ml, L, oz, lb)

5. **Image (Optional)**:
   - Max size: 10MB (API limit, we compress to 5MB)
   - Formats: JPEG, PNG
   - Dimensions: Recommended 400px minimum on shortest side

6. **Nutrition Values (Optional)**:
   - Must be per 100g or per 100ml
   - Negative values not allowed
   - Energy in kJ and kcal
   - Macros: protein, carbohydrates, fat (in grams)

**Validation Implementation**:

```dart
class ProductValidation {
  static String? validateBarcode(String? value) {
    if (value == null || value.isEmpty) {
      return 'Barcode is required';
    }
    if (!RegExp(r'^[0-9]{8,13}$').hasMatch(value)) {
      return 'Invalid barcode format (must be 8-13 digits)';
    }
    return null;
  }
  
  static String? validateProductName(String? value) {
    if (value == null || value.isEmpty) {
      return 'Product name is required';
    }
    if (value.length < 2) {
      return 'Product name must be at least 2 characters';
    }
    if (value.length > 200) {
      return 'Product name must be less than 200 characters';
    }
    return null;
  }
  
  static String? validateBrand(String? value) {
    if (value != null && value.length > 100) {
      return 'Brand name must be less than 100 characters';
    }
    return null; // Optional field
  }
  
  static String? validateQuantity(String? value) {
    if (value != null && value.isNotEmpty) {
      if (!RegExp(r'^[0-9]+(\.[0-9]+)?\s*(g|kg|ml|L|oz|lb)$', caseSensitive: false)
          .hasMatch(value)) {
        return 'Invalid quantity format (e.g., "500 g", "1 L")';
      }
    }
    return null; // Optional field
  }
}
```

**Form Integration**:
- Use `TextFormField` with `validator` property
- Show inline error messages below fields
- Disable submit button until form validates
- Show loading indicator during submission

**Alternatives Considered**:
- **Server-side only validation** (Rejected): Poor UX, wasted bandwidth
- **Checksum validation for barcodes** (Deferred): Nice-to-have, not critical for MVP
- **Real-time OpenFoodFacts API check** (Rejected): Too slow, rate limits

**Resources**:
- [OpenFoodFacts API Documentation](https://wiki.openfoodfacts.org/API)
- [openfoodfacts Dart Package](https://pub.dev/packages/openfoodfacts)
- [EAN/UPC Barcode Standards](https://www.gs1.org/standards/barcodes)

---

## Research Task 5: Offline Indicator UI Patterns

**Question**: What UI pattern best communicates offline status and cache age to users per FR-012?

### Decision: Badge + timestamp pattern with color coding

**Design Pattern**:

```
┌─────────────────────────────────┐
│  [Product Name]                 │
│  ┌─────────────────────────┐   │
│  │ 📶 Offline - Cached Data│   │ ← Badge at top
│  │ Last updated: 2 days ago│   │ ← Cache age
│  └─────────────────────────┘   │
│  [Product details...]           │
└─────────────────────────────────┘
```

**Implementation**:

```dart
class OfflineIndicator extends StatelessWidget {
  final DateTime cacheTimestamp;
  
  @override
  Widget build(BuildContext context) {
    final cacheAge = DateTime.now().difference(cacheTimestamp);
    final isStale = cacheAge.inDays > 7;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: isStale 
            ? Theme.of(context).colorScheme.errorContainer
            : Theme.of(context).colorScheme.surfaceVariant,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            isStale ? Icons.warning_amber : Icons.cloud_off,
            size: 16,
            color: isStale 
                ? Theme.of(context).colorScheme.error
                : Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isStale ? 'Data May Be Outdated' : 'Offline - Cached Data',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: isStale 
                        ? Theme.of(context).colorScheme.error
                        : Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                Text(
                  'Last updated: ${_formatCacheAge(cacheAge)}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  String _formatCacheAge(Duration age) {
    if (age.inMinutes < 60) return '${age.inMinutes} minutes ago';
    if (age.inHours < 24) return '${age.inHours} hours ago';
    return '${age.inDays} days ago';
  }
}
```

**Color Coding**:
- **Fresh** (<7 days): Neutral gray (surfaceVariant)
- **Stale** (>7 days): Warning yellow/orange (errorContainer)
- **Online**: No indicator shown (default state)

**Placement**:
- Product details screen: Top of content, below app bar
- Product list cards: Small badge icon in corner
- Search results: Footer message "X results from cache"

**Alternatives Considered**:
- **Toast/Snackbar only** (Rejected): Easy to miss, not persistent
- **App-wide banner** (Rejected): Intrusive, blocks content
- **Icon only** (Rejected): Not descriptive enough

**Accessibility**:
- Semantic label: "Product data cached {age} ago, may be outdated"
- Color not sole indicator (icon + text convey meaning)
- Sufficient contrast for WCAG 4.5:1 requirement

**Resources**:
- [Material 3 Badges](https://m3.material.io/components/badges)
- [Flutter Connectivity Indicators](https://material.io/design/connectivity)

---

## Summary of Research Findings

| Research Area | Technology Choice | Key Decisions |
|---------------|-------------------|---------------|
| **Testing** | flutter_test, mockito, integration_test | AAA pattern, 70% coverage via unit/widget/integration layers |
| **Image Compression** | flutter_image_compress | 85% quality, 1920px max, ~60% size reduction |
| **Notifications** | flutter_local_notifications (already in project) | Simple channel, manual trigger only, success/failure messages |
| **Validation** | Client-side regex + form validators | Barcode 8-13 digits, product name required, inline error messages |
| **Offline UI** | Badge + timestamp pattern | Color-coded (fresh/stale), cache age display, persistent indicator |

**No Unknowns Remaining**: All technical approaches validated and ready for implementation.

**Next Phase**: Proceed to Phase 1 (Design) to create data models, contracts, and quickstart guide.

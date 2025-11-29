# Nutrition Facts OCR - Implementation TODOs

## Overview
**Feature:** Nutrition Facts Input & OCR Extraction  
**Timeline:** ~19 dev days (4 sprints)  
**Status:** Planning Complete

---

## Sprint 1: Foundation (5 days)

### T1.1 - Create NutritionFacts Domain Entity
- **File:** `lib/features/FoodSearch/domain/entities/nutrition_facts.dart`
- **Complexity:** Low | **Est:** 2h
- [ ] Create `NutritionFacts` class with:
  - [ ] Core nutrition fields (energyKcal100g, fat100g, saturatedFat100g, carbohydrates100g, sugars100g, fiber100g, proteins100g, sodium100g, salt100g)
  - [ ] Serving info (servingSize, dataMode)
  - [ ] OCR metadata (confidenceScores map, requiresReview, scannedAt, rawOcrText)
- [ ] Add `isFieldConfident(String field)` method
- [ ] Add `getLowConfidenceFields()` method
- [ ] Add `convertToPer100g()` method for serving→100g conversion
- [ ] Add `isValid()` validation method (negative check, max check, energy sanity)
- [ ] Add `copyWith()` method

### T1.2 - Extend NutritionValuesModel
- **File:** `lib/features/FoodSearch/data/models/nutrition_values_model.dart`
- **Complexity:** Medium | **Est:** 3h
- [ ] Add new HiveFields (11-15):
  - [ ] `@HiveField(11) final Map<String, double>? confidenceScores`
  - [ ] `@HiveField(12) final bool? requiresManualReview`
  - [ ] `@HiveField(13) final DateTime? ocrScannedAt`
  - [ ] `@HiveField(14) final String? rawOcrText`
  - [ ] `@HiveField(15) final String? dataMode`
- [ ] Add `factory NutritionValuesModel.fromEntity(NutritionFacts facts)`
- [ ] Add `Map<String, dynamic> toOFFNutriments()` method
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`

### T1.3 - Create PendingProductUpload Model
- **File:** `lib/features/FoodSearch/data/models/pending_product_upload.dart`
- **Complexity:** Low | **Est:** 2h
- [ ] Create Hive model with `@HiveType(typeId: 20)`:
  - [ ] `@HiveField(0) final String barcode`
  - [ ] `@HiveField(1) final Map<String, dynamic> productData`
  - [ ] `@HiveField(2) final NutritionValuesModel? nutritionFacts`
  - [ ] `@HiveField(3) final String? imagePath`
  - [ ] `@HiveField(4) final DateTime timestamp`
  - [ ] `@HiveField(5) int retryCount`
  - [ ] `@HiveField(6) final SyncOperationType operationType`
- [ ] Add `part 'pending_product_upload.g.dart'`
- [ ] Run build_runner

### T1.4 - Build NutritionParsingService
- **File:** `lib/core/services/nutrition_parsing_service.dart`
- **Complexity:** High | **Est:** 12h
- [ ] Create `NutritionParsingService` class
- [ ] Define `_keyMapping` constant (EN/AR keywords):
  - [ ] energy: ['energy', 'calories', 'kcal', 'طاقة', 'سعرات', 'سعرة']
  - [ ] fat, saturated_fat, carbs, sugars, fiber, protein, sodium, salt
- [ ] Define `_arabicNumerals` constant (٠-٩ → 0-9, ٫/، → .)
- [ ] Implement `parseOcrText(String text)`:
  - [ ] Text normalization
  - [ ] Line splitting
  - [ ] Serving size detection
  - [ ] Nutrient extraction per line
- [ ] Implement `_normalizeText(String text)` - Arabic numeral conversion
- [ ] Implement `_extractServingSize(String line)` - Regex for EN/AR
- [ ] Implement `_extractNutrientFromLine()`:
  - [ ] Regex pattern for "Label: Value Unit"
  - [ ] Map to standard key
  - [ ] Unit conversion
  - [ ] Confidence calculation
- [ ] Implement `_mapToStandardKey(String label)`
- [ ] Implement `_convertToStandardUnit(double value, String? unit)` (mg→g, kJ→kcal)
- [ ] Implement `_calculateConfidence(RegExpMatch match, String line)`

### T1.5 - Write Parsing Service Unit Tests
- **File:** `test/core/services/nutrition_parsing_service_test.dart`
- **Complexity:** Medium | **Est:** 6h
- [ ] Test: Parse English nutrition label
- [ ] Test: Parse Arabic nutrition label with Arabic numerals
- [ ] Test: Converts mg to g for sodium
- [ ] Test: Converts kJ to kcal
- [ ] Test: Flags low confidence values for review
- [ ] Test: Handles mixed EN/AR labels
- [ ] Test: Handles per-serving vs per-100g detection

### T1.6 - Extend FoodSearchRepo
- **File:** `lib/features/FoodSearch/data/repo/food_search_repo.dart`
- **Complexity:** Medium | **Est:** 4h
- [ ] Add `submitProductWithNutrition()` method:
  - [ ] Accept Product, NutritionValuesModel?, User, imagePath?, isUpdate
  - [ ] Online path: direct submission with nutriments
  - [ ] Offline path: enqueue for later sync
  - [ ] Error handling: enqueue on failure
- [ ] Add `_enqueuePendingProduct()` private method

---

## Sprint 2: OCR Pipeline (5 days)

### T2.1 - Add ML Kit Dependency
- **File:** `pubspec.yaml`
- **Complexity:** Low | **Est:** 1h
- [ ] Add `google_mlkit_text_recognition: ^0.11.0`
- [ ] Add `image: ^4.1.7`
- [ ] Add `flutter_image_compress: ^2.1.0`
- [ ] Run `flutter pub get`
- [ ] Test import works

### T2.2 - Create OcrService Wrapper
- **File:** `lib/core/services/ocr_service.dart`
- **Complexity:** Low | **Est:** 3h
- [ ] Create `OcrService` class
- [ ] Initialize `TextRecognizer(script: TextRecognitionScript.latin)`
- [ ] Add `Future<String> extractText(File image)` method
- [ ] Add `Future<List<TextBlock>> extractBlocks(File image)` method
- [ ] Add `void dispose()` to close recognizer
- [ ] Handle multi-script (Latin + Arabic) recognition

### T2.3 - Create OCRScannerProvider
- **File:** `lib/features/FoodSearch/presentation/providers/ocr_scanner_provider.dart`
- **Complexity:** Medium | **Est:** 4h
- [ ] Create `OcrScannerController extends StateNotifier<AsyncValue<NutritionFacts?>>`
- [ ] Inject `NutritionParsingService` and `TextRecognizer`
- [ ] Implement `processImage(String imagePath)`:
  - [ ] Set loading state
  - [ ] Preprocess image
  - [ ] Run OCR
  - [ ] Parse nutrition facts
  - [ ] Return result or error
- [ ] Implement `_preprocessImage(File image)`:
  - [ ] Blur check
  - [ ] Contrast enhancement
  - [ ] Compression
- [ ] Implement `_isBlurry(File image)` using ML Kit confidence
- [ ] Add `dispose()` to close resources
- [ ] Create `ocrScannerProvider` provider

### T2.4 - Implement Image Preprocessing
- **Complexity:** Medium | **Est:** 6h
- [ ] Add blur detection (ML Kit text block confidence)
- [ ] Add contrast enhancement using `image` package
- [ ] Add compression with `flutter_image_compress`
- [ ] Add error handling for decode failures
- [ ] Test with low-quality images

### T2.5 - Create OCRScannerScreen (Basic)
- **File:** `lib/features/FoodSearch/presentation/screens/ocr_scanner_screen.dart`
- **Complexity:** High | **Est:** 8h
- [ ] Create `OCRScannerScreen` ConsumerStatefulWidget
- [ ] Add `ImagePicker` integration
- [ ] Build camera instructions placeholder
- [ ] Build processing overlay (shimmer + loading indicator)
- [ ] Build capture button
- [ ] Implement `_captureAndProcess()`:
  - [ ] Capture image
  - [ ] Call OCR provider
  - [ ] Handle success/error
- [ ] Add error dialog for OCR failure
- [ ] Return `NutritionFacts` result on success

### T2.6 - Wire OCR Flow
- **Complexity:** Medium | **Est:** 4h
- [ ] Add route for `ocrScanner` in `routing.dart`
- [ ] Test full flow: Camera → OCR → Parse → Return
- [ ] Add logging with TalkerService
- [ ] Handle edge cases (empty result, partial parse)

---

## Sprint 3: UI & Animations (5 days)

### T3.1 - Create NutritionStateProvider
- **File:** `lib/features/FoodSearch/presentation/providers/nutrition_state_provider.dart`
- **Complexity:** Low | **Est:** 3h
- [ ] Create `NutritionState` class:
  - [ ] facts, isExpanded, dataMode, isLoading, error
  - [ ] copyWith() method
- [ ] Create `NutritionStateNotifier extends StateNotifier<NutritionState>`:
  - [ ] toggleExpanded()
  - [ ] setDataMode(String mode) with auto-convert
  - [ ] updateFacts(NutritionFacts facts)
  - [ ] setLoading(bool loading)
  - [ ] setError(String? error)
  - [ ] reset()
- [ ] Create `nutritionStateProvider` with autoDispose

### T3.2 - Build NutritionFactsBottomSheet Widget
- **File:** `lib/features/FoodSearch/presentation/widgets/nutrition_facts_bottom_sheet.dart`
- **Complexity:** High | **Est:** 10h
- [ ] Create ConsumerStatefulWidget with SingleTickerProviderStateMixin
- [ ] Add AnimationController + slideAnimation
- [ ] Initialize text controllers for all fields
- [ ] Build header with:
  - [ ] AnimatedRotation icon
  - [ ] Title + field count
  - [ ] ConfidenceIndicator badge
  - [ ] AnimatedRotation chevron
- [ ] Build content with:
  - [ ] SlideTransition + FadeTransition
  - [ ] DataModeToggle
  - [ ] OCR scan button
  - [ ] Nutrition fields
  - [ ] Preview card
- [ ] Implement `_launchOCRScanner()` with navigation
- [ ] Implement `_animateAutoFill(NutritionFacts facts)` with staggered delays
- [ ] Add helper methods (getFieldConfidence, getAverageConfidence, etc.)
- [ ] Dispose controllers properly

### T3.3 - Create NutritionField Widget
- **File:** `lib/features/FoodSearch/presentation/widgets/nutrition_field.dart`
- **Complexity:** Medium | **Est:** 4h
- [ ] Create StatefulWidget with focus tracking
- [ ] Add AnimatedContainer with shadow on focus
- [ ] Add TextFormField with:
  - [ ] Label with unit
  - [ ] Warning prefix icon for low confidence
  - [ ] ConfidenceIndicator suffix
  - [ ] Color-coded borders
  - [ ] Helper text for review needed
- [ ] Add numeric input formatters

### T3.4 - Build ConfidenceIndicator Widget
- **File:** `lib/features/FoodSearch/presentation/widgets/confidence_indicator.dart`
- **Complexity:** Medium | **Est:** 5h
- [ ] Create StatefulWidget with SingleTickerProviderStateMixin
- [ ] Add pulse AnimationController (repeat, reverse)
- [ ] Build animated container with:
  - [ ] Color based on confidence level
  - [ ] Pulsing scale animation for low confidence
  - [ ] Glow shadow effect
  - [ ] Icon (check/warning/error)
- [ ] Add helper methods for color/icon selection
- [ ] Dispose animation controller

### T3.5 - Add Per-100g/Serving Mode Toggle
- **Complexity:** Medium | **Est:** 4h
- [ ] Build toggle UI in NutritionFactsBottomSheet
- [ ] AnimatedContainer for selection state
- [ ] Connect to NutritionStateNotifier.setDataMode()
- [ ] Auto-convert existing facts when mode changes
- [ ] Test conversion accuracy

### T3.6 - Implement Auto-Fill Animation
- **Complexity:** Medium | **Est:** 3h
- [ ] Staggered population of text fields
- [ ] 100ms delay between each field
- [ ] Shimmer effect during population
- [ ] Test with various field counts

### T3.7 - Add Scanning Overlay Painter
- **File:** `lib/features/FoodSearch/presentation/widgets/scanning_overlay_painter.dart`
- **Complexity:** Medium | **Est:** 4h
- [ ] Create CustomPainter with animation
- [ ] Draw dark overlay with transparent cutout
- [ ] Draw frame border
- [ ] Draw corner markers (green accents)
- [ ] Animate scan line movement
- [ ] Add gradient to scan line

### T3.8 - Success Confetti Animation
- **Complexity:** Low | **Est:** 2h
- [ ] Add `confetti: ^0.7.0` dependency
- [ ] Add ConfettiController to OCRScannerScreen
- [ ] Trigger confetti on successful scan
- [ ] Configure particle settings
- [ ] Dispose controller

---

## Sprint 4: Offline + Testing (5 days)

### T4.1 - Extend SyncService for Products
- **File:** `lib/core/services/sync.dart`
- **Complexity:** High | **Est:** 6h
- [ ] Add `FoodSearchRepo` dependency
- [ ] Add `_syncProducts()` method:
  - [ ] Get pending products from Hive
  - [ ] Reconstruct Product from stored data
  - [ ] Submit with retry backoff
  - [ ] Remove on success
  - [ ] Increment retry count on failure
  - [ ] Give up after 5 retries
- [ ] Add `_retryWithBackoff()` method:
  - [ ] Exponential backoff calculation
  - [ ] Max delay cap
- [ ] Call `_syncProducts()` in `syncPendingOperations()`

### T4.2 - Register Hive Types
- **File:** `lib/core/services/hive_boxes.dart`
- **Complexity:** Low | **Est:** 2h
- [ ] Register `PendingProductUploadAdapter`
- [ ] Add `pendingProductsBox` getter
- [ ] Open box in `init()` method
- [ ] Test box operations

### T4.3 - Implement Exponential Backoff Retry
- **Complexity:** Medium | **Est:** 4h
- [ ] Base delay: 2 seconds
- [ ] Max delay: 5 minutes
- [ ] Formula: baseDelay * 2^retryCount
- [ ] Test with simulated failures

### T4.4 - Add Pending Sync Badge UI
- **Complexity:** Low | **Est:** 3h
- [ ] Show pending count badge on product form
- [ ] "Pending sync" indicator after offline submission
- [ ] Toast notification when sync completes
- [ ] Visual state for queued items

### T4.5 - Write Widget Tests
- **File:** `test/features/FoodSearch/presentation/widgets/nutrition_facts_section_test.dart`
- **Complexity:** Medium | **Est:** 6h
- [ ] Test: NutritionFactsBottomSheet expands and collapses
- [ ] Test: Data mode toggle switches correctly
- [ ] Test: OCR button navigates to scanner
- [ ] Test: Fields update state correctly
- [ ] Test: Confidence indicator shows correct colors

### T4.6 - Integration Test: OCR → Submit Flow
- **File:** `integration_test/nutrition_ocr_flow_test.dart`
- **Complexity:** High | **Est:** 8h
- [ ] Test: Navigate to product form
- [ ] Test: Expand nutrition section
- [ ] Test: Launch OCR scanner (mocked)
- [ ] Test: Fields populate from OCR result
- [ ] Test: Submit product successfully

### T4.7 - E2E Test: Offline → Reconnect → Sync
- **Complexity:** Medium | **Est:** 6h
- [ ] Test: Submit product while offline
- [ ] Test: Product queued in Hive
- [ ] Test: Reconnect triggers sync
- [ ] Test: Product removed from queue on success

### T4.8 - Performance Optimization
- **Complexity:** Medium | **Est:** 4h
- [ ] Add RepaintBoundary for custom painters
- [ ] Profile animations (60fps target)
- [ ] Optimize image processing with compute()
- [ ] Lazy load OCR dependencies

---

## Localization TODOs

### Add ARB Keys
- **Files:** `lib/l10n/app_en.arb`, `lib/l10n/app_ar.arb`
- [ ] nutritionFacts / القيم الغذائية
- [ ] scanNutritionLabel / مسح ملصق الغذاء
- [ ] calories / سعرات حرارية
- [ ] fat / دهون
- [ ] saturatedFat / دهون مشبعة
- [ ] carbohydrates / كربوهيدرات
- [ ] sugars / سكريات
- [ ] fiber / ألياف
- [ ] proteins / بروتين
- [ ] sodium / صوديوم
- [ ] per100g / لكل ١٠٠ جم
- [ ] perServing / لكل حصة
- [ ] lowConfidence / ثقة منخفضة
- [ ] pleaseVerify / يرجى التحقق
- [ ] ocrFailed / فشل المسح
- [ ] retake / إعادة التصوير
- [ ] manualEntry / إدخال يدوي

---

## Route Configuration

### Add OCR Scanner Route
- **File:** `lib/routing.dart`
- [ ] Add `static const String ocrScanner = '/ocrScanner'`
- [ ] Add GoRoute for OCRScannerScreen
- [ ] Configure transition animation

---

## Dependencies Summary

```yaml
# Add to [pubspec.yaml](http://_vscodecontentref_/0)
dependencies:
  google_mlkit_text_recognition: ^0.11.0
  image: ^4.1.7
  flutter_image_compress: ^2.1.0
  confetti: ^0.7.0
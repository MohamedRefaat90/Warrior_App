# Feature Specification: FoodSearch Polish & Completion

**Feature Branch**: `001-food-search-polish`  
**Created**: 2026-02-07  
**Status**: Draft  
**Input**: User description: "Polish and complete the FoodSearch feature by addressing: 1) Missing test coverage (currently no tests exist for this feature), 2) Cleanup deprecated ProductUseCases facade and migrate to individual use cases, 3) Remove unused imports and commented code, 4) Add validation for product submissions to OpenFoodFacts, 5) Improve error handling for offline scenarios, 6) Add user feedback for pending uploads queue"

## Clarifications

### Session 2026-02-07

- Q: Should tests be created from scratch or expanded from existing? → A: Create complete test suite from scratch - migration docs are outdated/fictional
- Q: Should commented fields (ingredients, servingSize, countries) be implemented or removed? → A: Remove all 3 commented controllers (ingredientsController, servingSizeController, countriesController) plus commented ProductDetailsFields widget - keep form simple with barcode, name, brand, quantity, nutrition only
- Q: How should background sync for pending uploads be triggered? → A: Manual trigger only - when user opens app or taps sync button
- Q: What is the maximum retry attempts for failed uploads? → A: 3 retry attempts before requiring user intervention
- Q: Where should pending uploads management screen be located? → A: Dedicated full screen with own route, accessible from main navigation app bar beside search icon

## User Scenarios & Testing

### User Story 1 - Test Coverage for Critical Paths (Priority: P1)

As a developer maintaining the FoodSearch feature, I need comprehensive test coverage to prevent regressions and ensure business logic correctness.

**Why this priority**: Testing is foundational quality infrastructure. Without tests, refactoring and enhancements risk breaking existing functionality. This blocks all other improvements safely. Note: Despite migration docs claiming tests exist, they need to be created from scratch.

**Independent Test**: Can be verified by running `flutter test` and checking coverage reports show ≥70% coverage for FoodSearch feature files, with all critical paths (search, filtering, favorites) covered.

**Acceptance Scenarios**:

1. **Given** all 14 use cases exist in domain layer, **When** test suite runs, **Then** each use case has unit tests covering success paths, error paths, and edge cases
2. **Given** product filtering logic with multiple criteria, **When** unit tests execute, **Then** tests verify nutriScore, vegan, vegetarian, palm oil, NOVA, and allergen filters work independently and combined
3. **Given** repository implementations with caching logic, **When** integration tests run, **Then** tests verify cache-first strategy, cache freshness checks, and offline fallbacks
4. **Given** product submission with offline queueing, **When** tests execute, **Then** pending uploads queue correctly and process when connectivity restores
5. **Given** OCR nutrition extraction, **When** widget tests run, **Then** UI correctly displays extracted values and handles parsing failures

---

### User Story 2 - Clean Architecture Migration (Priority: P2)

As a developer working in the codebase, I need to use the new individual use case architecture instead of the deprecated ProductUseCases facade.

**Why this priority**: The refactoring to individual use cases is complete but not fully adopted. Migration unblocks cleaner code and eliminates deprecated warnings that clutter development.

**Independent Test**: Can be verified by searching codebase for `ProductUseCases` references (excluding the facade itself) - should return zero results. All providers use individual use case providers from `product_use_cases_provider.dart`.

**Acceptance Scenarios**:

1. **Given** deprecated ProductUseCases facade exists, **When** all presentation layer code migrates, **Then** no providers or screens import ProductUseCases directly
2. **Given** individual use case providers in `product_use_cases_provider.dart`, **When** code review runs, **Then** all food search operations use appropriate individual providers
3. **Given** ProductUseCases marked deprecated, **When** migration completes, **Then** deprecated facade can be safely removed from codebase
4. **Given** code using old facade, **When** migration executes, **Then** no functionality changes - only internal architecture improves

---

### User Story 3 - Code Quality & Cleanup (Priority: P2)

As a developer reading the code, I need clean, maintainable code without commented-out sections, unused imports, or debugging artifacts.

**Why this priority**: Code quality directly impacts maintainability and onboarding. Clean code makes future enhancements faster and reduces cognitive load.

**Independent Test**: Can be verified by running `flutter analyze` on FoodSearch directory showing zero lint warnings for unused imports, and manual inspection showing no commented-out production code (debugging comments acceptable).

**Acceptance Scenarios**:

1. **Given** product_form_screen.dart has unused import, **When** cleanup runs, **Then** `nutrition_facts.dart` import removed
2. **Given** multiple files have commented-out code, **When** cleanup executes, **Then** only essential comments explaining "why" remain, not "what" code does
3. **Given** debugging print statements exist, **When** code review occurs, **Then** production code uses TalkerService for logging, debugPrint removed
4. **Given** product form has commented fields (ingredients, servingSize, countries), **When** cleanup runs, **Then** remove all commented code - form remains simple with barcode, name, brand, quantity, and nutrition fields only

---

### User Story 4 - Product Submission Validation (Priority: P3)

As a user submitting products to OpenFoodFacts, I need clear validation feedback so I don't submit incomplete or invalid data.

**Why this priority**: Improves data quality contributed to OpenFoodFacts and prevents frustration from silent failures or cryptic API errors.

**Independent Test**: Can be verified by attempting to submit a product with missing required fields (barcode, product name) - form displays inline validation errors and prevents submission.

**Acceptance Scenarios**:

1. **Given** user opens product form, **When** attempting to submit without barcode, **Then** form displays "Barcode is required" error and prevents submission
2. **Given** user enters barcode with invalid format, **When** validation runs, **Then** form shows "Invalid barcode format (must be 8-13 digits)" error
3. **Given** user submits form without product name, **When** validation triggers, **Then** form displays "Product name is required" error
4. **Given** user uploads image exceeding size limit, **When** image selection occurs, **Then** app silently compresses to <5MB using 85% quality (no user notification)
5. **Given** nutrition values entered with invalid units, **When** form validates, **Then** system converts to standard units (per 100g) or displays conversion error

---

### User Story 5 - Enhanced Offline Experience (Priority: P3)

As a user in areas with poor connectivity, I need clear feedback about offline status and pending operations so I understand what's happening with my data.

**Why this priority**: Offline-first architecture exists but user visibility is limited. Enhanced feedback builds trust and reduces confusion about sync status.

**Independent Test**: Can be verified by enabling airplane mode, performing operations (search cached products, add to favorites, upload product), then checking UI displays appropriate offline indicators and pending operation count.

**Acceptance Scenarios**:

1. **Given** device is offline, **When** user searches for cached product, **Then** product details display with "Offline - Cached Data" indicator showing cache age (standard indicator only, no special stale warnings)
2. **Given** user uploads product while offline, **When** operation queues, **Then** success message states "Product queued for upload when online (3 pending)" with count
3. **Given** pending uploads exist, **When** user navigates to main FoodSearch screen, **Then** app bar shows badge beside search icon with pending count, tapping opens dedicated pending uploads screen
4. **Given** user opens app or taps sync button with pending uploads, **When** manual sync triggers, **Then** app uploads queued items and shows notification: "2 products uploaded successfully to OpenFoodFacts"
5. **Given** pending upload fails, **When** 3 retry attempts exhausted, **Then** user receives notification with option to review and manually retry failed uploads

---

### User Story 6 - Pending Uploads Management (Priority: P3)

As a user who submitted products offline, I need visibility into pending uploads and ability to manage them so I can ensure my contributions reach OpenFoodFacts.

**Why this priority**: Completes the offline-first story by giving users control over queued operations. Builds confidence in offline functionality.

**Independent Test**: Can be verified by queuing multiple product submissions offline, then viewing pending uploads list showing all queued items with status, and ability to retry or cancel individual items.

**Acceptance Scenarios**:

1. **Given** user has pending product uploads, **When** tapping badge in main navigation app bar (beside search icon), **Then** dedicated pending uploads screen opens showing list of queued products with thumbnail, name, and timestamp
2. **Given** pending upload in list, **When** user taps item, **Then** detail view shows full product data and allows editing before retry
3. **Given** pending upload selected, **When** user chooses "Retry Now" action, **Then** app attempts immediate upload with progress indicator (counts toward 3 retry limit)
4. **Given** pending upload fails repeatedly, **When** user chooses "Cancel Upload", **Then** app removes from queue with confirmation dialog
5. **Given** user on pending uploads screen with connectivity, **When** user taps "Sync All" button, **Then** app manually triggers upload of all queued items with progress feedback

---

### Edge Cases

- What happens when OpenFoodFacts API is down but device is online? (Should cache-first strategy still work and queue writes)
- How does system handle partial OCR extraction where only some nutrition values detected? (Display extracted values, mark others as "Not detected")
- What if user uploads product with barcode that already exists in OpenFoodFacts? (Should update existing product, not create duplicate)
- How does app handle extremely large images (>10MB) for product photos? (Silently auto-compress to <5MB using 85% quality before upload)
- What if cache becomes stale (>7 days) but device is offline? (Display standard cache age indicator - no special stale warnings needed)
- How does filtering handle products missing optional fields (no NOVA group, no Nutri-Score)? (Products without data should fail that filter criteria, not crash)
- What happens when pending uploads queue grows very large (50+ items)? (Implement pagination or limit queue size with warning)

## Requirements

### Functional Requirements

- **FR-001**: System MUST have unit tests covering all 14 use cases in domain layer with minimum 70% code coverage
- **FR-002**: System MUST have integration tests verifying repository implementations handle cache-first strategy correctly
- **FR-003**: System MUST have widget tests for OCR scanner, product form, and product comparison screens
- **FR-004**: System MUST remove all direct usage of deprecated ProductUseCases facade from presentation layer
- **FR-005**: System MUST use individual use case providers for all food search operations
- **FR-006**: System MUST remove unused imports identified by Flutter analyzer (nutrition_facts.dart in product_form_screen.dart)
- **FR-007**: System MUST remove 3 commented controllers (ingredientsController, servingSizeController, countriesController) and commented ProductDetailsFields widget from product_form_screen.dart - form keeps only barcode, name, brand, quantity, and nutrition fields
- **FR-008**: System MUST replace debugPrint statements with TalkerService logging in production code
- **FR-009**: System MUST validate barcode format (8-13 digits) before allowing product submission
- **FR-010**: System MUST validate required fields (barcode, product name) with inline error messages
- **FR-011**: System MUST compress uploaded images exceeding 5MB silently (no user notification) before upload using 85% quality setting
- **FR-012**: System MUST display offline indicator with cache age when showing cached products offline (no special stale data warnings needed)
- **FR-013**: System MUST show pending uploads count badge in main FoodSearch navigation app bar (beside search icon) when items queued
- **FR-014**: System MUST provide dedicated pending uploads management screen with route `/food-search/pending-uploads` accessible from main navigation app bar badge
- **FR-015**: System MUST allow users to retry, edit, or cancel individual pending uploads with concise confirmation dialog ("Remove '[Product Name]' from upload queue?" with [Cancel] [Remove] buttons)
- **FR-016**: System MUST notify users when pending uploads successfully sync after manual sync trigger (app foreground or sync button press)
- **FR-017**: System MUST handle OpenFoodFacts API failures gracefully by falling back to cache and queuing writes
- **FR-018**: System MUST limit pending upload retry attempts to maximum 3 attempts before requiring user intervention
- **FR-019**: System MUST provide manual sync trigger ("Sync All" button) in pending uploads screen to upload all queued items

### Key Entities

- **Test Suite**: Collection of unit, widget, and integration tests covering FoodSearch feature with minimum 70% coverage
- **Use Case Provider**: Riverpod provider exposing individual use case for specific operation (search, filter, favorite, etc.)
- **Pending Upload**: Queued product submission waiting for connectivity, includes product data, timestamp, retry count (max 3), and status (pending/uploading/failed)
- **Validation Rule**: Business logic determining if product submission data meets OpenFoodFacts requirements
- **Offline Indicator**: UI component showing cache status, age, and sync state to user
- **Pending Uploads Queue**: Hive-backed collection of pending product submissions with metadata

## Success Criteria

### Measurable Outcomes

- **SC-001**: FoodSearch feature achieves minimum 70% test coverage as measured by `flutter test --coverage`
- **SC-002**: Zero lint warnings related to unused imports or deprecated API usage in FoodSearch directory
- **SC-003**: Users see pending upload count within 500ms of queuing offline product upload
- **SC-004**: Product upload form prevents upload with invalid data 100% of the time through validation
- **SC-005**: Cached products display offline indicator showing cache age accurate to the hour (no special stale warnings)
- **SC-006**: Pending uploads sync within 30 seconds of manual trigger (app foreground or sync button press) - verified via performance test
- **SC-007**: Users can view, retry, or cancel pending uploads from dedicated management screen at route `/food-search/pending-uploads`
- **SC-008**: Image compression reduces image size by average 60% while maintaining visual quality for uploads (85% quality setting) - verified via performance test
- **SC-009**: Code review confirms zero commented-out production code and all comments explain "why" not "what"
- **SC-010**: Migration eliminates all ProductUseCases references (except facade itself) verified by codebase search

## Assumptions

1. **Testing Infrastructure**: Assumes test infrastructure (mockito/mocktail for mocks, test fixtures) is already configured in project
2. **OpenFoodFacts API Stability**: Assumes OpenFoodFacts API contracts remain stable - validation rules match their current requirements
3. **Image Compression**: Assumes `flutter_image_compress: ^4.5.0` package is available for silent compression at 85% quality
4. **Notification Support**: Assumes `flutter_local_notifications: ^19.4.2` is configured for sync completion notifications
5. **Manual Sync**: Manual sync triggered when app comes to foreground or user taps sync button - no true background processing required
6. **Network Status**: Assumes `ConnectivityChecker` accurately reflects device connectivity status
7. **User Behavior**: Assumes users typically queue fewer than 50 pending uploads - queue management optimized for this scale
8. **Terminology**: "Upload" is used consistently (not "submission") throughout codebase and UI

## Out of Scope

- Complete redesign of FoodSearch UI/UX (polish only, no major visual changes)
- Migration from Hive to different local database (keep existing Hive implementation)
- Advanced OCR improvements beyond current ML Kit capabilities
- Multi-language OCR support (current English-only OCR is sufficient)
- Integration with other food databases beyond OpenFoodFacts
- Barcode generation or printing features
- Social features (sharing products, reviews, ratings)
- Nutritional meal planning or calorie tracking integration
- Product recommendation algorithms

## Dependencies

- **Internal**: Depends on `core/services/connectivity.dart` for network status
- **Internal**: Depends on `core/services/talker_service.dart` for logging
- **Internal**: Depends on `core/services/hive_boxes.dart` for local storage
- **External**: OpenFoodFacts API availability and stability
- **External**: Google ML Kit for OCR functionality (already integrated)
- **External**: `flutter_image_compress: ^4.5.0` package for silent image optimization (85% quality)
- **External**: `flutter_local_notifications: ^19.4.2` for sync notifications
- **External**: `openfoodfacts: ^3.27.0` for OpenFoodFacts API integration

## Related Documentation

- [FoodSearch README.md](../../../lib/features/FoodSearch/README.md) - Feature overview and architecture
- [REFACTORING_SUMMARY.md](../../../lib/features/FoodSearch/domain/REFACTORING_SUMMARY.md) - Domain layer refactoring details
- [MIGRATION_CHECKLIST.md](../../../lib/features/FoodSearch/domain/MIGRATION_CHECKLIST.md) - Migration progress tracking
- [FOOD_SEARCH_ANALYSIS.md](../../../lib/features/FoodSearch/FOOD_SEARCH_ANALYSIS.md) - Comprehensive feature analysis
- [Constitution](../../../.specify/memory/constitution.md) - Project governance and principles

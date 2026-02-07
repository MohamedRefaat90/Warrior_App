# Implementation Plan: FoodSearch Polish & Completion

**Branch**: `001-food-search-polish` | **Date**: 2026-02-07 | **Spec**: [spec.md](./spec.md)
**Input**: Feature specification from `/specs/001-food-search-polish/spec.md`

**Note**: This template is filled in by the `/speckit.plan` command. See `.specify/templates/commands/plan.md` for the execution workflow.

## Summary

This feature polishes and completes the existing FoodSearch module by adding comprehensive test coverage (70% minimum), cleaning up deprecated code patterns, implementing product submission validation, and enhancing the offline user experience with visible pending uploads management. The work focuses on quality improvements rather than new functionality - creating a complete test suite from scratch, migrating to individual use cases architecture, removing code cruft, and adding user-facing feedback for offline operations.

## Technical Context

**Language/Version**: Flutter 3.5.3+ / Dart 3.5.3+  
**Primary Dependencies**: Riverpod 3, GoRouter, Hive, Dio, Firebase Auth, Google ML Kit, flutter_image_compress, flutter_local_notifications  
**Storage**: Hive (local NoSQL for caching, favorites, search history, pending uploads)  
**Testing**: flutter_test (widget), package:test (unit), integration_test (E2E), mockito/mocktail (mocks)  
**Target Platform**: iOS 15+, Android 8.0+ (API 26+)  
**Project Type**: Flutter mobile application (feature-first architecture)  
**Performance Goals**: 60fps UI, <200ms navigation, <500ms pending upload UI update, 70% test coverage minimum  
**Constraints**: Offline-first (full functionality without network), manual sync only (no background processing), 3 retry limit for failed uploads, simple product form (5 fields), image compression to <5MB  
**Scale/Scope**: Enhancement to existing FoodSearch feature (~20 files), add ~30 test files, 1 new screen (pending uploads), update 5 existing screens

## Constitution Check

*GATE: Must pass before Phase 0 research. Re-check after Phase 1 design.*

**Reference**: `.specify/memory/constitution.md` (Version 1.0.0)

### Principle I: Feature-First Architecture
- [x] Feature is organized under `lib/features/[FeatureName]/` ✅ FoodSearch already properly organized
- [x] Contains appropriate subdirectories: `screens/`, `widgets/`, `providers/`, `models/`, `repo/`, `data_sources/` ✅ All present
- [x] Cross-feature dependencies routed through `lib/core/` ✅ Uses core services (connectivity, talker, hive)
- [ ] Feature has independent test directory ⚠️ NEEDS CREATION - tests missing (P1 story addresses this)

### Principle II: SOLID & Clean Code
- [x] Classes/functions follow Single Responsibility Principle ✅ Individual use cases implemented
- [x] Dependencies use abstractions (interfaces/abstract classes) ✅ Repository pattern with interfaces
- [ ] Code follows Effective Dart guidelines (80 char lines, naming conventions) ⚠️ PARTIAL - unused imports exist (P2 story addresses this)
- [x] Null safety enforced without unnecessary `!` operators ✅ Sound null safety throughout

### Principle III: Offline-First Design
- [x] Feature functions without internet connectivity ✅ Offline-first architecture implemented
- [x] Hive local storage is primary data source ✅ Cache-first strategy in repositories
- [x] Network operations have offline fallbacks ✅ Try-catch with offline queueing
- [x] Repository checks cache before remote fetch ✅ Cache freshness checks (7-day TTL)
- [x] UI never blocks on network operations ✅ Async operations with loading states

### Principle IV: Test-Driven Development
- [ ] Tests written before implementation (Red-Green-Refactor) ❌ NO TESTS EXIST - P1 story creates full suite
- [ ] Unit tests for business logic and models ❌ MISSING
- [ ] Widget tests for UI components ❌ MISSING
- [ ] Integration tests for critical user flows ❌ MISSING
- [ ] Test coverage maintains ≥70% target ❌ CURRENTLY 0% for FoodSearch

### Principle V: State Management Standards
- [x] Riverpod 3 used for app state management ✅ All providers use Riverpod 3
- [x] StatefulWidget used only for ephemeral UI state ✅ Proper separation
- [x] Providers placed in feature's `providers/` directory ✅ Organized correctly
- [x] No UI logic in providers ✅ Business logic in use cases
- [x] Appropriate use of `family` and `autoDispose` modifiers ✅ Proper provider configuration

### Principle VI: UI/UX Excellence
- [x] Supports light and dark themes ✅ Material theme support
- [x] Text contrast meets WCAG 4.5:1 minimum ✅ Theme configuration compliant
- [x] Semantic labels for accessibility ✅ Screen reader support
- [x] `const` constructors used where applicable ✅ Performance optimizations present
- [x] Long lists use `.builder` constructors ✅ ListView.builder used
- [x] Heavy computations offloaded to isolates ✅ OCR processing properly handled
- [x] Supports Arabic (RTL) and English localization ✅ L10n integration
- [x] Responsive design with ScreenUtil/MediaQuery ✅ Responsive layouts

**Violations Requiring Justification**:

| Principle | Violation | Justification | Resolution |
|-----------|-----------|---------------|------------|
| Test-Driven Development (IV) | No tests exist despite feature being "complete" | Legacy code developed before constitution ratification; tests were documented but never created | P1 story creates complete test suite before any refactoring |
| SOLID & Clean Code (II) | Unused imports and commented code present | Technical debt accumulated during rapid feature development | P2 story cleans up code quality issues |

**Initial Constitution Check**: ⚠️ CONDITIONAL PASS with 2 violations justified above. P1 and P2 stories directly address violations.

## Project Structure

### Documentation (this feature)

```text
specs/[###-feature]/
├── plan.md              # This file (/speckit.plan command output)
├── research.md          # Phase 0 output (/speckit.plan command)
├── data-model.md        # Phase 1 output (/speckit.plan command)
├── quickstart.md        # Phase 1 output (/speckit.plan command)
├── contracts/           # Phase 1 output (/speckit.plan command)
└── tasks.md             # Phase 2 output (/speckit.tasks command - NOT created by /speckit.plan)
```

### Source Code (repository root)
<!--
  ACTION REQUIRED: Replace the placeholder tree below with the concrete layout
  for this feature. Delete unused options and expand the chosen structure with
  real paths (e.g., lib/features/Auth, lib/features/Workouts). The delivered 
  plan must not include Option labels.
-->

```text
lib/
├── features/
│   └── FoodSearch/                    # Existing feature being polished
│       ├── data/
│       │   ├── models/                # Food models with Hive adapters (existing)
│       │   ├── data_sources/          # Remote (API) and Local (Hive) sources (existing)
│       │   └── repositories/          # Repository implementations (existing)
│       ├── domain/
│       │   ├── entities/              # Domain entities (existing)
│       │   ├── repositories/          # Repository interfaces (existing)
│       │   └── usecases/              # 14 individual use cases (existing, cleanup facade)
│       └── presentation/
│           ├── providers/             # Riverpod providers (update to use individual use cases)
│           ├── screens/               # Existing screens + NEW: pending_uploads_screen.dart
│           └── widgets/               # Existing widgets (update validation, offline indicators)
└── core/
    └── services/                      # Shared services (connectivity, talker, hive)

test/                                  # NEW: Complete test suite creation
├── unit/
│   └── food_search/                   # NEW: Unit tests for 14 use cases
│       ├── usecases/                  # Test each use case independently
│       ├── repositories/              # Test repository implementations
│       └── models/                    # Test data models
├── widget/
│   └── food_search/                   # NEW: Widget tests for screens
│       ├── product_form_test.dart     # Test validation logic
│       ├── ocr_scanner_test.dart      # Test OCR UI
│       ├── product_comparison_test.dart
│       └── pending_uploads_test.dart  # NEW screen test
└── integration/
    └── food_search/                   # NEW: E2E flow tests
        ├── offline_submission_test.dart
        ├── pending_sync_test.dart
        └── search_and_favorite_test.dart

specs/001-food-search-polish/         # This feature's documentation
├── spec.md                            # Feature specification (complete)
├── plan.md                            # This file
├── research.md                        # Phase 0: Technical research (next)
├── data-model.md                      # Phase 1: Entity schemas
├── quickstart.md                      # Phase 1: Developer guide
├── contracts/                         # Phase 1: Validation contracts
└── checklists/                        # Quality validation checklists
```

**Structure Decision**: Enhancement to existing `lib/features/FoodSearch/` directory. No new feature created. Main changes: (1) Create complete `test/unit|widget|integration/food_search/` hierarchy from scratch, (2) Add new `pending_uploads_screen.dart` in existing `presentation/screens/`, (3) Update existing providers to use individual use cases, (4) Clean up deprecated code.

## Complexity Tracking

> **Fill ONLY if Constitution Check has violations that must be justified**

| Violation | Why Needed | Simpler Alternative Rejected Because |
|-----------|------------|-------------------------------------|
| No tests (TDD Principle IV) | Tests missing from original implementation | Cannot retrofit TDD to existing code, but P1 story creates full suite before proceeding with refactoring |
| Code quality issues (SOLID Principle II) | Technical debt from rapid development cycle | Cleanup deferred to avoid blocking feature delivery, now addressed in P2 story |

**Justification**: Both violations are temporary and directly addressed by prioritized user stories. P1 creates tests first (enabling safe refactoring), then P2 cleans code quality. No new violations introduced - only resolving existing technical debt.

---

## Phase 0: Research (COMPLETED)

✅ **Status**: Complete  
📄 **Artifact**: [research.md](./research.md)

All technical unknowns resolved through 5 research tasks:
1. **Testing Strategy**: Flutter testing frameworks (unit/widget/integration), AAA pattern, 70% coverage target
2. **Image Compression**: flutter_image_compress at 85% quality, 1920px max dimension, 60% size reduction
3. **Local Notifications**: flutter_local_notifications v19.4.2 (already in dependencies), simple notification channel
4. **OpenFoodFacts Validation**: Barcode 8-13 digits regex, product name 2-200 chars required
5. **Offline Indicator UI**: Badge + timestamp pattern, color-coded fresh (<7 days) / stale (>7 days)

**Outcome**: All NEEDS CLARIFICATION items from Technical Context resolved. Ready for Phase 1 design.

---

## Phase 1: Design & Contracts (COMPLETED)

✅ **Status**: Complete  
📄 **Artifacts**: 
- [data-model.md](./data-model.md) - Entity schemas and Hive migration plan
- [contracts/product-validation.contract.md](./contracts/product-validation.contract.md) - Field validation rules with test cases
- [contracts/openfoodfacts-api.contract.md](./contracts/openfoodfacts-api.contract.md) - API integration contracts
- [quickstart.md](./quickstart.md) - Developer setup and testing guide

### Data Model Summary

**New/Enhanced Entities**:
- `PendingProductUpload` (enhanced): Added retry tracking (0-3), status enum, last attempt timestamp, failure reason
- `PendingUploadStatus` (new enum): pending, uploading, failed
- `ProductValidationResult` (new): Validation result with field errors map
- `FoodProductModel` (enhanced): Added cache metadata (cachedAt, source enum)
- `ProductDataSource` (new enum): cache, remote, local_submission
- `SyncResult` (new): Sync operation results for notifications

**Hive Changes**:
- Type ID 8: PendingUploadStatus enum
- Type ID 9: ProductDataSource enum
- Migration script for existing PendingProductUpload records

### Validation Contracts Summary

**Validators**:
1. `BarcodeValidator`: Required, 8-13 digits regex, test cases (7)
2. `ProductNameValidator`: Required, 2-200 chars, test cases (7)
3. `BrandValidator`: Optional, max 100 chars, test cases (3)
4. `QuantityValidator`: Optional, max 50 chars, test cases (3)
5. `NutritionValidator`: Optional, range validation (0-100g macros, 0-9999 kcal energy), test cases (10+)

**Total Test Cases Required**: 30+ for validation layer alone

### API Contracts Summary

**Endpoints**:
- GET `/api/v2/product/{barcode}` - Fetch product (10s timeout, 7-day cache)
- POST `/cgi/product_jqm2.pl` - Submit product (15s timeout, form data)

**Error Handling**: 5 categories (network, timeout, not found, invalid, server) with retry strategies

**Offline Behavior**: Queue-first for submissions, cache-first for reads, manual sync only, exponential backoff (0s, 5s, 15s)

### Agent Context Update

✅ **Copilot Context Updated**: `.github/agents/copilot-instructions.md`  
Added: Flutter 3.5.3+, Riverpod 3, Hive, Dio, firebase_auth, google_mlkit, flutter_image_compress, flutter_local_notifications

---

## Phase 1 Constitution Re-Check

*Post-design evaluation of constitution compliance*

### Principle I: Feature-First Architecture
- [x] Feature organized correctly ✅ (no changes)
- [x] Test directory structure defined ✅ NEW: test/unit|widget|integration/food_search/
- **Status**: PASS

### Principle II: SOLID & Clean Code
- [ ] Code cleanup pending ⚠️ (P2 story)
- [x] Validation layer follows SRP ✅ NEW: Individual validator classes per field
- **Status**: PARTIAL (improved with new validators, full resolution in P2)

### Principle III: Offline-First Design
- [x] Offline contracts defined ✅ NEW: Queue strategy, retry logic, cache TTL documented
- [x] Error handling comprehensive ✅ NEW: 5 error categories with user messages
- **Status**: PASS

### Principle IV: Test-Driven Development
- [x] Test structure defined ✅ NEW: 30+ test files specified
- [ ] Tests not yet written ⚠️ (P1 story implementation)
- **Status**: PARTIAL (architecture ready, implementation next)

### Principle V: State Management Standards
- [x] Provider patterns documented ✅ (no changes)
- **Status**: PASS

### Principle VI: UI/UX Excellence
- [x] Offline indicators designed ✅ NEW: Badge + timestamp UI pattern
- [x] Validation UX specified ✅ NEW: Inline errors, real-time validation
- **Status**: PASS

**Updated Violations**:
- TDD violation remains (tests pending implementation in P1 story)
- Code quality violation remains (cleanup pending in P2 story)

**Conclusion**: Phase 1 design provides architecture for resolving both violations. No new violations introduced. Ready for task breakdown (Phase 2).

---

## Next Steps

### Immediate: Generate Task Breakdown
Run `/speckit.tasks` command to generate `tasks.md` from this plan and spec.

**Command**: `/speckit.tasks`  
**Output**: `specs/001-food-search-polish/tasks.md` with granular task list

### Development Workflow
1. Review `quickstart.md` for environment setup
2. Follow TDD workflow: Write tests → Implement → Refactor
3. Reference contracts for validation rules and API integration
4. Use data-model.md for Hive schema changes
5. Track progress against tasks.md checklist

### Branch Management
- **Current Branch**: 001-food-search-polish
- **Target Branch**: main/develop (check with team)
- **Merge Strategy**: Squash + rebase (check with team)

---

## Report Summary

**Feature**: 001-food-search-polish  
**Branch**: `001-food-search-polish`  
**Implementation Plan**: `B:\Fullstack Projects\Warrior_App\specs\001-food-search-polish\plan.md`

**Generated Artifacts**:
- ✅ research.md (Phase 0 complete)
- ✅ data-model.md (Phase 1 complete)
- ✅ quickstart.md (Phase 1 complete)
- ✅ contracts/product-validation.contract.md (Phase 1 complete)
- ✅ contracts/openfoodfacts-api.contract.md (Phase 1 complete)
- ✅ .github/agents/copilot-instructions.md (agent context updated)
- ⏳ tasks.md (pending `/speckit.tasks` command)

**Constitution Status**: ⚠️ Conditional pass with 2 justified violations (TDD, code quality) - both resolved by P1/P2 stories.

**Ready for**: Task breakdown generation via `/speckit.tasks` command.

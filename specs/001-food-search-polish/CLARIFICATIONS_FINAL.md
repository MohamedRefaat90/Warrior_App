# Final Clarifications - FoodSearch Polish

**Date**: 2026-02-07  
**Feature**: 001-food-search-polish  
**Status**: Ready for Implementation

---

## Implementation Decisions

### ✅ Q1: Commented Product Form Fields (HIGH Priority)
**Decision**: OPTION A - Delete all commented code completely

**Action Taken**:
- Identified 3 commented controllers: `ingredientsController`, `servingSizeController`, `countriesController`
- Identified 1 commented widget section: `ProductDetailsFields`
- Updated FR-007 with exact list
- Updated Task T066-T068 with specific deletion targets

---

### ✅ Q2: Stale Cache Warning Design (MEDIUM Priority)
**Decision**: Feature not needed - remove from scope

**Action Taken**:
- Removed stale cache warning requirements from spec
- Updated FR-012: Standard cache age indicator only, no special warnings
- Updated US5 acceptance scenarios: Remove stale warning mentions
- Updated Edge Cases: Clarified standard indicator for 7-day+ cache
- Updated SC-005: No special stale warnings
- Updated Task T084: Standard cache display only

**Result**: Simpler implementation, less UI complexity

---

### ✅ Q3: Image Compression User Feedback (MEDIUM Priority)
**Decision**: OPTION C - Silent compression with no notification

**Action Taken**:
- Updated FR-011: Silent compression at 85% quality, no user notification
- Updated US4 acceptance scenario #4: Remove compression notification
- Updated Edge Cases: Silent auto-compress to <5MB
- No compressed image preview before upload - trust 85% quality from research

**Result**: Seamless user experience, no interruptions

---

### ✅ Q4: Delete Pending Upload Confirmation (MEDIUM Priority)
**Decision**: OPTION B - Concise dialog

**Action Taken**:
- Updated FR-015 with dialog text: "Remove '[Product Name]' from upload queue?"
- Buttons: [Cancel] [Remove]
- Updated Task T101 with exact dialog specification

---

### ✅ Q5: Pending Uploads Screen Route Path (MEDIUM Priority)
**Decision**: OPTION A - `/food-search/pending-uploads`

**Action Taken**:
- Updated FR-014 with exact route path
- Updated SC-007 with route path
- Updated Task T097: Add route '/food-search/pending-uploads'

**Result**: RESTful, clear hierarchy, discoverable

---

### ✅ Q6: Performance Testing for SC-006 & SC-008 (MEDIUM Priority)
**Decision**: OPTION A - Add 2 dedicated performance test tasks

**Action Taken**:
- Added Task T116: Performance test for sync latency (target: <30s, verifies SC-006)
- Added Task T117: Performance test for image compression ratio (target: ≥60%, verifies SC-008)
- Updated task count summary: 115 → 117 tasks
- Updated SC-006 and SC-008 with "verified via performance test" note

**Result**: Measurable quality gates, enforceable success criteria

---

### ✅ Q7: Package Version Constraints (MEDIUM Priority)
**Decision**: OPTION A - Semantic versioning with specific minimums

**Action Taken**:
- Updated spec Assumptions with versions:
  - `flutter_image_compress: ^4.5.0` (minimum for format preservation)
  - `flutter_local_notifications: ^19.4.2` (exact version, already installed)
  - `openfoodfacts: ^3.27.0` (current major version)
- Updated spec Dependencies section with versions
- Updated Task T005: Verify package versions in pubspec.yaml

**Result**: Prevents breaking changes, explicit compatibility

---

### ✅ Q8: Hive TypeId Collision Prevention (MEDIUM Priority)
**Decision**: OPTION A - Pre-flight check before code generation

**Action Taken**:
- Updated Task T012 with pre-flight check:
  ```bash
  grep -r "@HiveType(typeId:" lib/ | grep -oE "typeId: [0-9]+" | sort
  # Verify output shows 0-9 with no duplicates
  ```
- Then proceed with: `dart run build_runner build --delete-conflicting-outputs`

**Result**: Prevents Hive schema corruption, safe migration

---

### ✅ Q9: Terminology Standardization (LOW Priority)
**Decision**: OPTION A - Use "upload" consistently (not "submission")

**Action Taken**:
- Updated spec.md: All "product submission" → "product upload"
- Updated Assumptions: Added #8 - "Upload" terminology note
- Already consistent in tasks.md

**Result**: Clear, concise terminology throughout

---

### ✅ Q10: Success Criteria Tracking in Tasks (MEDIUM Priority)
**Decision**: OPTION A - Add SC references to each checkpoint

**Action Taken**:
- Phase 3 checkpoint: Added SC-001, SC-002
- Phase 4 checkpoint: Added SC-010
- Phase 5 checkpoint: Added SC-002, SC-009
- Phase 6 checkpoint: Added SC-004
- Phase 7 checkpoint: Added SC-003, SC-005
- Phase 8 checkpoint: Added SC-007

**Result**: Clear traceability from tasks to success criteria

---

## Updated Metrics

| Metric | Value | Change |
|--------|-------|--------|
| **Total Requirements** | 36 | No change |
| **Total Tasks** | 117 | +2 (performance tests) |
| **Requirement Coverage** | 100% | +8% (performance tests added) |
| **Parallelizable Tasks** | 58 | No change |
| **Success Criteria Mapped** | 10/10 | +2 (SC-006, SC-008 now testable) |

---

## Files Updated

✅ **spec.md**:
- Clarifications section (exact commented fields)
- FR-007, FR-011, FR-012, FR-014, FR-015 (technical details)
- US4, US5 acceptance scenarios (UX clarifications)
- Edge Cases (removed stale warnings, silent compression)
- Success Criteria (performance tests, route path)
- Assumptions (package versions, terminology)
- Dependencies (package versions)

✅ **tasks.md**:
- Phase 1 Task T005 (package version verification)
- Phase 2 Task T012 (typeId collision check)
- Phase 5 Tasks T066-T068 (exact commented fields)
- Phase 7 Task T084 (remove stale warnings)
- Phase 8 Tasks T097, T101, T102 (route path, dialog text, button state)
- Phase 9 Tasks T114, T116, T117 (localization, performance tests)
- All checkpoints (SC references added)
- Task count summary (115 → 117)

✅ **plan.md**: No changes required (already aligned)

---

## Implementation Status

🟢 **READY FOR IMPLEMENTATION**

All critical ambiguities resolved. All HIGH and MEDIUM priority decisions finalized. Tasks are clear, testable, and have concrete acceptance criteria.

### Next Steps

1. Review this clarifications document
2. Begin Phase 1: Setup (Tasks T001-T005)
3. Proceed to Phase 2: Foundational (Tasks T006-T014)
4. Follow task order as specified in tasks.md

### Constitution Compliance

✅ Both violations justified and addressed:
- **TDD (P1)**: Tasks T015-T050 create full test suite
- **Code Quality (P2)**: Tasks T061-T071 clean up deprecated code

**Merge Condition**: Both violations MUST be resolved before PR merge to main.

---

## Quick Reference

### Key Paths
- **Route**: `/food-search/pending-uploads`
- **Form Screen**: `lib/features/FoodSearch/presentation/screens/product_form_screen.dart`

### Key Values
- **Test Coverage Target**: 70%
- **Image Compression Quality**: 85%
- **Max Retry Attempts**: 3
- **Sync Latency Target**: <30s
- **Compression Ratio Target**: ≥60%

### Key Packages
- `flutter_image_compress: ^4.5.0`
- `flutter_local_notifications: ^19.4.2`
- `openfoodfacts: ^3.27.0`

### Deleted Elements
- `ingredientsController` (commented)
- `servingSizeController` (commented)
- `countriesController` (commented)
- `ProductDetailsFields` widget (commented section)
- Stale cache warning feature (entire feature removed from scope)

---

**End of Clarifications Document**

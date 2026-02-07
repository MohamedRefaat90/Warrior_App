# Quickstart Guide: FoodSearch Polish Implementation

**Feature**: 001-food-search-polish  
**Branch**: `001-food-search-polish`  
**Last Updated**: 2026-02-07

## Overview

This quickstart guide walks developers through setting up their environment, running tests, and implementing the FoodSearch polish feature. Follow these steps in order to ensure a smooth development experience.

---

## Prerequisites

Before starting, ensure you have:

- ✅ **Flutter SDK**: 3.5.3 or higher
- ✅ **Dart SDK**: 3.5.3 or higher
- ✅ **IDE**: VS Code or Android Studio with Flutter/Dart plugins
- ✅ **Git**: Latest version for branch management
- ✅ **Android Studio**: For Android emulator (optional)
- ✅ **Xcode**: For iOS simulator (macOS only, optional)

### Verify Installation

```powershell
# Check Flutter version
flutter --version

# Check Dart version
dart --version

# Run Flutter doctor to check setup
flutter doctor -v
```

Expected output:
```
Flutter 3.5.3 • channel stable
Dart 3.5.3
```

---

## Step 1: Clone & Setup Repository

### 1.1 Clone the Repository (If Not Already Done)

```powershell
git clone <repository-url>
cd Warrior_App
```

### 1.2 Checkout Feature Branch

```powershell
# Ensure you're on the feature branch
git checkout 001-food-search-polish

# Pull latest changes
git pull origin 001-food-search-polish
```

### 1.3 Install Dependencies

```powershell
# Install Flutter dependencies
flutter pub get

# Run code generation (for Hive adapters, JSON serialization)
dart run build_runner build --delete-conflicting-outputs
```

**Expected output**: All dependencies installed successfully, no errors.

---

## Step 2: Configure Development Environment

### 2.1 Configure Firebase (Required)

1. Copy `firebase_config.example` to create local config:
   ```powershell
   Copy-Item firebase_config.example firebase.json
   ```

2. Update with your Firebase project credentials (ask team lead if needed)

### 2.2 Set Up Test Configuration

1. Copy test config template:
   ```powershell
   Copy-Item test_config.yaml.example test_config.yaml
   ```

2. Configure OpenFoodFacts test credentials (use test account):
   ```yaml
   openfoodfacts:
     test_user: "warrior_app_test"
     test_password: ""  # Anonymous for now
     base_url: "https://world.openfoodfacts.org"
   ```

### 2.3 Initialize Hive Boxes (Test Data)

Run initialization script to set up test database:

```powershell
flutter run lib/core/scripts/init_hive_test_data.dart
```

This creates:
- Empty pending uploads box
- Sample cached products (for offline testing)
- Test user favorites

---

## Step 3: Run the Application

### 3.1 Start Emulator/Simulator

**Option A: Android Emulator**
```powershell
# List available emulators
flutter emulators

# Launch emulator
flutter emulators --launch <emulator_id>
```

**Option B: iOS Simulator (macOS only)**
```powershell
# Launch default simulator
open -a Simulator
```

### 3.2 Run the App

```powershell
# Run in debug mode
flutter run

# OR specify device
flutter run -d <device_id>
```

### 3.3 Navigate to FoodSearch Feature

1. Open app on device/emulator
2. Tap **"Food Search"** from bottom navigation bar
3. Explore existing screens:
   - Search screen
   - Scan barcode screen
   - Product details screen
   - Favorites screen

---

## Step 4: Run Tests

### 4.1 Run All Tests

```powershell
# Run all test suites
flutter test

# Run with coverage report
flutter test --coverage

# View coverage in HTML
genhtml coverage/lcov.info -o coverage/html
Start-Process coverage/html/index.html
```

### 4.2 Run Specific Test Suites

**Unit Tests**:
```powershell
flutter test test/unit/food_search/
```

**Widget Tests**:
```powershell
flutter test test/widget/food_search/
```

**Integration Tests** (requires running app):
```powershell
flutter test integration_test/food_search_flow_test.dart
```

### 4.3 Run Tests in Watch Mode

For TDD workflow, use watch mode to auto-run tests on file changes:

```powershell
flutter test --watch
```

---

## Step 5: Development Workflow

### 5.1 Feature Development Checklist

Follow this checklist for each user story:

- [ ] **Read spec**: Review requirements in `specs/001-food-search-polish/spec.md`
- [ ] **Read contracts**: Review validation rules in `contracts/`
- [ ] **Write tests first** (TDD):
  - [ ] Unit tests for business logic
  - [ ] Widget tests for UI components
  - [ ] Integration tests for user flows
- [ ] **Implement feature**:
  - [ ] Data layer (models, repositories)
  - [ ] Domain layer (entities, use cases)
  - [ ] Presentation layer (screens, widgets, state)
- [ ] **Run tests**: Ensure all tests pass
- [ ] **Manual testing**: Test on real device/emulator
- [ ] **Code review**: Self-review before PR
- [ ] **Format code**: Run `dart format .`
- [ ] **Lint check**: Run `flutter analyze`

### 5.2 TDD Workflow Example

**Goal**: Implement barcode validation (User Story 1.4)

**Step 1**: Write failing test
```dart
// test/unit/food_search/validators/barcode_validator_test.dart
test('BarcodeValidator accepts valid EAN-13', () {
  final result = BarcodeValidator.validate('5449000000996');
  expect(result, isNull);
});

test('BarcodeValidator rejects invalid format', () {
  final result = BarcodeValidator.validate('invalid');
  expect(result, equals('Barcode must be 8-13 digits'));
});
```

**Step 2**: Run test (should fail)
```powershell
flutter test test/unit/food_search/validators/barcode_validator_test.dart
```

**Step 3**: Implement validator
```dart
// lib/features/FoodSearch/domain/validators/barcode_validator.dart
class BarcodeValidator {
  static const _pattern = r'^\d{8,13}$';
  static final _regex = RegExp(_pattern);
  
  static String? validate(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Barcode is required';
    }
    if (!_regex.hasMatch(value.trim())) {
      return 'Barcode must be 8-13 digits';
    }
    return null;
  }
}
```

**Step 4**: Run test again (should pass)
```powershell
flutter test test/unit/food_search/validators/barcode_validator_test.dart
```

**Step 5**: Add more test cases (edge cases, boundaries)

**Step 6**: Refactor if needed, ensuring tests still pass

---

## Step 6: Testing Offline Behavior

### 6.1 Simulate Offline Mode

**Option A: Device Settings**
1. Open device settings
2. Turn off Wi-Fi and mobile data
3. Test app behavior

**Option B: Firebase Remote Config** (if enabled)
```dart
// In debug mode, force offline
await FirebaseRemoteConfig.instance.setConfigSettings(
  RemoteConfigSettings(
    fetchTimeout: Duration.zero,
    minimumFetchInterval: Duration.zero,
  ),
);
```

**Option C: Mock ConnectivityService**
```dart
// In test
when(mockConnectivity.isConnected()).thenAnswer((_) async => false);
```

### 6.2 Test Offline Scenarios

**Scenario 1: Submit product offline**
1. Go offline (turn off connectivity)
2. Navigate to Add Product screen
3. Fill form and submit
4. **Expected**: Product queued, success message shown
5. Check Hive: `HiveBoxes.getPendingUploads()` should contain 1 item

**Scenario 2: View cached product**
1. Go offline
2. Search for a previously cached product (e.g., "Coca Cola")
3. **Expected**: Product displayed from cache with "Offline" badge
4. Timestamp shown: "Last updated X days ago"

**Scenario 3: Manual sync**
1. Queue 2-3 products while offline
2. Go online (restore connectivity)
3. Navigate to Pending Uploads screen
4. Tap "Sync Now" button
5. **Expected**: All products uploaded, notification shown, queue cleared

---

## Step 7: Code Quality Checks

### 7.1 Format Code

```powershell
# Format all Dart files
dart format .

# Check formatting (CI mode)
dart format --set-exit-if-changed .
```

### 7.2 Lint Analysis

```powershell
# Run static analysis
flutter analyze

# OR for specific directory
flutter analyze lib/features/FoodSearch/
```

**Expected**: No errors, no warnings.

### 7.3 Test Coverage

```powershell
# Generate coverage report
flutter test --coverage

# Check coverage percentage
lcov --summary coverage/lcov.info
```

**Target**: ≥70% total coverage for FoodSearch feature

---

## Step 8: Manual Testing Checklist

Before submitting PR, manually test these scenarios:

### Happy Path Testing

- [ ] **Search product by name**: Enter "Coca Cola", verify results displayed
- [ ] **Search product by barcode**: Enter "5449000000996", verify product found
- [ ] **Scan barcode**: Use camera to scan product, verify detection works
- [ ] **View product details**: Tap product from results, verify all data displayed
- [ ] **Add to favorites**: Tap heart icon, verify product saved to favorites
- [ ] **View favorites**: Navigate to Favorites tab, verify product listed
- [ ] **Submit new product**: Fill form, submit, verify success message
- [ ] **Offline indicator**: Go offline, view cached product, verify badge shown
- [ ] **Pending uploads**: Submit offline, navigate to Pending screen, verify listed
- [ ] **Manual sync**: Sync pending uploads, verify success notification

### Error Handling Testing

- [ ] **Invalid barcode**: Enter "123" (too short), verify error message
- [ ] **Empty product name**: Submit form with empty name, verify validation error
- [ ] **Network timeout**: Simulate slow network, verify timeout handling
- [ ] **API error**: Force 500 error, verify retry queuing
- [ ] **Exceeded retries**: Force 3 failed retries, verify permanent failure state

### Edge Case Testing

- [ ] **Cache expiry**: View product cached >7 days ago, verify "stale" indicator
- [ ] **Multiple sync**: Try syncing twice simultaneously, verify lock prevents duplicate
- [ ] **Background sync**: Leave app, restore, verify sync continued
- [ ] **Low storage**: Fill device storage, verify graceful handling

---

## Step 9: Troubleshooting

### Issue: Tests Failing with "Hive box not open"

**Solution**: Ensure Hive is initialized in test setup
```dart
setUp(() async {
  await Hive.initFlutter();
  await Hive.openBox<PendingProductUpload>('pendingProductUploads');
});

tearDown(() async {
  await Hive.close();
});
```

### Issue: Code generation not working

**Solution**: Clean build and regenerate
```powershell
flutter clean
flutter pub get
dart run build_runner build --delete-conflicting-outputs
```

### Issue: Integration tests fail on CI

**Solution**: Ensure headless mode is enabled
```dart
await IntegrationTestWidgetsFlutterBinding.ensureInitialized();
```

### Issue: Coverage report not generated

**Solution**: Install lcov tools
```powershell
# Windows (Chocolatey)
choco install lcov

# macOS
brew install lcov

# Linux
sudo apt-get install lcov
```

---

## Step 10: Submitting Your Work

### 10.1 Pre-PR Checklist

Before creating a pull request:

- [ ] All tests passing (`flutter test`)
- [ ] Code formatted (`dart format .`)
- [ ] No lint warnings (`flutter analyze`)
- [ ] Coverage ≥70% (`flutter test --coverage`)
- [ ] Manual testing completed (see Step 8 checklist)
- [ ] Commits follow convention: `feat(FoodSearch): Add barcode validation`
- [ ] Branch up-to-date with main (`git pull origin main`)

### 10.2 Create Pull Request

```powershell
# Push branch
git push origin 001-food-search-polish

# Create PR on GitHub/GitLab
# Title: "[001] FoodSearch Polish & Completion"
# Description: Reference spec.md and list completed user stories
```

### 10.3 PR Template

```markdown
## Summary
Implements FoodSearch Polish feature (spec: 001-food-search-polish)

## Completed User Stories
- [x] User Story 1.1: Unit tests for use cases
- [x] User Story 1.2: Widget tests for screens
- [x] User Story 1.3: Integration tests for flows
- [x] User Story 1.4: Form validation
- [x] User Story 2.1: Remove deprecated ProductUseCases
- [x] User Story 2.2: Remove unused imports
- [x] User Story 3.1: Offline indicator
- [x] User Story 3.2: Pending uploads screen
- [x] User Story 3.3: Manual sync

## Test Coverage
- Unit tests: 85%
- Widget tests: 75%
- Integration tests: 100%
- Overall: 78%

## Manual Testing
- Tested on Android emulator (API 33)
- Tested on iOS simulator (iOS 17)
- Tested offline scenarios
- Tested error handling

## Screenshots
[Attach screenshots of key features]
```

---

## Quick Reference

### Common Commands

```powershell
# Run app
flutter run

# Run tests
flutter test

# Run tests with coverage
flutter test --coverage

# Format code
dart format .

# Lint check
flutter analyze

# Code generation
dart run build_runner build --delete-conflicting-outputs

# Clean build
flutter clean && flutter pub get
```

### File Locations

| Component | Path |
|-----------|------|
| Feature Spec | `specs/001-food-search-polish/spec.md` |
| Implementation Plan | `specs/001-food-search-polish/plan.md` |
| Validation Contract | `specs/001-food-search-polish/contracts/product-validation.contract.md` |
| API Contract | `specs/001-food-search-polish/contracts/openfoodfacts-api.contract.md` |
| Unit Tests | `test/unit/food_search/` |
| Widget Tests | `test/widget/food_search/` |
| Integration Tests | `test/integration/food_search/` |
| Validators | `lib/features/FoodSearch/domain/validators/` |
| Models | `lib/features/FoodSearch/data/models/` |
| Use Cases | `lib/features/FoodSearch/domain/usecases/` |
| Screens | `lib/features/FoodSearch/presentation/screens/` |

### Test Commands by User Story

```powershell
# User Story 1.1: Use case tests
flutter test test/unit/food_search/usecases/

# User Story 1.2: Widget tests
flutter test test/widget/food_search/screens/

# User Story 1.3: Integration tests
flutter test test/integration/food_search_flow_test.dart

# User Story 1.4: Validation tests
flutter test test/unit/food_search/validators/
```

---

## Need Help?

### Documentation
- **Project Overview**: `PROJECT_OVERVIEW.md`
- **Constitution**: `.specify/memory/constitution.md`
- **Feature Analysis**: `FOOD_SEARCH_ANALYSIS.md`

### Team Contacts
- **Tech Lead**: [Contact info]
- **QA Lead**: [Contact info]
- **Slack Channel**: #warrior-app-dev

### External Resources
- [Flutter Testing Docs](https://docs.flutter.dev/testing)
- [Effective Dart](https://dart.dev/effective-dart)
- [OpenFoodFacts API](https://wiki.openfoodfacts.org/API)
- [Hive Documentation](https://docs.hivedb.dev/)

---

**Happy Coding!** 🚀

Remember: Write tests first, commit often, and ask questions early.

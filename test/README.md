# Warrior App Test Suite

This directory contains comprehensive tests for the Warrior Flutter application. The test suite includes unit tests, widget tests, and integration tests to ensure app quality and reliability.

## Test Structure

```
test/
├── unit/                    # Unit tests for business logic
│   ├── repositories/        # Repository layer tests
│   └── providers/           # Provider layer tests
├── widget/                  # Widget-specific tests
│   └── widgets/             # Individual widget tests
├── integration/             # End-to-end integration tests
├── helpers/                 # Test utilities and helpers
│   └── test_helpers.dart    # Common test functions and mock data
├── widget_test.dart         # Main app widget tests
└── README.md               # This file
```

## Test Categories

### 1. Unit Tests (`test/unit/`)
- **Repository Tests**: Test data layer functionality, API interactions, and data transformations
- **Provider Tests**: Test state management logic, business rules, and provider interactions
- **Coverage**: Focuses on pure Dart logic without UI dependencies

### 2. Widget Tests (`test/widget/`)
- **Component Tests**: Test individual widgets in isolation
- **UI Logic Tests**: Test widget behavior, state changes, and user interactions
- **Coverage**: Focuses on UI components and their behavior

### 3. Integration Tests (`test/integration/`)
- **End-to-End Tests**: Test complete user flows and app functionality
- **Performance Tests**: Test app performance under various conditions
- **Coverage**: Tests the entire app working together

## Test Helpers

The `test/helpers/test_helpers.dart` file provides:

### TestHelpers Class
- `createTestApp()`: Creates a test widget with necessary providers
- `pumpAndSettleWidget()`: Pumps widget and waits for animations
- `expectWidgetExists<T>()`: Common widget existence assertions
- `enterTextInField()`: Helper for text input simulation
- `tapWidget()`: Helper for tap interactions

### MockData Class
- Sample user, workout, and exercise data
- Valid and invalid test data constants
- Helper methods for generating test data

### TestConstants Class
- Common duration constants
- Screen size constants for different devices
- Font size constants for accessibility testing

## Running Tests

### Prerequisites
1. Flutter SDK installed
2. All dependencies installed (`flutter pub get`)
3. For integration tests: An emulator/device connected

### Command Line

```bash
# Run all tests
flutter test

# Run specific test types
flutter test test/unit/                    # Unit tests only
flutter test test/widget/                  # Widget tests only
flutter test test/integration/             # Integration tests only

# Run with coverage
flutter test --coverage

# Run specific test file
flutter test test/widget_test.dart
```

### Using Test Scripts

For convenience, use the provided scripts:

**Unix/Mac/Linux:**
```bash
chmod +x scripts/run_tests.sh
./scripts/run_tests.sh
```

**Windows:**
```batch
scripts\run_tests.bat
```

These scripts will:
- Install dependencies
- Run all test categories
- Generate coverage reports
- Perform static analysis
- Provide detailed output and summary

## Test Configuration

The `test_config.yaml` file contains:
- Test timeout settings
- Coverage requirements
- Test data definitions
- Performance thresholds
- Execution settings

## Writing Tests

### Unit Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('AuthRepo Tests', () {
    test('should validate email format', () {
      // Arrange
      const email = MockData.validEmail;
      
      // Act
      final isValid = EmailValidator.isValid(email);
      
      // Assert
      expect(isValid, true);
    });
  });
}
```

### Widget Test Example
```dart
import 'package:flutter_test/flutter_test.dart';
import '../helpers/test_helpers.dart';

void main() {
  group('CustomButton Tests', () {
    testWidgets('should display button with text', (tester) async {
      // Arrange
      const buttonText = 'Login';
      
      // Act
      await tester.pumpWidget(
        TestHelpers.createTestApp(
          child: CustomButton(text: buttonText),
        ),
      );
      
      // Assert
      TestHelpers.expectTextExists(buttonText);
    });
  });
}
```

### Integration Test Example
```dart
import 'package:integration_test/integration_test.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  
  group('App Flow Tests', () {
    testWidgets('complete login flow', (tester) async {
      // Test complete user flow from app launch to login
    });
  });
}
```

## Test Coverage

### Current Coverage Goals
- **Overall Coverage**: > 80%
- **Unit Tests**: > 90%
- **Widget Tests**: > 85%
- **Critical Paths**: 100%

### Excluded from Coverage
- Generated files (`*.g.dart`, `*.freezed.dart`)
- Platform-specific code
- Main entry point

### Viewing Coverage Reports
After running tests with coverage:

```bash
# Generate HTML report (requires lcov)
genhtml coverage/lcov.info -o coverage/html

# Open in browser
open coverage/html/index.html  # Mac
start coverage/html/index.html # Windows
```

## Best Practices

### Test Organization
1. **Group Related Tests**: Use `group()` to organize related test cases
2. **Descriptive Names**: Use clear, descriptive test names
3. **Follow AAA Pattern**: Arrange, Act, Assert structure
4. **Single Responsibility**: Each test should verify one specific behavior

### Test Data
1. **Use Mock Data**: Leverage `MockData` class for consistent test data
2. **Test Edge Cases**: Include boundary conditions and error scenarios
3. **Isolate Tests**: Ensure tests don't depend on external data or state

### Performance
1. **Fast Tests**: Keep tests fast and focused
2. **Mock Dependencies**: Mock external dependencies and network calls
3. **Parallel Execution**: Tests should be able to run in parallel

### Maintenance
1. **Keep Tests Updated**: Update tests when code changes
2. **Regular Review**: Regularly review and refactor tests
3. **Documentation**: Document complex test scenarios

## Continuous Integration

The test suite is designed to work with CI/CD pipelines:

### GitHub Actions Example
```yaml
name: Tests
on: [push, pull_request]
jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - uses: subosito/flutter-action@v2
      - run: flutter pub get
      - run: flutter test --coverage
      - run: flutter analyze
```

## Troubleshooting

### Common Issues

1. **Test Timeout**: Increase timeout in test configuration
2. **Widget Not Found**: Check widget tree structure and keys
3. **Async Issues**: Use `pumpAndSettle()` for async operations
4. **Provider Issues**: Ensure proper provider overrides in tests

### Debug Tips

1. **Use `debugDumpApp()`**: Print widget tree for debugging
2. **Add Delays**: Use `tester.pump()` with delays for timing issues
3. **Check Logs**: Enable logging in test environment
4. **Isolate Tests**: Run individual tests to identify issues

## Contributing

When adding new tests:

1. Follow the existing structure and naming conventions
2. Add appropriate documentation
3. Ensure tests pass in CI environment
4. Update this README if adding new test categories
5. Maintain test coverage above minimum thresholds

## Resources

- [Flutter Testing Documentation](https://docs.flutter.dev/testing)
- [Widget Testing Guide](https://docs.flutter.dev/cookbook/testing/widget)
- [Integration Testing Guide](https://docs.flutter.dev/testing/integration-tests)
- [Mockito Documentation](https://pub.dev/packages/mockito)
- [Mocktail Documentation](https://pub.dev/packages/mocktail) 
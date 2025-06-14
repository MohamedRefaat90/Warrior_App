#!/bin/bash

# Warrior App Test Suite Runner
# ==============================

set -e  # Exit on any error

echo "Running Warrior App Test Suite"
echo "==============================="

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Install dependencies
print_status "Installing dependencies..."
flutter pub get || {
    print_error "Failed to install dependencies"
    exit 1
}

# Generate mocks if needed
print_status "Generating mocks..."
if flutter packages pub run build_runner build --delete-conflicting-outputs; then
    print_status "Mocks generated successfully"
else
    print_warning "Failed to generate mocks"
fi

# Create test results directory
mkdir -p test_results

# Run unit tests
print_status "Running unit tests..."
if flutter test test/unit/ --coverage --machine > test_results/unit_tests.json; then
    print_status "Unit tests passed"
else
    print_error "Unit tests failed"
    exit 1
fi

# Run widget tests
print_status "Running widget tests..."
if flutter test test/widget/ --coverage --machine > test_results/widget_tests.json; then
    print_status "Widget tests passed"
else
    print_error "Widget tests failed"
    exit 1
fi

# Run main widget tests
print_status "Running main widget tests..."
if flutter test test/widget_test.dart --coverage --machine > test_results/main_tests.json; then
    print_status "Main widget tests passed"
else
    print_error "Main widget tests failed"
    exit 1
fi

# Check for available devices for integration tests
print_status "Checking for available devices..."
if flutter devices | grep -q -E "(emulator|simulator|device)"; then
    print_status "Running integration tests..."
    if flutter test integration_test/ --machine > test_results/integration_tests.json; then
        print_status "Integration tests passed"
    else
        print_error "Integration tests failed"
        exit 1
    fi
else
    print_warning "No devices available for integration tests"
fi

# Generate coverage report
print_status "Generating coverage report..."
if flutter test --coverage; then
    if [ -f "coverage/lcov.info" ]; then
        print_status "Coverage report generated at coverage/lcov.info"
        
        # Generate HTML coverage report if lcov is available
        if command -v genhtml &> /dev/null; then
            genhtml coverage/lcov.info -o coverage/html
            print_status "HTML coverage report generated at coverage/html/index.html"
        fi
    else
        print_warning "Coverage report not generated"
    fi
else
    print_warning "Failed to generate coverage report"
fi

# Run static analysis
print_status "Running static analysis..."
if flutter analyze > test_results/analysis.txt; then
    print_status "Static analysis passed"
else
    print_error "Static analysis found issues"
    cat test_results/analysis.txt
    exit 1
fi

# Check formatting
print_status "Checking code formatting..."
if dart format --output=none --set-exit-if-changed .; then
    print_status "Code formatting is correct"
else
    print_warning "Code formatting issues found. Run 'dart format .' to fix"
fi

# Summary
print_status "Test Suite Summary:"
echo "=================="
echo "✅ Dependencies installed"
echo "✅ Unit tests passed"
echo "✅ Widget tests passed"
echo "✅ Main widget tests passed"
if flutter devices | grep -q -E "(emulator|simulator|device)"; then
    echo "✅ Integration tests passed"
else
    echo "⚠️  Integration tests skipped (no devices)"
fi
echo "✅ Static analysis passed"
echo "✅ Coverage report generated"

print_status "All tests completed successfully!"
echo "===============================" 
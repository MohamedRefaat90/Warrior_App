# 💪 Warrior App

<div align="center">

![Warrior App Logo](https://img.shields.io/badge/💪-WARRIOR-red?style=for-the-badge&logoColor=white)

**A Flutter-Based Fitness Workout Management App**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.3+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-63%20Passing-brightgreen?style=flat-square)](tests)
[![Version](https://img.shields.io/badge/Version-2.0.0-blue?style=flat-square)](pubspec.yaml)

*Your personal fitness companion for creating and managing custom workout routines*

[🚀 Features](#-features) • [🏗️ Architecture](#️-architecture) • [📱 Screenshots](#-screenshots)

</div>

---

## 🌟 Overview

**Warrior App** is a comprehensive fitness application built with Flutter that helps users create, manage, and track their workout routines. The app focuses on providing a seamless experience for fitness enthusiasts to organize their exercises by muscle groups and build personalized workout sets.

### ✨ Key Highlights

- 🏋️ **Muscle-Based Exercise Organization** - Browse exercises by specific muscle groups
- 📝 **Custom Workout Sets** - Create and manage personalized workout routines
- 💾 **Offline-First Architecture** - Full functionality without internet connection
- 🔄 **Smart Synchronization** - Seamless data sync when online
- 🔐 **Secure Authentication** - Google OAuth and traditional login support

---

## 🚀 Features

### 💪 Core Functionality

| Feature | Description | Status |
|---------|-------------|--------|
| **Muscle Groups** | Browse exercises organized by muscle groups | ✅ Complete |
| **Exercise Library** | Comprehensive database of fitness exercises | ✅ Complete |
| **Workout Sets** | Create, edit, and delete custom workout routines | ✅ Complete |
| **Workout Management** | Add/remove exercises from workout sets | ✅ Complete |
| **Offline Mode** | Full app functionality without internet | ✅ Complete |
| **Data Sync** | Automatic synchronization when online | ✅ Complete |

### 🔧 Technical Features

- **Clean Architecture** - Organized with features, core, and clear separation of concerns
- **State Management** - Riverpod for reactive state management
- **Local Storage** - Hive database for offline data persistence
- **Network Layer** - Dio HTTP client with interceptors and error handling
- **Authentication** - Firebase Auth with Google Sign-In integration
- **Responsive UI** - Flutter ScreenUtil for adaptive layouts
- **Testing** - Comprehensive unit, widget, and integration tests

### 🎯 User Experience

- **Onboarding Flow** - Guided introduction for new users
- **Guest Mode** - Try the app without creating an account
- **Exercise Selection** - Long-press to select multiple exercises
- **Workout Editing** - Inline editing of workout names and descriptions
- **Progress Tracking** - Track weights for each exercise

### 🧩 Architecture Pattern

The app follows **Clean Architecture** principles with clear separation:

- **Presentation Layer**: UI widgets, screens, and providers
- **Data Layer**: Repositories, models, and data sources
- **Core Layer**: Shared services, utilities, and constants

## 🧪 Testing

### 🎯 Test Coverage

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific test suites
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/
```

### 📊 Test Results

| Test Suite | Tests | Status | Coverage |
|------------|-------|--------|----------|
| **Unit Tests** | 34 | ✅ Passing | Models, Providers, Repositories |
| **Widget Tests** | 21 | ✅ Passing | UI Components, Interactions |
| **Integration Tests** | 8 | ✅ Passing | App Functionality |
| **Total** | **63** | ✅ **100% Pass Rate** | Comprehensive Coverage |

---

## 📱 Screenshots

<div align="center">

### 🏠 Home Dashboard
*Main navigation with muscle groups and workout access*

### 💪 Muscle Groups
*Browse exercises organized by muscle groups*

### 🏋️ Workout Management
*Create and manage custom workout sets*

### ⚙️ Exercise Selection
*Add exercises to workout sets with weight tracking*

</div>

---

## 🔧 Key Dependencies

### Core Dependencies
```yaml
dependencies:
  flutter_riverpod: ^2.4.0      # State management
  go_router: ^12.0.0            # Navigation
  hive: ^2.2.3                  # Local database
  dio: ^5.3.0                   # HTTP client
  firebase_core: ^2.15.0        # Firebase integration
  google_sign_in: ^6.1.5        # Google authentication
  flutter_screenutil: ^5.9.0    # Responsive design
  cached_network_image: ^3.3.0  # Image caching
  connectivity_plus: ^5.0.1     # Network connectivity
```

### Development Dependencies
```yaml
dev_dependencies:
  build_runner: ^2.4.7          # Code generation
  hive_generator: ^2.0.1        # Hive adapters
  mockito: ^5.4.4               # Testing mocks
  integration_test:             # Integration testing
    sdk: flutter
```

---

## 🚀 Deployment

### 📦 Build Commands

```bash
# Android APK
flutter build apk --release

# Android App Bundle
flutter build appbundle --release

# iOS
flutter build ipa --release
```

### 🔧 Build Configuration

- **ProGuard**: Enabled for Android release builds
- **Obfuscation**: Code obfuscation for production
- **App Icons**: Custom launcher icons configured
- **Splash Screen**: Native splash screen setup

---

## 🔄 GitHub Workflows

### 📋 **GitHub Workflows**

The project includes comprehensive CI/CD automation with two main workflows:

#### 1. **Tests & Quality Checks** (`.github/workflows/tests.yaml`)
**Triggers**: Pushes to `main` branch only

| Job | Purpose | Duration |
|-----|---------|----------|
| **Tests & Quality** | Unit tests, widget tests, code analysis, formatting | ~3-5 mins |
| **Integration Tests** | End-to-end integration testing | ~2-3 mins |
| **Build Validation** | Release APK build and validation | ~5-7 mins |
| **Summary** | Results summary and status report | ~30 secs |

#### 2. **Android Firebase Distribution** (`.github/workflows/android_fastlane_firebaseDestribution.yaml`)
**Triggers**: Pushes to `main` branch only

- **Automated APK Build**: Release APK generation
- **Firebase Distribution**: Automatic distribution to beta testers
- **Fastlane Integration**: Streamlined deployment process

### 🎯 **Workflow Features**

#### ✅ **Quality Assurance**
```yaml
# Automated checks on main branch pushes
- Code analysis (flutter analyze)
- Code formatting (dart format)
- Unit & widget tests
- Integration tests
- Test coverage reporting
- Release APK build validation
```

#### ✅ **Automated Deployment**
```yaml
# Parallel execution on main branch
- CI tests run in parallel with deployment
- Automatic APK generation
- Firebase App Distribution
- Beta tester notifications
```

#### ✅ **Developer Experience**
- **Simple Workflow**: Only triggers on main branch pushes
- **Parallel Execution**: Tests and deployment run simultaneously
- **Clear Status**: Detailed success/failure reporting
- **Artifact Storage**: APKs and coverage reports saved

### 📊 **Pipeline Flow**

```
Push to Main Branch
    ↓
┌─────────────────────┬─────────────────────┐
│   Tests Workflow    │   Firebase Deploy   │
│   ↓                 │   ↓                 │
│   Unit Tests        │   Build APK         │
│   ↓                 │   ↓                 │
│   Integration Tests │   Distribute        │
│   ↓                 │   ↓                 │
│   Build Validation  │   Notify Testers    │
└─────────────────────┴─────────────────────┘
```


<div align="center">

**Built with ❤️ using Flutter**

*Empowering your fitness journey, one workout at a time*

⭐ **Star this repository if you find it helpful!**

</div>

# 💪 Warrior App

<div align="center">

![Warrior App Logo](https://img.shields.io/badge/💪-WARRIOR-red?style=for-the-badge&logoColor=white)

**A Flutter-Based Fitness Workout Management App**

[![Flutter](https://img.shields.io/badge/Flutter-3.5.3+-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Tests](https://img.shields.io/badge/Tests-63%20Passing-brightgreen?style=flat-square)](tests)
[![Version](https://img.shields.io/badge/Version-1.0.0-blue?style=flat-square)](pubspec.yaml)

_Your personal fitness companion for creating and managing custom workout routines_

[🚀 Features](#-features) • [🏗️ Architecture](#️-architecture) • [📄 Project Overview](./PROJECT_OVERVIEW.md) • [📱 Screenshots](#-screenshots)

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

| Feature                | Description                                      | Status      |
| ---------------------- | ------------------------------------------------ | ----------- |
| **Muscle Groups**      | Browse exercises organized by muscle groups      | ✅ Complete |
| **Exercise Library**   | Comprehensive database of fitness exercises      | ✅ Complete |
| **Workout Sets**       | Create, edit, and delete custom workout routines | ✅ Complete |
| **Workout Management** | Add/remove exercises from workout sets           | ✅ Complete |
| **Offline Mode**       | Full app functionality without internet          | ✅ Complete |
| **Data Sync**          | Automatic synchronization when online            | ✅ Complete |

### 🔧 Technical Features

- **Clean Architecture** - Organized with features, core, and clear separation of concerns
- **State Management** - Riverpod for reactive state management
- **Local Storage** - Hive database for offline data persistence
- **Network Layer** - Dio HTTP client with interceptors and error handling
- **Authentication** - Firebase Auth with Google Sign-In integration
- **Responsive UI** - Flutter ScreenUtil for adaptive layouts
- **Over-the-Air Updates** - Shorebird for instant app updates without store approval
- **Testing** - Comprehensive unit, widget, and integration tests

### 🎯 User Experience

- **Onboarding Flow** - Guided introduction for new users
- **Guest Mode** - Try the app without creating an account
- **Exercise Selection** - Long-press to select multiple exercises
- **Workout Editing** - Inline editing of workout names and descriptions
- **Progress Tracking** - Track weights for each exercise

---

## 🍎 FoodSearch Feature

The **FoodSearch** module provides comprehensive food database integration with offline-first support.

### 📋 FoodSearch Capabilities

| Feature                        | Description                                           | Status      |
| ------------------------------ | ----------------------------------------------------- | ----------- |
| **Barcode Scanning**           | QR/Barcode scanning for quick product lookup          | ✅ Complete |
| **OCR Nutrition Extraction**   | Extract nutrition facts from food labels using ML Kit | ✅ Complete |
| **Food Search**                | Search food database by name or barcode               | ✅ Complete |
| **Product Details**            | View comprehensive nutrition information              | ✅ Complete |
| **Product Comparison**         | Compare nutrition across multiple products            | ✅ Complete |
| **Nutrition Guide**            | Learn about nutrition scores and food ratings         | ✅ Complete |
| **Form Validation**            | Real-time validation for product submissions          | ✅ Complete |
| **Offline Sync**               | Queue submissions and sync when online                | ✅ Complete |
| **Pending Uploads Management** | View and manage queued products with manual retry     | ✅ Complete |
| **Search History**             | Track and manage product search history              | ✅ Complete |
| **Favorites**                  | Save favorite products for quick access              | ✅ Complete |

### 🔄 Offline-First Architecture

**Key Features**:
- ✅ Automatic queueing of product submissions when offline
- ✅ Persistent Hive storage for offline data
- ✅ Auto-retry with exponential backoff (max 3 attempts)
- ✅ Manual retry and delete controls for queued items
- ✅ Automatic sync when connectivity restored
- ✅ User-friendly pending uploads management screen

**File Structure**:
```
lib/features/FoodSearch/
├── data/
│   ├── models/                    # Data models
│   │   ├── food_product_model.dart
│   │   ├── pending_product_upload.dart
│   │   ├── pending_upload_status.dart
│   │   └── ...
│   ├── repositories/              # Repository implementations
│   │   ├── product_read_repository_impl.dart
│   │   └── product_write_repository_impl.dart
│   └── data_sources/              # API & local data sources
│       ├── food_remote_data_source.dart
│       └── food_local_data_source.dart
├── domain/
│   ├── repositories/              # Repository interfaces
│   │   ├── product_read_repository.dart
│   │   └── product_write_repository.dart
│   ├── usecases/                  # Business logic (11 use cases)
│   │   ├── search_product_by_barcode_usecase.dart
│   │   ├── search_products_by_name_usecase.dart
│   │   ├── toggle_favorite_usecase.dart
│   │   ├── get_pending_uploads_usecase.dart
│   │   ├── retry_pending_upload_usecase.dart
│   │   └── ...
│   └── entities/                  # Domain models
│       ├── product_entity.dart
│       ├── nutrition_facts.dart
│       └── ...
└── presentation/
    ├── screens/                   # UI Screens
    │   ├── food_search_screen.dart
    │   ├── pending_uploads_screen.dart
    │   ├── product_form_screen.dart
    │   └── ...
    ├── widgets/                   # Reusable widgets
    │   ├── pending_upload_card.dart
    │   ├── pending_upload_badge.dart
    │   ├── product_card.dart
    │   └── ...
    ├── providers/                 # Riverpod providers
    │   └── food_search_provider.dart
    └── ...
```

### 📊 Food Product Validation

**Fields Validated**:
- Product Name (required, 2-200 characters)
- Barcode (required, valid EAN/UPC format)
- Brands (optional, max 200 characters)
- Quantity (optional, valid format)
- Nutrition Values (optional, valid ranges)
- Images (optional, valid formats and sizes)

**Validation Features**:
- ✅ Real-time validation as user types
- ✅ Clear, actionable error messages
- ✅ Localization support for all messages
- ✅ Visual feedback (red borders, error text)
- ✅ Submit button disabled until valid

### 🧪 FoodSearch Test Coverage

| Test Category | Count | Coverage |
| ------------- | ----- | -------- |
| Unit Tests    | 60+   | Domain & Data layers |
| Widget Tests  | 30+   | UI components |
| Integration   | 5+    | End-to-end scenarios |
| **Total**     | **95+** | **70%+ overall** |

For detailed FoodSearch documentation, see [FoodSearch Feature README](./lib/features/FoodSearch/README.md)

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

| Test Suite            | Tests  | Status                | Coverage                        |
| --------------------- | ------ | --------------------- | ------------------------------- |
| **Unit Tests**        | 34     | ✅ Passing            | Models, Providers, Repositories |
| **Widget Tests**      | 21     | ✅ Passing            | UI Components, Interactions     |
| **Integration Tests** | 8      | ✅ Passing            | App Functionality               |
| **Total**             | **63** | ✅ **100% Pass Rate** | Comprehensive Coverage          |

---

## 📱 Screenshots

<div align="center">

### 🏠 Home Dashboard

_Main navigation with muscle groups and workout access_

### 💪 Muscle Groups

_Browse exercises organized by muscle groups_

### 🏋️ Workout Management

_Create and manage custom workout sets_

### ⚙️ Exercise Selection

_Add exercises to workout sets with weight tracking_

</div>

---

## 🔧 Key Dependencies

### Core Dependencies

```yaml
dependencies:
  flutter_riverpod: ^2.4.0 # State management
  go_router: ^12.0.0 # Navigation
  hive: ^2.2.3 # Local database
  dio: ^5.3.0 # HTTP client
  firebase_core: ^2.15.0 # Firebase integration
  google_sign_in: ^6.1.5 # Google authentication
  flutter_screenutil: ^5.9.0 # Responsive design
  cached_network_image: ^3.3.0 # Image caching
  connectivity_plus: ^5.0.1 # Network connectivity
```

### Development Dependencies

```yaml
dev_dependencies:
  build_runner: ^2.4.7 # Code generation
  hive_generator: ^2.0.1 # Hive adapters
  mockito: ^5.4.4 # Testing mocks
  integration_test: # Integration testing
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

The project includes comprehensive CI/CD automation with three main workflows:

#### 1. **Tests & Quality Checks** (`.github/workflows/tests.yaml`)

**Triggers**: Pushes to `main` branch only

| Job                   | Purpose                                             | Duration  |
| --------------------- | --------------------------------------------------- | --------- |
| **Tests & Quality**   | Unit tests, widget tests, code analysis, formatting | ~3-5 mins |
| **Integration Tests** | End-to-end integration testing                      | ~2-3 mins |
| **Build Validation**  | Release APK build and validation                    | ~5-7 mins |
| **Summary**           | Results summary and status report                   | ~30 secs  |

#### 2. **Android Firebase Distribution** (`.github/workflows/android_fastlane_firebaseDestribution.yaml`)

**Triggers**: Pushes to `main` branch only

- **Automated APK Build**: Release APK generation
- **Firebase Distribution**: Automatic distribution to beta testers
- **Fastlane Integration**: Streamlined deployment process

#### 3. **Shorebird Deploy** (`.github/workflows/shorebird_deploy.yaml`)

**Triggers**: Pushes to `main`, version changes, manual dispatch

- **Over-the-Air Updates**: Instant patches for bug fixes and small features
- **Release Management**: Automated releases for version changes
- **Multi-platform Support**: Android and iOS deployment
- **Smart Detection**: Automatically determines patch vs release deployment

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

_Empowering your fitness journey, one workout at a time_

⭐ **Star this repository if you find it helpful!**

</div>
#   T r i g g e r   w o r k f l o w   -   0 6 / 2 0 / 2 0 2 5   2 0 : 5 5 : 3 3 
 
 

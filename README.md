# 💪 Warrior App

<div align="center">

![Warrior App Logo](https://img.shields.io/badge/💪-WARRIOR-red?style=for-the-badge&logoColor=white)

**A Flutter-Based Fitness Management App**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=flat-square&logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.5.3+-0175C2?style=flat-square&logo=dart&logoColor=white)](https://dart.dev)
[![Firebase](https://img.shields.io/badge/Firebase-Enabled-FFCA28?style=flat-square&logo=firebase&logoColor=black)](https://firebase.google.com)
[![Version](https://img.shields.io/badge/Version-1.1.0-blue?style=flat-square)](pubspec.yaml)

_Your personal fitness companion for workouts, food scanning, and calorie tracking_

[🚀 Features](#-features) • [🏗️ Architecture](#️-architecture) • [🧪 Testing](#-testing) • [📱 Screenshots](#-screenshots)

</div>

---

## 🌟 Overview

**Warrior App** is a comprehensive fitness application built with Flutter that helps users create, manage, and track their workout routines, monitor nutrition, scan food products, and manage supplements. The app provides a seamless offline-first experience with smart synchronization when online.

### ✨ Key Highlights

- 🏋️ **Muscle-Based Exercise Organization** - Browse exercises by specific muscle groups
- 📝 **Custom Workout Sets** - Create and manage personalized workout routines
- 📷 **Food Scanning** - Barcode scanning + OCR nutrition extraction via ML Kit
- 🔢 **Calories Calculator** - BMR/TDEE calculations for personalized goals
- 🚧 **Nutrition & Supplements** - Coming soon
- 💾 **Offline-First Architecture** - Full functionality without internet connection
- 🔄 **Smart Synchronization** - Seamless data sync when online
- 🔐 **Secure Authentication** - Google OAuth and traditional login support
- 🌍 **Bilingual** - Full Arabic and English localization

---

## 🚀 Features

### 💪 Core Functionality

| Feature                    | Description                                            | Status      |
| -------------------------- | ------------------------------------------------------ | ----------- |
| **Muscle Groups**          | Browse exercises organized by muscle groups            | ✅ Complete |
| **Exercise Library**       | Comprehensive database of fitness exercises            | ✅ Complete |
| **Custom Workout Sets**    | Create, edit, and delete personalized workout routines | ✅ Complete |
| **Predefined Workouts**    | Curated workout plans ready to use                     | ✅ Complete |
| **Calories Calculator**    | BMR/TDEE calculations for personalized goals           | ✅ Complete |
| **Offline Mode**           | Full app functionality without internet                | ✅ Complete |
| **Data Sync**              | Automatic synchronization when online                  | ✅ Complete |
| **Nutrition Tracking**     | Log and monitor daily nutrition intake                 | 🚧 Coming Soon |
| **Supplement Tracking**    | Manage and track supplements                           | 🚧 Coming Soon |

### 🍎 FoodSearch Feature

| Feature                        | Description                                           | Status      |
| ------------------------------ | ----------------------------------------------------- | ----------- |
| **Barcode Scanning**           | QR/Barcode scanning for quick product lookup          | ✅ Complete |
| **OCR Nutrition Extraction**   | Extract nutrition facts from food labels via ML Kit   | ✅ Complete |
| **Food Search**                | Search food database by name or barcode               | ✅ Complete |
| **Product Details**            | View comprehensive nutrition information              | ✅ Complete |
| **Favorites**                  | Save favorite products for quick access               | ✅ Complete |
| **Search History**             | Track and manage product search history               | ✅ Complete |
| **Offline Sync**               | Queue submissions and sync when online                | ✅ Complete |
| **Pending Uploads Management** | View and manage queued products with manual retry     | ✅ Complete |

### 🔧 Technical Features

- **Clean Architecture** - Feature-first with presentation/domain/data layers
- **State Management** - Riverpod 3.x for reactive state management
- **Local Storage** - Hive CE for offline data persistence with code generation
- **Network Layer** - Dio HTTP client with interceptors and error handling
- **Authentication** - Firebase Auth with Google Sign-In integration
- **Crash Monitoring** - Sentry for error tracking and performance monitoring
- **Push Notifications** - Firebase Cloud Messaging
- **Analytics** - Firebase Analytics
- **Logging** - Talker for structured, filterable logs
- **Ads** - Google Mobile Ads with system-controlled visibility flag
- **Over-the-Air Updates** - Shorebird for instant patches without store approval
- **Bilingual UI** - Full ARB-based localization (English + Arabic)
- **Nutrition & Supplements** - Placeholder screens, full implementation coming soon

---

## 🏗️ Architecture

### 🧩 Clean Architecture — Feature-First

```
lib/
├── core/                        # Shared infrastructure
│   ├── network/                 # Dio HTTP client & interceptors
│   ├── localization/arb/        # en.arb & ar.arb translation files
│   ├── services/                # TalkerService, Firebase, etc.
│   ├── providers/               # Global Riverpod providers
│   └── theme/                   # App theming
├── features/
│   ├── Auth/                    # Firebase Auth + Google Sign-In
│   ├── Workouts/                # Custom workout creation & tracking
│   ├── Predefined_workouts/     # Curated workout plans
│   ├── Exercises/               # Exercise library with muscle group data
│   ├── Nutrition/               # Nutrition logging & tracking
│   ├── FoodSearch/              # Barcode scanning + OCR + OpenFoodFacts
│   ├── CaloriesCalculator/      # BMR/TDEE calculations
│   ├── Supplements/             # Supplement management
│   ├── Home/                    # Main dashboard
│   └── onboarding/              # New user onboarding flow
├── main.dart                    # App entry point
└── routing.dart                 # GoRouter configuration
```

Each feature follows the three-layer pattern:
- **Presentation**: Screens, widgets, Riverpod providers
- **Domain**: Entities, use cases, repository interfaces
- **Data**: Repository implementations, models, remote/local data sources

### 🔄 Offline-First Data Flow

- Automatic queueing of submissions when offline
- Persistent Hive CE storage for offline data
- Auto-retry with exponential backoff
- Manual retry and delete controls for queued items
- Automatic sync when connectivity is restored

---

## 🧪 Testing

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage

# Run specific suites
flutter test test/unit/
flutter test test/widget/
flutter test test/integration/
```

### 📊 Test Results

| Test Suite            | Files  | Status         |
| --------------------- | ------ | -------------- |
| **Unit Tests**        | 33     | ✅ Passing     |
| **Widget Tests**      | 15     | ✅ Passing     |
| **Integration Tests** | 5      | ✅ Passing     |
| **Total**             | **53** | ✅ All Passing |

Tests use the Arrange-Act-Assert pattern. Mocking via `mocktail` (preferred) or `mockito`.

---

## 🔧 Key Dependencies

### Core

```yaml
flutter_riverpod: ^3.0.3       # State management
go_router:                      # Navigation & deep linking
hive_ce: ^2.9.0                 # Local database (Hive Community Edition)
hive_ce_flutter: ^2.1.0
dio:                            # HTTP client
shared_preferences: ^2.3.5     # Simple key-value storage
connectivity_plus:              # Network state detection
```

### Firebase & Monitoring

```yaml
firebase_core:
firebase_analytics: ^11.4.5
firebase_messaging: ^15.2.10
firebase_crashlytics: ^4.3.5
sentry_flutter: ^9.6.0         # Crash reporting & performance
```

### UI & UX

```yaml
google_fonts: ^6.3.2
lottie:                        # Lottie animations
flutter_animate: ^4.5.0
animate_do: ^4.2.0
fl_chart: ^1.1.1               # Charts
skeletonizer: ^2.1.0+1         # Skeleton loading states
confetti: ^0.8.0
smooth_page_indicator:
cached_network_image:
flutter_svg:
video_player: ^2.10.0
cached_video_player_plus: ^4.0.4
```

### Food & Nutrition

```yaml
openfoodfacts: ^3.27.0                    # OpenFoodFacts product database
mobile_scanner: ^7.1.3                    # Barcode / QR scanning
google_mlkit_text_recognition: ^0.15.0   # OCR from food labels
camera: ^0.11.3
image_picker: ^1.0.7
image_cropper: ^11.0.0
flutter_image_compress: ^2.4.0
```

### Other

```yaml
google_mobile_ads: ^6.0.0      # AdMob ads
google_sign_in:                 # Google OAuth
flutter_secure_storage: ^9.2.4
talker_flutter: ^5.0.1          # Structured logging
talker_riverpod_logger: ^5.0.1
talker_dio_logger: ^5.0.1
in_app_review: ^2.0.11
share_plus: ^12.0.0
url_launcher: ^6.3.2
intl: ^0.20.2
equatable: ^2.0.8
```

### Dev

```yaml
build_runner:                  # Code generation
hive_ce_generator: ^1.11.1    # Hive type adapters
mockito: ^5.4.4
mocktail: ^1.0.3
sentry_dart_plugin: ^3.1.1
```

---

## 🚀 Deployment

### Build Commands

```bash
# Android APK
flutter build apk --release --dart-define-from-file=secrets.json

# Android App Bundle
flutter build appbundle --release --dart-define-from-file=secrets.json

# iOS
flutter build ipa --release --dart-define-from-file=secrets.json
```

### Environment Variables

Secrets are injected at build time via `--dart-define-from-file=secrets.json`. Never hardcode credentials. Access in Dart via `const String.fromEnvironment('KEY')`.

### Build Configuration

- **ProGuard**: Enabled for Android release builds
- **Obfuscation**: Code obfuscation for production
- **App Icons**: Custom launcher icons configured
- **Splash Screen**: Native splash screen setup

---

## 🔄 CI/CD (GitHub Actions)

All workflows are in `.github/workflows/`:

| Workflow | File | Trigger |
| --- | --- | --- |
| **Tests & Quality** | `tests.yaml` | Push to `main` |
| **Firebase Distribution** | `android_fastlane_firebaseDestribution.yaml` | Push to `main` |
| **Shorebird OTA** | `shorebird_deploy.yaml` | Push to `main`, version changes, manual |
| **Play Store** | `google_play_store.yaml` | Manual / release |

### Pipeline Flow

```
Push to Main
    ↓
┌─────────────────────┬─────────────────────┐
│   Tests Workflow    │   Firebase Deploy   │
│   Unit Tests        │   Build APK         │
│   Widget Tests      │   Firebase Dist.    │
│   Integration Tests │   Notify Testers    │
│   flutter analyze   │                     │
└─────────────────────┴─────────────────────┘
                ↓
        Shorebird OTA Deploy (if patch eligible)
```

---

<div align="center">

**Built with ❤️ using Flutter**

_Empowering your fitness journey, one workout at a time_

⭐ **Star this repository if you find it helpful!**

</div>

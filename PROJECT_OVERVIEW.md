# 💪 Warrior App - Project Overview

## 📋 Project Identity

**Warrior App** is a high-performance, feature-rich fitness and nutrition management application built with **Flutter**. It serves as a comprehensive companion for fitness enthusiasts, providing tools for workout tracking, exercise discovery, nutritional analysis, and metabolic calculation.

---

## 🎯 Mission & Purpose

The primary goal of Warrior App is to empower users to take control of their fitness journey through:

- **Personalized Tracking**: Managing custom workout routines and progress.
- **Informed Nutrition**: Leveraging OCR and barcode scanning to understand food composition.
- **Educational Discovery**: Visualizing muscle groups and understanding exercise impact.
- **Accessibility**: Providing a seamless, offline-first experience with multi-language support (Arabic & English).

---

## 🚀 Key Features

### 🏋️ Workout & Exercise Management

- **Exercise Library**: A comprehensive database categorized by muscle groups.
- **Custom Workouts**: Create, edit, and track personalized workout sets.
- **Interactive Muscle Diagram**: A full-body visualization to browse exercises by muscle group with draggable cards.
- **Progress Tracking**: Inline weight tracking and performance feedback (animations for PRs/changes).
- **Predefined Routines**: Access to curated workout plans for various fitness levels.

### 🥗 Nutrition & Food Tracking

- **Food Search**: Search a massive database of products via Open Food Facts.
- **Barcode Scanner**: Instant product identification using the mobile camera.
- **OCR Nutrition Extraction**: Extract nutritional data (Macros, Nutri-Score, etc.) directly from food labels using ML Kit.
- **Product Comparison**: Side-by-side comparison of 2-3 products to facilitate healthier choices.
- **Nutrition Guide**: Educational resources explaining Nutri-Score, NOVA groups, and Eco-Scores.
- **Favorites & History**: Save frequently consumed foods and track search history.

### 🔢 Metabolic Tools

- **Calories Calculator**: Calculate TDEE, BMR, and macronutrient targets based on user metrics (age, weight, height, activity level).
- **Results Visualization**: Clear breakdowns of caloric needs for maintenance, Weight loss, or gain.

---

## 🛠️ Technical Stack

| Component            | Technology                                            |
| -------------------- | ----------------------------------------------------- |
| **Core Framework**   | Flutter (v3.5.3+) & Dart (v3.5.3+)                    |
| **State Management** | Riverpod 3 (AutoDisposeNotifier, StateProvider, etc.) |
| **Navigation**       | GoRouter (Declarative routing, deep links)            |
| **Local Storage**    | Hive (NoSQL, offline-first caching)                   |
| **Networking**       | Dio (Interceptors, global configuration)              |
| **Authentication**   | Firebase Auth (Google Sign-In & Email/Password)       |
| **OCR & Vision**     | Google ML Kit (Text recognition)                      |
| **Deployment & OTA** | Shorebird (Over-the-Air updates)                      |
| **Responsiveness**   | Flutter ScreenUtil                                    |
| **Localization**     | ARB files (Arabic/English support)                    |
| **Testing**          | Unit, Widget, and Integration tests                   |

---

## 🏗️ Architecture: Feature-First Clean Architecture

The project follows a **Feature-First Clean Architecture** to ensure scalability and maintainability.

### Layered Structure (per feature):

1.  **Presentation Layer**:
    - `screens/`: UI pages.
    - `widgets/`: Reusable, feature-specific UI components.
    - `providers/`: State management logic using Riverpod.
2.  **Domain Layer**: (Where applicable)
    - `entities/`: Pure business logic objects.
3.  **Data Layer**:
    - `models/`: Data Transfer Objects (DTOs) with Hive adapters and JSON serialization.
    - `repo/`: Repository implementation handling data flow (Remote vs. Local).
    - `data_sources/`: API clients or local database access.

### Core Directory:

- `lib/core/`: Contains shared services (OCR, Networking, Localization), constants, and global widgets.

---

## 📂 Project Structure Highlights

```text
lib/
├── core/                       # Shared logic (services, constants, theme, localization)
├── features/                   # Feature-based modules
│   ├── Auth/                   # Authentication logic
│   ├── CaloriesCalculator/      # Metabolic calculations
│   ├── Exercises/              # Muscle groups and exercise database
│   ├── FoodSearch/             # Barcode scanning and OCR nutrition
│   ├── Home/                   # Dashboard navigation
│   ├── Workouts/               # Custom workout management
│   └── ...
├── main.dart                   # Entry point and initialization
└── routing.dart                # Global GoRouter configuration
```

---

## 🤖 Guidance for AI Agents & Developers

When working on this codebase, adhere to the following:

1.  **Consistency**: Follow the existing feature-first structure.
2.  **State Management**: Use Riverpod 3. Always prefer `AutoDispose` to prevent memory leaks.
3.  **Localization**: Hardcoded strings are forbidden. Use `context.l10n` and update `en.arb`/`ar.arb`.
4.  **Offline First**: Ensure new features support Hive caching or handle connectivity gracefully.
5.  **Performance**: Utilize `ListView.builder` for long lists and optimize image assets.
6.  **Style**: Follow the guidelines in `AGENTS.md` and `TRANSLATION_GUIDE.md`.

---

## 🚀 Getting Started

1.  **Check Dependencies**: `flutter pub get`
2.  **Code Generation**: `dart run build_runner build --delete-conflicting-outputs`
3.  **Run Application**: `flutter run`
4.  **Tests**: `flutter test`

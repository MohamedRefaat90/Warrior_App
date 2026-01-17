# FoodSearch Feature Analysis

## 1. Overview

The **FoodSearch** feature is a comprehensive module designed to empower users to search, scan, analyze, and compare food products. It leverages the **Open Food Facts API** to retrieve nutritional data and supports extensive offline capabilities through **Hive** caching.

## 2. Architecture System

The feature adheres to **Clean Architecture** principles, ensuring separation of concerns and maintainability.

### 2.1. Layer Separation

- **Data Layer**:
  - **Repositories**: `FoodSearchRepo` acts as the single source of truth, coordinating between remote and local data.
  - **Data Sources**:
    - `FoodRemoteDataSource`: Direct interaction with `openfoodfacts` package.
    - `FoodLocalDataSource`: Manages Hive boxes for caching products, history, and pending uploads.
  - **Models**: `FoodProductModel`, `NutritionValuesModel`, `SearchHistoryModel`.
- **Domain Layer**:
  - Contains business entities (e.g., `NutritionFacts`). _Note: `FoodProductModel` is currently used across layers, which is a pragmatic deviation._
- **Presentation Layer**:
  - **State Management**: Powered by **Riverpod** (`ConsumerWidget`, `Provider`, `Notifier`).
  - **UI**: Responsive screens and reusable modular widgets.

## 3. Core Functionality

### 3.1. Search & Discovery

- **Barcode Scanning**: Primary entry point for fast product lookup.
- **Text Search**: Supports brand, category, and product name queries.
- **Autocomplete**: Implemented with an **LRU (Least Recently Used) Cache** (`_SuggestionsLRUCache`) in `food_search_provider.dart` to optimize API usage and performance.

### 3.2. Data Synchronization & Offline First

- **Read Strategy**: The repository (`FoodSearchRepo`) typically attempts to fetch fresh data from the API but seamlessly falls back to the local Hive cache if offline or if the API fails.
- **Write Strategy**:
  - **Online**: Reviews and updates products directly.
  - **Offline**: Queues operations as `PendingProductUpload` objects. These are processed when connectivity is restored.
- **Caching**: Every fetched product is cached for 7 days (`isCacheFresh` check).

### 3.3. Product Analysis

- **Nutritional Indicators**: Visual representations for:
  - **Nutri-Score**: Color-coded shield (A-E).
  - **NOVA Group**: Processing level indicator (1-4).
  - **Eco-Score**: Environmental impact score.
- **Deep Dive**: `ProductDetailsScreen` breaks down macro-nutrients (Protiens, Carbs, Fat) using progress bars relative to daily recommended values.

### 3.4. User Tools

- **Comparison**: Users can select products to compare side-by-side (`comparison_provider.dart`).
- **Favorites**: Local bookmarking of products for quick access.
- **History**: Tracks recently searched and scanned items.
- **Filtering**: Advanced filtering by specific dietary requirements (Vegan, Gluten-free, Palm-oil free, Allergens).

## 4. Key Components Analysis

### 4.1. `FoodSearchRepo`

This is the workhorse of the feature.

- **Connectivity Checks**: Explicitly uses `ConnectivityChecker` before making remote calls.
- **Error Handling**: Wraps operations in try-catch blocks and logs to `TalkerService` (a centralized logging service) instead of failing silently.
- **Parallel Processing**: Uses `Future.wait` when caching lists of products (e.g., in `searchByBrand`) to improve performance.

### 4.2. `ProductDetailsScreen`

A high-fidelity screen that demonstrates strong UI/UX practices:

- **SliverAppBar**: Provides a collapsible header with the product image.
- **Hero Animations**: Smooth transitions from the list view to details.
- **Conditional Rendering**: Sections like Allergens or Labels only appear if data exists.

### 4.3. `FoodSearchProvider`

- **Suggestions Caching**: Implements a custom in-memory LRU cache to avoid spamming the API during typing.
- **Filters**: Uses a `NotifierProvider` to manage complex filter states cleanly.

## 5. UI/UX & Design Patterns

- **Responsiveness**: Heavily utilizes `ResponsiveUtils` to adapt layouts (grid columns, container widths) for Mobile, Tablet, and Desktop.
- **Monetization**: Integrates `InterstitialAdManager` and `BannerAdWidget` at strategic interaction points (e.g., before opening specific tools).
- **Localization**: All UI strings are localized using `context.l10n` and `.tr()` extensions.

## 6. Recommendations

1.  **Domain Model Separation**: Consider strictly separating `FoodProductModel` (Data) from a pure `Product` entity (Domain) to decouple the app from Hive and API specific implementation details.
2.  **State Granularity**: The `FoodSearchRepo` is quite large. Breaking it down (e.g., `ProductRepository`, `UserInteractionRepository`) might improve testability.
3.  **Nutrition Logic**: Ensure `ComparisonProvider` logic handles unit conversions if products use different serving sizes.

## 7. Technology Stack

- **Language**: Dart / Flutter
- **State Management**: Riverpod
- **Network**: Dio (implied via Remote Data Source) / OpenFoodFacts wrapper
- **Local DB**: Hive
- **Logging**: Talker
- **Navigation**: GoRouter

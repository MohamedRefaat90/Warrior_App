# FoodSearch Domain Architecture

## Use Case Class Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                    PRESENTATION LAYER                           │
│              (Widgets, Controllers, Providers)                  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ uses
┌─────────────────────────────────────────────────────────────────┐
│                      DOMAIN LAYER                               │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              SEARCH USE CASES                            │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • SearchProductByBarcodeUseCase                         │  │
│  │  • SearchProductsByNameUseCase                           │  │
│  │  • SearchProductsByBrandUseCase                          │  │
│  │  • SearchProductsByCategoryUseCase                       │  │
│  │  • GetProductSuggestionsUseCase                          │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         FILTERING & COMPARISON USE CASES                 │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • FilterProductsUseCase ⭐ (Business Logic)             │  │
│  │  • CompareProductsUseCase                                │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │           FAVORITES USE CASES                            │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • AddToFavoritesUseCase                                 │  │
│  │  • RemoveFromFavoritesUseCase                            │  │
│  │  • ToggleFavoriteUseCase ⭐ (Business Logic)             │  │
│  │  • GetFavoritesUseCase                                   │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │            HISTORY USE CASES                             │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • GetSearchHistoryUseCase                               │  │
│  │  • GetRecentlyScannedUseCase                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         PRODUCT MANAGEMENT USE CASES                     │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • SubmitProductUseCase                                  │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              REPOSITORY INTERFACES                       │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • ProductReadRepository                                 │  │
│  │  • ProductWriteRepository                                │  │
│  │  • UserInteractionRepository                             │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │                   ENTITIES                               │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • ProductEntity                                         │  │
│  │  • SearchHistoryEntity                                   │  │
│  │  • NutritionFacts                                        │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
                              ↓ implements
┌─────────────────────────────────────────────────────────────────┐
│                       DATA LAYER                                │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │         REPOSITORY IMPLEMENTATIONS                       │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • ProductReadRepositoryImpl                             │  │
│  │  • ProductWriteRepositoryImpl                            │  │
│  │  • UserInteractionRepositoryImpl                         │  │
│  └──────────────────────────────────────────────────────────┘  │
│                                                                 │
│  ┌──────────────────────────────────────────────────────────┐  │
│  │              DATA SOURCES                                │  │
│  ├──────────────────────────────────────────────────────────┤  │
│  │  • FoodRemoteDataSource (OpenFoodFacts API)              │  │
│  │  • FoodLocalDataSource (Hive)                            │  │
│  └──────────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────────┘
```

## FilterProductsUseCase - Detailed Flow

```
┌─────────────────────────────────────────────────────────────────┐
│                  FilterProductsUseCase                          │
├─────────────────────────────────────────────────────────────────┤
│                                                                 │
│  call({nutriScore, vegan, vegetarian, ...})                    │
│    │                                                            │
│    ├─► 1. Get all cached products from repository              │
│    │      └─► ProductReadRepository.getAllCachedProducts()     │
│    │                                                            │
│    ├─► 2. Apply Nutri-Score filter (if provided)               │
│    │      └─► _filterByNutriScore(products, nutriScore)        │
│    │                                                            │
│    ├─► 3. Apply vegan filter (if true)                         │
│    │      └─► _filterByVegan(products)                         │
│    │                                                            │
│    ├─► 4. Apply vegetarian filter (if true)                    │
│    │      └─► _filterByVegetarian(products)                    │
│    │                                                            │
│    ├─► 5. Apply palm oil filter (if true)                      │
│    │      └─► _filterByPalmOilFree(products)                   │
│    │                                                            │
│    ├─► 6. Apply NOVA group filter (if provided)                │
│    │      └─► _filterByNovaGroup(products, novaGroup)          │
│    │                                                            │
│    └─► 7. Apply allergen filter (if provided)                  │
│           └─► _filterByAllergens(products, allergens)          │
│                                                                 │
│  return filtered products                                      │
└─────────────────────────────────────────────────────────────────┘
```

## Repository Refactoring - Before vs After

### BEFORE (Business Logic in Repository) ❌

```
ProductReadRepositoryImpl
  │
  ├─► filterProducts({...})
  │     ├─► Get cached products (DATA ACCESS) ✅
  │     ├─► Filter by nutriScore (BUSINESS LOGIC) ❌
  │     ├─► Filter by vegan (BUSINESS LOGIC) ❌
  │     ├─► Filter by vegetarian (BUSINESS LOGIC) ❌
  │     ├─► Filter by palmOilFree (BUSINESS LOGIC) ❌
  │     ├─► Filter by novaGroup (BUSINESS LOGIC) ❌
  │     └─► Filter by allergens (BUSINESS LOGIC) ❌
  │
  └─► Other methods...
```

### AFTER (Pure Data Access) ✅

```
ProductReadRepositoryImpl
  │
  ├─► getAllCachedProducts()
  │     └─► Get cached products (DATA ACCESS) ✅
  │
  └─► Other methods...

FilterProductsUseCase (Domain Layer)
  │
  ├─► call({...})
  │     ├─► Get all products via repository ✅
  │     ├─► Filter by nutriScore (BUSINESS LOGIC) ✅
  │     ├─► Filter by vegan (BUSINESS LOGIC) ✅
  │     ├─► Filter by vegetarian (BUSINESS LOGIC) ✅
  │     ├─► Filter by palmOilFree (BUSINESS LOGIC) ✅
  │     ├─► Filter by novaGroup (BUSINESS LOGIC) ✅
  │     └─► Filter by allergens (BUSINESS LOGIC) ✅
  │
  └─► Private filter methods...
```

## Dependency Flow

```
┌──────────────────────────────────────────────────────────┐
│                    Presentation                          │
│                                                          │
│  ProductListController                                   │
│    │                                                     │
│    └─► uses FilterProductsUseCase                       │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│                      Domain                              │
│                                                          │
│  FilterProductsUseCase                                   │
│    │                                                     │
│    └─► depends on ProductReadRepository (interface)     │
└──────────────────────────────────────────────────────────┘
                        ↓
┌──────────────────────────────────────────────────────────┐
│                       Data                               │
│                                                          │
│  ProductReadRepositoryImpl                               │
│    │                                                     │
│    ├─► implements ProductReadRepository                 │
│    │                                                     │
│    └─► uses FoodLocalDataSource                         │
└──────────────────────────────────────────────────────────┘
```

## Use Case Categorization

### 🔍 Query Use Cases (Read-only)

- `SearchProductByBarcodeUseCase`
- `SearchProductsByNameUseCase`
- `SearchProductsByBrandUseCase`
- `SearchProductsByCategoryUseCase`
- `FilterProductsUseCase`
- `CompareProductsUseCase`
- `GetFavoritesUseCase`
- `GetSearchHistoryUseCase`
- `GetRecentlyScannedUseCase`
- `GetProductSuggestionsUseCase`

### ✏️ Command Use Cases (Write operations)

- `SubmitProductUseCase`
- `AddToFavoritesUseCase`
- `RemoveFromFavoritesUseCase`
- `ToggleFavoriteUseCase`

## Legend

⭐ = Contains business logic  
✅ = Correct layer placement  
❌ = Incorrect layer placement

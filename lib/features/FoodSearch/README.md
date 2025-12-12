# Food Search Feature

A comprehensive food search feature that allows users to scan barcodes, extract nutrition from labels using OCR, search for products, view detailed nutrition information, compare products, and contribute to the Open Food Facts database.

## Features Implemented

### Core Functionality

- ✅ **Barcode Scanning**: Scan product barcodes using mobile_scanner with custom overlay
- ✅ **OCR Nutrition Scanning**: Extract nutrition facts from food labels using ML Kit OCR
- ✅ **Product Search**: Search products by name, brand, or category with autocomplete
- ✅ **Advanced Search**: Filter by Nutri-Score, NOVA group, dietary preferences
- ✅ **Product Details**: View comprehensive nutrition information including:
  - Nutri-Score (A-E rating)
  - NOVA Group (processing level 1-4)
  - Eco-Score (environmental impact)
  - Detailed nutritional values per 100g
  - Ingredients list with allergen highlighting
  - Labels and certifications (Vegan, Vegetarian, Palm Oil Free)

### User Features

- ✅ **Favorites**: Save favorite products for quick access
- ✅ **Search History**: Track recent searches with date grouping
- ✅ **Product Comparison**: Side-by-side comparison of 2-3 products with visual indicators
- ✅ **Nutrition Guide**: Educational screen explaining Nutri-Score, NOVA, and Eco-Score
- ✅ **Add/Edit Products**: Contribute new products to Open Food Facts

### Data Management

- ✅ **Offline Support**: Cached products available offline
- ✅ **Smart Caching**: Try cache first, then fetch from API (7-day freshness)
- ✅ **Hive Storage**: Efficient local storage using Hive
- ✅ **Pending Uploads**: Queue product submissions for later sync

## Architecture

### Clean Architecture Pattern

```
lib/features/FoodSearch/
├── data/
│   ├── models/              # Data models with Hive adapters
│   │   ├── food_product_model.dart
│   │   ├── nutrition_values_model.dart
│   │   ├── favorite_food_model.dart
│   │   ├── search_history_model.dart
│   │   └── pending_product_upload.dart
│   ├── data_sources/        # Remote (API) and Local (Hive) data sources
│   │   ├── food_remote_data_source.dart
│   │   └── food_local_data_source.dart
│   └── repo/                # Repository with caching logic
│       └── food_search_repo.dart
├── domain/
│   └── entities/            # Domain entities
│       └── nutrition_facts.dart
└── presentation/
    ├── providers/           # Riverpod 3 state management
    │   ├── food_search_provider.dart
    │   ├── favorites_provider.dart
    │   ├── comparison_provider.dart
    │   ├── search_history_provider.dart
    │   ├── advanced_search_provider.dart
    │   ├── ocr_scanner_provider.dart
    │   └── nutrition_state_provider.dart
    ├── screens/             # UI screens
    │   ├── food_search_screen.dart
    │   ├── barcode_scanner_screen.dart
    │   ├── ocr_scanner_screen.dart
    │   ├── product_details_screen.dart
    │   ├── product_comparison_screen.dart
    │   ├── advanced_search_screen.dart
    │   ├── favorites_screen.dart
    │   ├── search_history_screen.dart
    │   ├── product_form_screen.dart
    │   └── nutrition_guide_screen.dart
    └── widgets/             # Reusable widgets
        ├── food_search_widgets.dart
        ├── product_card.dart
        ├── nutrition_score_badge.dart
        ├── nova_group_indicator.dart
        ├── confidence_indicator.dart
        ├── nutrition_field.dart
        ├── nutrition_facts_bottom_sheet.dart
        ├── scanning_overlay_painter.dart
        └── product_form/
            ├── info_card.dart
            ├── product_basic_fields.dart
            ├── product_details_fields.dart
            ├── product_image_picker.dart
            └── product_form_widgets.dart
```

### State Management

- **Riverpod 3**: Modern state management with AutoDisposeNotifier
- **Providers**:
  - `foodSearchRepoProvider`: Repository instance
  - `searchProductByBarcodeProvider`: FutureProvider for barcode search
  - `searchProductsByNameProvider`: FutureProvider for name search
  - `productSuggestionsProvider`: Autocomplete with LRU cache (50 entries, 5-min expiry)
  - `recentlyScannedProvider`: Recently scanned products (limit: 10)
  - `filteredProductsProvider`: Products filtered by search criteria
  - `searchFiltersProvider`: Current active filters state
  - `favoritesProvider`: Favorites management with O(1) lookup
  - `favoritesSortProvider`: Favorites sorting preference
  - `sortedFavoritesProvider`: Sorted favorites list (6 sort options)
  - `isFavoriteProvider`: O(1) favorite status check
  - `searchHistoryProvider`: History management
  - `comparisonProvider`: Product comparison (max 3 products)
  - `isInComparisonProvider`: O(1) comparison status check
  - `advancedSearchProvider`: Search with filters and pagination
  - `ocrScannerProvider`: OCR scanning state management
  - `ocrServiceProvider`: ML Kit OCR service instance
  - `nutritionParsingServiceProvider`: Intelligent nutrition parser
  - `nutritionStateProvider`: Nutrition input form state

### Performance Optimizations

- **LRU Cache for Suggestions**: 
  - Maximum 50 cached queries
  - 5-minute cache expiry per entry
  - Automatic eviction of least recently used entries
  - Query normalization (lowercase, trimmed)
- **O(1) Operations**: 
  - Favorite status checks using HashSet
  - Product lookup by barcode (Hive key-based)
  - Comparison list membership checks
- **Smart Pagination**: 
  - Page size: 20 products
  - Infinite scroll with `hasMoreResults` tracking
  - `isLoadingMore` state prevents concurrent loads
- **Responsive Grids**: 
  - Dynamic column calculation based on screen size
  - Mobile: 2 columns, Tablet: 4 columns, Desktop: 4 columns

### Local Storage

- **Hive Boxes**:
  - `foodProductsBox`: Cached products (typeId: 10, barcode as key)
  - `searchHistoryBox`: Search history (typeId: 6)
  - `favoriteFoodsBox`: Favorite products (typeId: 7, barcode as key)
  - `pendingUploadsBox`: Pending product uploads
- **Key-Based Access**: O(1) lookup using barcode as key for products and favorites
- **Automatic Eviction**: Search history limited to last 50 searches
- **Sort Options Storage**: User's favorite sort preference persisted

### Favorites Sorting

The feature supports 6 sorting options:

```dart
enum FavoritesSortOption {
  dateNewest,   // Default - Recently added first
  dateOldest,   // Oldest favorites first
  nameAsc,      // A-Z by product name
  nameDesc,     // Z-A by product name
  brandAsc,     // A-Z by brand name
  brandDesc,    // Z-A by brand name
}
```

- **Implementation**: `sortedFavoritesProvider` applies sorting without mutating original list
- **Performance**: Creates sorted copy, O(n log n) complexity
- **Case-Insensitive**: Name and brand sorting uses lowercase comparison

## API Integration

### Open Food Facts

- **SDK**: openfoodfacts ^3.27.0
- **Configuration**: Initialized in main.dart with User Agent
- **Languages**: English, Arabic
- **Features**:
  - Product search by barcode
  - Product search by name/brand/category
  - Autocomplete suggestions with smart filtering
  - Add/Edit products
- **Optimization**:
  - Reduced payload with specific ProductFields for list views
  - Category and brand search support
  - Query normalization for better results

### Autocomplete Suggestions with LRU Cache

The `productSuggestionsProvider` implements an efficient LRU (Least Recently Used) caching strategy:

```dart
/// LRU Cache Implementation
class _SuggestionsLRUCache {
  static final Map<String, _CacheEntry> _cache = {};
  static const int maxEntries = 50;
  static const Duration expiryDuration = Duration(minutes: 5);
  
  // Features:
  // - O(1) get/put operations
  // - Automatic expiry after 5 minutes
  // - LRU eviction when exceeding 50 entries
  // - Query normalization (lowercase, trimmed)
}
```

**Benefits**:
- Reduces API calls for repeated queries
- Instant response for cached suggestions
- Memory-efficient with bounded cache size
- Fresh data with TTL expiry

### OCR Services

- **Google ML Kit**: Text recognition for nutrition label extraction
- **Image Cropping**: Pre-processing step to isolate nutrition labels
  - Pure Dart implementation (stable, no platform channel crashes)
  - Interactive crop with pinch-to-zoom and drag
  - Rotation controls
  - Custom overlay with corner dot controls
  - Reduces OCR noise by removing irrelevant content
- **Custom Parsing**: Intelligent nutrition facts parser with confidence scoring
- **OCR Flow**:
  1. Image capture or gallery selection
  2. **User crops image to isolate nutrition label** ⭐
  3. ML Kit text extraction
  4. Intelligent parsing with pattern matching
  5. Confidence scoring per field (0.0-1.0)
  6. Field color-coding: High (≥0.7), Medium (0.4-0.7), Low (<0.4)
  7. Automatic review flagging for low-confidence results
- **Confidence Thresholds**:
  - High confidence: ≥ 0.7 (green indicator)
  - Medium confidence: 0.4 - 0.7 (orange indicator)
  - Low confidence: < 0.4 (red indicator, requires review)
- **Data Modes**: Supports both "per 100g" and "per serving" extraction
- **Logging**: Detailed field-by-field extraction logs for debugging
- **Error Handling**: 
  - No text found: "Try a clearer photo"
  - No nutrition data: "Make sure the nutrition label is clearly visible"
  - Processing errors: Retryable with user feedback

## Screens

### 1. Food Search Home Screen (`/foodSearch`)

- Quick action buttons for scanning, favorites, advanced search, comparison
- Recently scanned products (horizontal list with shimmer loading)
- Nutrition guide access
- Empty state with call-to-action
- Responsive grid layout (2/4 columns based on screen size)
- Pull-to-refresh support
- Interstitial ad integration with proper lifecycle management

### 2. Barcode Scanner Screen (`/barcodeScanner`)

- Full-screen scanner with custom animated overlay
- Manual barcode input option
- Torch toggle
- Vibration feedback on successful scan
- Localized instructions

### 3. OCR Scanner Screen (`/ocrScanner`)

- Camera-based nutrition label scanning with safe disposal
- **Image Cropping**: User can crop captured/gallery images before OCR
  - Pure Dart implementation (no platform channel issues)
  - Interactive pinch-to-zoom and drag
  - Rotation support
  - Removes noise and background for better accuracy
  - Custom crop overlay with corner controls
- Gallery image picker option (camera and gallery)
- Real-time processing with multi-stage loading states
- Confetti animation on successful scan
- Confidence indicators for extracted values (high/medium/low)
- Color-coded fields based on confidence levels
- Bottom sheet with extracted nutrition facts
- Manual editing before saving
- Detailed OCR logging with field-by-field confidence scores
- Aspect ratio-aware camera preview with Transform scaling

### 4. Product Details Screen (`/productDetails`)

- Hero animation for product image
- Comprehensive nutrition information
- Interactive nutrition scores (Nutri-Score, NOVA, Eco-Score)
- Allergen warnings with chips
- Favorite toggle with animation
- Add to comparison button with flushbar notification
- Navigate to edit product

### 5. Product Comparison Screen (`/productComparison`)

- Side-by-side comparison of 2-3 products
- Visual hierarchy with product cards (tap to view details)
- Nutrition value highlighting (best=green, worst=red)
- Dietary information comparison (Vegan, Vegetarian, Palm Oil Free)
- Clear all and add product actions

### 6. Advanced Search Screen (`/advancedSearch`)

- Real-time search with debouncing (500ms)
- Collapsible filter panel with active filter count
- Infinite scroll pagination (20 products per page)
- State management: `isLoading`, `isLoadingMore`, `hasMoreResults`, `currentPage`
- Filter by:
  - Nutri-Score (A-E with color chips)
  - NOVA Group (1-4)
  - Dietary preferences (Vegan, Vegetarian, Palm Oil Free)
  - Categories (multiple selection)
  - Brands (multiple selection)
- Staggered list animations
- Empty and error states
- Clear filters action

### 7. Favorites Screen (`/favorites`)

- Grid view of favorite products (responsive)
- **6 Sorting Options**:
  - Date Added (Newest First) ⭐ Default
  - Date Added (Oldest First)
  - Product Name (A-Z)
  - Product Name (Z-A)
  - Brand Name (A-Z)
  - Brand Name (Z-A)
- Swipe to delete functionality
- Tap to view product details
- Empty state with action button
- Sort persistence across sessions

### 8. Search History Screen (`/searchHistory`)

- Chronological list of searches grouped by date
- Clear all history option
- Tap to re-run search

### 9. Product Form Screen (`/productForm`)

- Add new products or edit existing
- Image picker with camera/gallery options
- Basic fields: Barcode, Product Name, Brand
- Nutrition facts input
- Contribution message

### 10. Nutrition Guide Screen (`/nutritionGuide`)

- Educational content explaining:
  - Nutri-Score (A-E) with examples
  - NOVA Classification (1-4) with examples
  - Eco-Score (A-E) with examples
- Quick tips for healthier choices
- Visual score cards with color coding

## Widgets

### Reusable Components

- `ProductCard`: Compact product display for lists/grids
- `NutritionScoreBadge`: Circular or shield-style Nutri-Score badge
- `NutritionScoreShield`: Shield-shaped Nutri-Score display
- `NovaGroupIndicator`: NOVA group visualization (1-4 filled circles)
- `EcoscoreWidget`: Eco-Score letter display with color
- `NutritionProgressBar`: Visual nutrition value bars with max reference
- `AllergenChip`: Highlighted allergen warnings
- `EmptyStateWidget`: Friendly empty states with action button
- `LoadingProductShimmer`: Skeleton loading states
- `ProductImageWidget`: Image with error handling and placeholder

### OCR/Form Specific

- `ConfidenceIndicator`: Shows OCR confidence level (high/medium/low)
- `NutritionField`: Input field for nutrition values with validation
- `NutritionFactsBottomSheet`: Displays extracted OCR data with editing
- `ScanningOverlayPainter`: Custom paint for scanner frame animation

### Product Form Widgets

- `InfoCard`: Styled information card
- `ProductBasicFields`: Barcode, name, brand inputs
- `ProductDetailsFields`: Additional product details
- `ProductImagePicker`: Camera/gallery image selection

### Product Comparison Widgets

- `ComparisonContentView`: Main comparison layout
- `ComparisonSectionRow`: Section headers for comparison
- `NutritionComparisonRow`: Side-by-side nutrition value comparison
- `ProductHeaderCard`: Product card header in comparison
- `SingleProductView`: Individual product view in comparison
- `ProductComparisonWidgets`: Barrel file for comparison widgets

## Routes

| Route                | Screen                  | Description                  |
| -------------------- | ----------------------- | ---------------------------- |
| `/foodSearch`        | FoodSearchScreen        | Main food search home        |
| `/barcodeScanner`    | BarcodeScannerScreen    | Barcode scanning             |
| `/ocrScanner`        | OcrScannerScreen        | OCR nutrition label scanning |
| `/productDetails`    | ProductDetailsScreen    | Product information          |
| `/productComparison` | ProductComparisonScreen | Compare products             |
| `/advancedSearch`    | AdvancedSearchScreen    | Filtered search              |
| `/favorites`         | FavoritesScreen         | Favorite products            |
| `/searchHistory`     | SearchHistoryScreen     | Search history               |
| `/productForm`       | ProductFormScreen       | Add/edit products            |
| `/nutritionGuide`    | NutritionGuideScreen    | Educational guide            |

## Dependencies

```yaml
dependencies:
  openfoodfacts: ^3.27.0 # Open Food Facts API
  mobile_scanner: ^5.0.0 # Barcode scanning
  google_mlkit_text_recognition: # OCR text extraction
  crop_your_image: ^2.0.0 # Stable image cropping
  flutter_staggered_animations: ^1.1.1 # List animations
  badges: ^3.1.2 # Notification badges
  image_picker: ^1.0.7 # Image selection
  camera: # Camera access for OCR
  confetti: # Success animations
  hive: ^2.2.3 # Local storage
  hive_flutter: ^1.1.0 # Hive Flutter integration
  flutter_riverpod: # State management
  cached_network_image: # Image caching
  another_flushbar: # Toast notifications
  google_mobile_ads: # Ad integration
```

## Usage

### Initialize in main.dart

```dart
// Initialize Open Food Facts API
OpenFoodAPIConfiguration.userAgent = UserAgent(
  name: 'Warrior App',
  version: '1.1.0',
  system: 'Flutter',
);
OpenFoodAPIConfiguration.globalLanguages = [
  OpenFoodFactsLanguage.ENGLISH,
  OpenFoodFactsLanguage.ARABIC,
];
```

### Navigation

Access from Home Screen → Food Search card

## Technical Implementation Details

### Camera Management (OCR Scanner)

```dart
// Safe camera controller disposal
@override
void dispose() {
  if (_cameraController?.value.isInitialized ?? false) {
    _cameraController?.dispose();
  }
  super.dispose();
}

// Aspect ratio-aware preview
Transform.scale(
  scale: scale, // Calculated from camera and screen aspect ratios
  child: Center(child: CameraPreview(controller)),
)
```

### Responsive Layout Strategy

```dart
// Dynamic column calculation
final columns = ResponsiveUtils.getGridColumns(
  context,
  mobile: 2,    // 2 columns on mobile
  tablet: 4,    // 4 columns on tablet
  desktop: 4,   // 4 columns on desktop
);
```

### Haptic Feedback Integration

```dart
// Different feedback types for different actions
HapticFeedback.mediumImpact();  // Add to favorites
HapticFeedback.lightImpact();   // Remove from favorites
HapticFeedback.heavyImpact();   // Comparison limit reached
HapticFeedback.selectionClick(); // Already in comparison
```

### Advanced Search State Machine

```dart
// State properties
isLoading: bool         // Initial search in progress
isLoadingMore: bool     // Loading next page
hasMoreResults: bool    // More pages available
currentPage: int        // Current pagination page
results: List           // Accumulated results
errorMessage: String?   // Error state
```

## Testing

## Performance Considerations

- **Image Caching**: All product images cached using cached_network_image
- **Lazy Loading**: Recently scanned uses horizontal ListView.builder
- **Smart Caching**: 7-day cache freshness check with automatic refresh
- **Debounced Search**: 500ms debounce on search input to reduce API calls
- **O(1) Favorite Lookup**: Barcode-based Hive key for instant favorite checks
- **O(1) Comparison Check**: HashSet membership testing
- **Optimized Hive Reads**: Key-based access instead of iteration
- **LRU Suggestions Cache**: 
  - 50-entry maximum to prevent memory bloat
  - 5-minute TTL per cached query
  - Automatic eviction of oldest entries
- **Pagination Strategy**: 
  - 20 products per page for optimal load times
  - Infinite scroll with `isLoadingMore` guard
  - Prevents concurrent page loads
- **Staggered Animations**: Smooth list appearance without performance hit
- **Responsive Layouts**: Dynamic grid columns based on breakpoints
- **Camera Disposal**: Proper cleanup to prevent memory leaks
- **Ad Lifecycle**: Interstitial ads loaded/disposed with screen lifecycle

## Accessibility

- Semantic labels for screen readers
- Sufficient color contrast in nutrition scores
- Text scaling support
- Haptic feedback on scan success

## Known Limitations

1. **Product Coverage**: Not all products (especially local/regional) may be in Open Food Facts database
2. **Data Quality**: Some products may have incomplete information
3. **Offline Limitations**: First search requires internet connection
4. **OCR Accuracy**: Depends on image quality, lighting, and label format
5. **Comparison Limit**: Maximum 3 products can be compared at once
6. **LRU Cache**: Suggestions cache limited to 50 queries (5-min TTL)
7. **Pagination**: Advanced search loads 20 products per page
8. **Camera Requirements**: OCR scanner requires camera permissions and adequate lighting

## Future Enhancements

- [ ] Barcode generation for custom products
- [ ] Export nutrition data (PDF/CSV)
- [ ] Meal planning integration
- [ ] Nutrition goal tracking
- [ ] Social features (share products/comparisons)
- [ ] Offline OCR processing
- [ ] Enhanced allergen warnings
- [ ] Product recommendations based on preferences
- [ ] Multi-language OCR support beyond English/Arabic

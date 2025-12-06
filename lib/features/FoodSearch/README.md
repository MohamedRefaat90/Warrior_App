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
  - `favoritesProvider`: Favorites management with O(1) lookup
  - `searchHistoryProvider`: History management
  - `comparisonProvider`: Product comparison (max 3 products)
  - `advancedSearchProvider`: Search with filters and pagination
  - `ocrScannerProvider`: OCR scanning state management
  - `nutritionStateProvider`: Nutrition input form state

### Local Storage

- **Hive Boxes**:
  - `foodProductsBox`: Cached products (typeId: 5)
  - `searchHistoryBox`: Search history (typeId: 6)
  - `favoriteFoodsBox`: Favorite products (typeId: 7)
  - `pendingUploadsBox`: Pending product uploads

## API Integration

### Open Food Facts

- **SDK**: openfoodfacts ^3.27.0
- **Configuration**: Initialized in main.dart with User Agent
- **Languages**: English, Arabic
- **Features**:
  - Product search by barcode
  - Product search by name/brand/category
  - Autocomplete suggestions
  - Add/Edit products

### OCR Services

- **Google ML Kit**: Text recognition for nutrition label extraction
- **Custom Parsing**: Intelligent nutrition facts parser with confidence scoring

## Screens

### 1. Food Search Home Screen (`/foodSearch`)

- Quick action buttons for scanning, favorites, advanced search, comparison
- Recently scanned products (horizontal list with shimmer loading)
- Nutrition guide access
- Empty state with call-to-action

### 2. Barcode Scanner Screen (`/barcodeScanner`)

- Full-screen scanner with custom animated overlay
- Manual barcode input option
- Torch toggle
- Vibration feedback on successful scan
- Localized instructions

### 3. OCR Scanner Screen (`/ocrScanner`)

- Camera-based nutrition label scanning
- Gallery image picker option
- Real-time processing with loading states
- Confidence indicators for extracted values
- Bottom sheet with extracted nutrition facts
- Manual editing before saving

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

- Real-time search with debouncing
- Collapsible filter panel with active filter count
- Filter by:
  - Nutri-Score (A-E with color chips)
  - NOVA Group (1-4)
  - Dietary preferences (Vegan, Vegetarian, Palm Oil Free)
- Staggered list animations
- Empty and error states

### 7. Favorites Screen (`/favorites`)

- Grid view of favorite products
- Swipe to delete functionality
- Tap to view product details
- Empty state with action button

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
  google_mlkit_text_recognition: ^x.x.x # OCR text extraction
  flutter_staggered_animations: ^1.1.1 # List animations
  badges: ^3.1.2 # Notification badges
  image_picker: ^1.0.7 # Image selection
  hive: ^2.2.3 # Local storage
  hive_flutter: ^1.1.0 # Hive Flutter integration
  cached_network_image: (existing) # Image caching
  another_flushbar: (existing) # Toast notifications
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

## Testing

## Performance Considerations

- **Image Caching**: All product images cached using cached_network_image
- **Lazy Loading**: Recently scanned uses horizontal ListView
- **Smart Caching**: 7-day cache freshness check
- **Debounced Search**: 500ms debounce on search input
- **O(1) Favorite Lookup**: HashSet for fast favorite checks
- **Optimized Hive Reads**: Efficient local queries
- **Staggered Animations**: Smooth list appearance

## Accessibility

- Semantic labels for screen readers
- Sufficient color contrast in nutrition scores
- Text scaling support
- Haptic feedback on scan success

## Known Limitations

1. **Product Coverage**: Not all products (especially local/regional) may be in Open Food Facts database
2. **Data Quality**: Some products may have incomplete information
3. **Offline Limitations**: First search requires internet connection
4. **OCR Accuracy**: Depends on image quality and label format
5. **Comparison Limit**: Maximum 3 products can be compared at once

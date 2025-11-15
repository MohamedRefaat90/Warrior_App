# Food Search Feature

A comprehensive food search feature that allows users to scan barcodes, search for products, view detailed nutrition information, and contribute to the Open Food Facts database.

## Features Implemented

### Core Functionality
- ✅ **Barcode Scanning**: Scan product barcodes using mobile_scanner
- ✅ **Product Search**: Search products by name, brand, or category
- ✅ **Product Details**: View comprehensive nutrition information including:
  - Nutri-Score (A-E rating)
  - NOVA Group (processing level)
  - Eco-Score (environmental impact)
  - Detailed nutritional values per 100g
  - Ingredients list with allergen highlighting
  - Labels and certifications (Vegan, Vegetarian, Palm Oil Free)

### User Features
- ✅ **Favorites**: Save favorite products for quick access
- ✅ **Search History**: Track recent searches
- ✅ **Local Caching**: Products cached locally for offline access (7-day freshness)
- ✅ **Recently Scanned**: Quick access to recently viewed products

### Data Management
- ✅ **Offline Support**: Cached products available offline
- ✅ **Smart Caching**: Try cache first, then fetch from API
- ✅ **Hive Storage**: Efficient local storage using Hive
- ✅ **Future-Ready Sync**: Structured for future server synchronization

## Architecture

### Clean Architecture Pattern
```
lib/features/FoodSearch/
├── data/
│   ├── models/           # Data models with Hive adapters
│   ├── data_sources/     # Remote (API) and Local (Hive) data sources
│   └── repo/             # Repository with caching logic
└── presentation/
    ├── providers/        # Riverpod 3 state management
    ├── screens/          # UI screens
    └── widgets/          # Reusable widgets
```

### State Management
- **Riverpod 3**: Modern state management with AutoDisposeNotifier
- **Providers**:
  - `foodSearchRepoProvider`: Repository instance
  - `searchProductByBarcodeProvider`: FutureProvider for barcode search
  - `favoritesProvider`: Favorites management
  - `searchHistoryProvider`: History management
  - `comparisonProvider`: Product comparison (ready for implementation)

### Local Storage
- **Hive Boxes**:
  - `foodProductsBox`: Cached products (typeId: 5)
  - `favoriteFoodsBox`: Favorite products (typeId: 7)
  - `searchHistoryBox`: Search history (typeId: 6)

## API Integration

### Open Food Facts
- **SDK**: openfoodfacts ^3.27.0
- **Configuration**: Initialized in main.dart with User Agent
- **Languages**: English, Arabic
- **Features**:
  - Product search by barcode
  - Product search by name/brand/category
  - Autocomplete suggestions
  - Future: Add/Edit products (UI ready, needs implementation)

## Screens

### 1. Food Search Home Screen
- Quick action buttons for scanning, favorites, advanced search, comparison
- Recently scanned products (horizontal list)
- Empty state with call-to-action

### 2. Barcode Scanner Screen
- Full-screen scanner with custom overlay
- Animated scanning frame
- Manual barcode input option
- Torch toggle
- Vibration feedback on scan

### 3. Product Details Screen
- Hero animation for product image
- Comprehensive nutrition information
- Interactive nutrition scores
- Allergen warnings
- Favorite toggle
- Share functionality
- Add to comparison

### 4. Favorites Screen
- Grid view of favorite products
- Swipe to delete (ready for implementation)
- Sort options (ready for implementation)

### 5. Search History Screen
- Chronological list of searches
- Grouped by date
- Clear history option
- Tap to re-run search (ready for implementation)

## Widgets

### Reusable Components
- `ProductCard`: Compact product display for lists
- `NutritionScoreBadge`: Circular or shield-style Nutri-Score badge
- `NovaGroupIndicator`: NOVA group visualization (1-4 circles)
- `EcoscoreWidget`: Eco-Score display
- `NutritionProgressBar`: Visual nutrition value bars
- `AllergenChip`: Highlighted allergen warnings
- `EmptyStateWidget`: Friendly empty states
- `LoadingProductShimmer`: Skeleton loading states
- `ProductImageWidget`: Image with error handling

## Future Enhancements (Not Yet Implemented)

### Advanced Search Screen
- Complex filtering by multiple criteria
- Autocomplete suggestions
- Filter by Nutri-Score, NOVA, allergens, dietary preferences
- Save filter presets

### Product Comparison Screen
- Side-by-side comparison of 2-3 products
- Highlight best/worst values
- Share comparison

### Add/Edit Product Form
- Contribute new products to Open Food Facts
- Edit existing product information
- Upload product images
- Structured nutrition facts input

### Animations
- Staggered list animations
- Smooth transitions
- Favorite button animations

## Dependencies

```yaml
dependencies:
  openfoodfacts: ^3.27.0          # Open Food Facts API
  mobile_scanner: ^5.0.0          # Barcode scanning
  flutter_staggered_animations: ^1.1.1  # List animations
  badges: ^3.1.2                  # Notification badges
  image_picker: ^1.0.7            # Image selection
  hive: ^2.2.3                    # Local storage
  hive_flutter: ^1.1.0            # Hive Flutter integration
  cached_network_image: (existing) # Image caching
  share_plus: (existing)          # Sharing functionality
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

### Routes
- `/foodSearch` - Main food search screen
- `/barcodeScanner` - Barcode scanner
- `/productDetails` - Product details
- `/favorites` - Favorites (ready)
- `/searchHistory` - Search history (ready)
- `/advancedSearch` - Advanced search (pending)
- `/productComparison` - Comparison (pending)
- `/productForm` - Add/Edit product (pending)

## Testing

### Manual Testing Checklist
- [ ] Scan barcode with valid product
- [ ] Scan barcode with invalid product
- [ ] Search product by name
- [ ] Add product to favorites
- [ ] Remove product from favorites
- [ ] View product details
- [ ] Check offline caching
- [ ] Verify search history
- [ ] Test with no internet connection

## Performance Considerations

- **Image Caching**: All product images cached using cached_network_image
- **Lazy Loading**: Recently scanned uses horizontal ListView
- **Smart Caching**: 7-day cache freshness check
- **Debounced Search**: Search suggestions debounced (ready for implementation)
- **Optimized Hive Reads**: Efficient local queries

## Accessibility

- Semantic labels for screen readers (ready for enhancement)
- Sufficient color contrast in nutrition scores
- Text scaling support
- Keyboard navigation support (ready for enhancement)

## Known Limitations

1. **Product Coverage**: Not all products (especially local/regional) may be in Open Food Facts database
2. **Data Quality**: Some products may have incomplete information
3. **Offline Limitations**: First search requires internet connection
4. **Image Upload**: Not yet implemented
5. **Advanced Filters**: Not yet implemented
6. **Product Comparison**: Not yet implemented

## Contributing

To add new features:
1. Follow existing Clean Architecture pattern
2. Use Riverpod 3 AutoDisposeNotifier for state management
3. Add Hive models with proper typeId
4. Implement offline-first approach
5. Add proper error handling
6. Follow Flutter best practices

## License

This feature integrates with Open Food Facts, which is licensed under ODbL (Open Database License).


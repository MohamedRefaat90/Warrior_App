# FoodSearch Use Cases - Quick Reference

## 🚀 Quick Start

### Import All Use Cases

```dart
import 'package:Warrior/features/FoodSearch/domain/usecases/usecases.dart';
```

### Or Import Individual Use Cases

```dart
import 'package:Warrior/features/FoodSearch/domain/usecases/filter_products_use_case.dart';
```

## 📋 Use Case Cheat Sheet

### Search Operations

#### Search by Barcode

```dart
final useCase = SearchProductByBarcodeUseCase(repository);
final product = await useCase('1234567890123');
```

#### Search by Name

```dart
final useCase = SearchProductsByNameUseCase(repository);
final products = await useCase('chocolate', page: 1, pageSize: 25);
```

#### Search by Brand

```dart
final useCase = SearchProductsByBrandUseCase(repository);
final products = await useCase('Nestle', page: 1, pageSize: 25);
```

#### Search by Category

```dart
final useCase = SearchProductsByCategoryUseCase(repository);
final products = await useCase('snacks', page: 1, pageSize: 25);
```

### Filtering & Comparison

#### Filter Products

```dart
final useCase = FilterProductsUseCase(repository);
final filtered = useCase(
  nutriScore: 'A',
  vegan: true,
  vegetarian: false,
  palmOilFree: true,
  allergens: ['milk', 'eggs'],
  novaGroup: 1,
);
```

#### Compare Products

```dart
final useCase = CompareProductsUseCase(repository);
final products = await useCase(['barcode1', 'barcode2', 'barcode3']);
```

### Favorites Management

#### Add to Favorites

```dart
final useCase = AddToFavoritesUseCase(repository);
await useCase(product);
```

#### Remove from Favorites

```dart
final useCase = RemoveFromFavoritesUseCase(repository);
await useCase('barcode');
```

#### Toggle Favorite

```dart
final useCase = ToggleFavoriteUseCase(repository);
await useCase(product);

// Check if favorite
final isFavorite = useCase.isFavorite('barcode');
```

#### Get Favorites

```dart
final useCase = GetFavoritesUseCase(repository);
final favorites = useCase();
```

### History & Suggestions

#### Get Search History

```dart
final useCase = GetSearchHistoryUseCase(repository);
final history = useCase(limit: 20);
```

#### Get Recently Scanned

```dart
final useCase = GetRecentlyScannedUseCase(repository);
final recent = useCase(limit: 10);
```

#### Get Suggestions

```dart
final useCase = GetProductSuggestionsUseCase(repository);
final suggestions = await useCase('choc');
```

### Product Management

#### Submit Product

```dart
final useCase = SubmitProductUseCase(repository);
final success = await useCase(
  product: product,
  user: user,
  imagePath: '/path/to/image.jpg',
  isUpdate: false,
);
```

## 🎯 Riverpod Integration

### Define Providers

```dart
// Repository providers
final productReadRepositoryProvider = Provider<ProductReadRepository>((ref) {
  return ProductReadRepositoryImpl(
    remoteDataSource: ref.watch(foodRemoteDataSourceProvider),
    localDataSource: ref.watch(foodLocalDataSourceProvider),
  );
});

// Use case providers
final filterProductsUseCaseProvider = Provider<FilterProductsUseCase>((ref) {
  return FilterProductsUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

final searchByBarcodeUseCaseProvider = Provider<SearchProductByBarcodeUseCase>((ref) {
  return SearchProductByBarcodeUseCase(
    ref.watch(productReadRepositoryProvider),
  );
});

// Add more use case providers as needed...
```

### Use in Controllers

```dart
class ProductListController extends StateNotifier<AsyncValue<List<ProductEntity>>> {
  final FilterProductsUseCase _filterUseCase;

  ProductListController(this._filterUseCase) : super(const AsyncValue.loading());

  void filterProducts({String? nutriScore, bool? vegan}) {
    state = const AsyncValue.loading();
    try {
      final filtered = _filterUseCase(
        nutriScore: nutriScore,
        vegan: vegan,
      );
      state = AsyncValue.data(filtered);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

// Provider
final productListControllerProvider =
    StateNotifierProvider<ProductListController, AsyncValue<List<ProductEntity>>>((ref) {
  return ProductListController(
    ref.watch(filterProductsUseCaseProvider),
  );
});
```

### Use in Widgets

```dart
class ProductListScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final productsState = ref.watch(productListControllerProvider);

    return productsState.when(
      data: (products) => ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => ProductCard(products[index]),
      ),
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

## 🧪 Testing Examples

### Unit Test - FilterProductsUseCase

```dart
void main() {
  late FilterProductsUseCase useCase;
  late MockProductReadRepository mockRepository;

  setUp(() {
    mockRepository = MockProductReadRepository();
    useCase = FilterProductsUseCase(mockRepository);
  });

  test('filters products by vegan status', () {
    // Arrange
    final veganProduct = ProductEntity(
      barcode: '1',
      isVegan: true,
      lastUpdated: DateTime.now(),
    );
    final nonVeganProduct = ProductEntity(
      barcode: '2',
      isVegan: false,
      lastUpdated: DateTime.now(),
    );

    when(mockRepository.getAllCachedProducts())
        .thenReturn([veganProduct, nonVeganProduct]);

    // Act
    final result = useCase(vegan: true);

    // Assert
    expect(result, [veganProduct]);
    expect(result, isNot(contains(nonVeganProduct)));
  });
}
```

### Unit Test - ToggleFavoriteUseCase

```dart
void main() {
  late ToggleFavoriteUseCase useCase;
  late MockUserInteractionRepository mockRepository;

  setUp(() {
    mockRepository = MockUserInteractionRepository();
    useCase = ToggleFavoriteUseCase(mockRepository);
  });

  test('adds product to favorites when not favorite', () async {
    // Arrange
    final product = ProductEntity(
      barcode: '123',
      lastUpdated: DateTime.now(),
    );

    when(mockRepository.isFavorite('123')).thenReturn(false);
    when(mockRepository.addToFavorites(product))
        .thenAnswer((_) async => {});

    // Act
    await useCase(product);

    // Assert
    verify(mockRepository.addToFavorites(product)).called(1);
    verifyNever(mockRepository.removeFromFavorites(any));
  });

  test('removes product from favorites when already favorite', () async {
    // Arrange
    final product = ProductEntity(
      barcode: '123',
      lastUpdated: DateTime.now(),
    );

    when(mockRepository.isFavorite('123')).thenReturn(true);
    when(mockRepository.removeFromFavorites('123'))
        .thenAnswer((_) async => {});

    // Act
    await useCase(product);

    // Assert
    verify(mockRepository.removeFromFavorites('123')).called(1);
    verifyNever(mockRepository.addToFavorites(any));
  });
}
```

## 📊 Use Case Decision Tree

```
Need to work with products?
│
├─ Searching?
│  ├─ By barcode? → SearchProductByBarcodeUseCase
│  ├─ By name? → SearchProductsByNameUseCase
│  ├─ By brand? → SearchProductsByBrandUseCase
│  └─ By category? → SearchProductsByCategoryUseCase
│
├─ Filtering cached products?
│  └─ FilterProductsUseCase
│
├─ Comparing products?
│  └─ CompareProductsUseCase
│
├─ Managing favorites?
│  ├─ Add? → AddToFavoritesUseCase
│  ├─ Remove? → RemoveFromFavoritesUseCase
│  ├─ Toggle? → ToggleFavoriteUseCase
│  └─ Get all? → GetFavoritesUseCase
│
├─ Getting history/suggestions?
│  ├─ Search history? → GetSearchHistoryUseCase
│  ├─ Recently scanned? → GetRecentlyScannedUseCase
│  └─ Autocomplete? → GetProductSuggestionsUseCase
│
└─ Submitting data?
   └─ SubmitProductUseCase
```

## 💡 Best Practices

### ✅ DO

- Use individual use cases in new code
- Inject use cases via constructor
- Keep use cases focused on single responsibility
- Test use cases independently
- Use Riverpod providers for dependency injection

### ❌ DON'T

- Put business logic in repositories
- Create use cases that do multiple things
- Access data sources directly from use cases
- Mix presentation logic with domain logic
- Skip testing use cases

## 🔗 Related Files

- `REFACTORING_GUIDE.md` - Detailed refactoring documentation
- `REFACTORING_SUMMARY.md` - Summary of changes
- `ARCHITECTURE_DIAGRAM.md` - Visual architecture diagrams
- `usecases.dart` - Barrel export file

## 📞 Support

For questions about use cases or Clean Architecture, refer to:

1. `REFACTORING_GUIDE.md` for detailed explanations
2. `ARCHITECTURE_DIAGRAM.md` for visual references
3. Individual use case files for inline documentation

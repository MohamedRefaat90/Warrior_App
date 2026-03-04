import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final productFormProvider =
    NotifierProvider.autoDispose<ProductFormNotifier, ProductFormState>(
        ProductFormNotifier.new);

class ProductFormNotifier extends Notifier<ProductFormState> {
  @override
  ProductFormState build() {
    return const ProductFormState();
  }

  void initialize({ProductEntity? product, String? barcode}) {
    state = ProductFormState(
      barcode: product?.barcode ?? barcode ?? '',
      productName: product?.productName ?? '',
      brands: product?.brands ?? '',
      quantity: product?.quantity ?? '',
      // ingredients: product?.ingredients ?? '',
      // servingSize: product?.servingSize ?? '',
      // countries: product?.countries ?? '',
      nutrition: product?.nutrition,
      imagePath: null,
      isInitialized: true,
      // Preserve isScanning if needed, mostly logic in UI handles this
    );
  }

  void reset() {
    state = const ProductFormState();
  }

  void setScanning(bool isScanning) {
    state = state.copyWith(isScanning: isScanning);
  }

  void updateField({
    String? barcode,
    String? productName,
    String? brands,
    String? quantity,
    // String? ingredients,
    // String? servingSize,
    // String? countries,
  }) {
    state = state.copyWith(
      barcode: barcode,
      productName: productName,
      brands: brands,
      quantity: quantity,
      // ingredients: ingredients,
      // servingSize: servingSize,
      // countries: countries,
    );
  }

  void updateImage(String? imagePath) {
    TalkerService.debug('Updating image path: $imagePath', 'FORM');
    state = state.copyWith(imagePath: imagePath);
    TalkerService.debug('Image path updated: ${state.imagePath}', 'FORM');
  }

  void updateNutrition(NutritionFacts? nutrition) {
    state = state.copyWith(nutrition: nutrition);
  }
}

class ProductFormState {
  final String barcode;
  final String productName;
  final String brands;
  final String quantity;
  // final String ingredients;
  // final String servingSize;
  // final String countries;
  final NutritionFacts? nutrition;
  final String? imagePath;
  final bool isInitialized;
  final bool isScanning;

  const ProductFormState({
    this.barcode = '',
    this.productName = '',
    this.brands = '',
    this.quantity = '',
    // this.ingredients = '',
    // this.servingSize = '',
    // this.countries = '',
    this.nutrition,
    this.imagePath,
    this.isInitialized = false,
    this.isScanning = false,
  });

  ProductFormState copyWith({
    String? barcode,
    String? productName,
    String? brands,
    String? quantity,
    String? ingredients,
    String? servingSize,
    String? countries,
    NutritionFacts? nutrition,
    String? imagePath,
    bool? isInitialized,
    bool? isScanning,
  }) {
    return ProductFormState(
      barcode: barcode ?? this.barcode,
      productName: productName ?? this.productName,
      brands: brands ?? this.brands,
      quantity: quantity ?? this.quantity,
      // ingredients: ingredients ?? this.ingredients,
      // servingSize: servingSize ?? this.servingSize,
      // countries: countries ?? this.countries,
      nutrition: nutrition ?? this.nutrition,
      imagePath: imagePath,
      isInitialized: isInitialized ?? this.isInitialized,
      isScanning: isScanning ?? this.isScanning,
    );
  }
}

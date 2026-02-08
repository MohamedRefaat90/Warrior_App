/// Test helper utilities for FoodSearch feature
///
/// This library provides common test utilities and constants used across
/// FoodSearch unit, widget, and integration tests to reduce duplication
/// and maintain consistent test patterns.
library;

import 'package:Warrior/features/FoodSearch/domain/entities/nutrition_facts.dart';
import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';

/// Creates a valid test product entity
ProductEntity createTestProduct({
  String? barcode,
  String? productName,
  String? brands,
  String? quantity,
  NutritionFacts? nutrition,
}) {
  return ProductEntity(
      barcode: barcode ?? '5449000000996',
      productName: productName ?? 'Test Product',
      brands: brands ?? 'Test Brand',
      quantity: quantity ?? '100g',
      nutrition: nutrition ?? createTestNutritionFacts(),
      lastUpdated: DateTime.now());
}

/// Creates a valid test nutrition facts
NutritionFacts createTestNutritionFacts({
  double? caloriesPerHundred,
  double? protein,
  double? carbohydrates,
  double? fat,
  double? fiber,
}) {
  return NutritionFacts(
    energyKcal100g: caloriesPerHundred ?? 100.0,
    proteins100g: protein ?? 5.0,
    carbohydrates100g: carbohydrates ?? 20.0,
    fat100g: fat ?? 3.0,
    fiber100g: fiber ?? 2.0,
  );
}

/// Test constants
class FoodSearchTestConstants {
  /// Valid barcodes for testing
  static const String validBarcode8 = '12345678';
  static const String validBarcode13 = '5449000000996';

  /// Invalid barcodes for testing
  static const String invalidBarcodeShort = '1234567';
  static const String invalidBarcodeLong = '12345678901234';
  static const String invalidBarcodeLetters = '123ABC456';

  /// Valid product names
  static const String validProductName = 'Test Product';
  static const String validProductNameMin = 'Ab';
  static String validProductNameMax = 'A' * 200; // 200 character product name

  /// Invalid product names
  static const String invalidProductNameEmpty = '';
  static const String invalidProductNameShort = 'A';
  static String invalidProductNameLong = 'A' * 201;

  /// Valid brands
  static const String validBrand = 'Test Brand';
  static String validBrandMax = 'A' * 100;

  /// Valid quantities
  static const String validQuantity = '100g';
  static String validQuantityMax = 'A' * 50;
}

/// Helper function to create multiple test products
List<ProductEntity> createTestProducts({int count = 5}) {
  return List.generate(
    count,
    (index) => createTestProduct(
      barcode: '${5449000000990 + index}',
      productName: 'Test Product $index',
    ),
  );
}

/// Constants for test data validation
const double testImageCompressionQuality = 0.85; // 85% quality setting
const int testMaxRetries = 3;
const int testImageMaxSizeMB = 5;
const int testCacheTTLDays = 7;

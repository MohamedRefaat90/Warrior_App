import 'package:Warrior/features/FoodSearch/data/models/food_product_model.dart';
import 'package:hive/hive.dart';

part 'favorite_food_model.g.dart';

/// Model for favorite food products
/// Allows users to save their favorite products for quick access
@HiveType(typeId: 14)
class FavoriteFoodModel extends HiveObject {
  @HiveField(0)
  final FoodProductModel foodProduct;

  @HiveField(1)
  final DateTime addedDate;

  @HiveField(2)
  final String? notes;

  FavoriteFoodModel({
    required this.foodProduct,
    required this.addedDate,
    this.notes,
  });

  factory FavoriteFoodModel.fromMap(Map<String, dynamic> map) {
    return FavoriteFoodModel(
      foodProduct:
          FoodProductModel.fromMap(map['food_product'] as Map<String, dynamic>),
      addedDate: DateTime.parse(map['added_date'] as String),
      notes: map['notes'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'food_product': foodProduct.toMap(),
      'added_date': addedDate.toIso8601String(),
      'notes': notes,
    };
  }

  FavoriteFoodModel copyWith({
    FoodProductModel? foodProduct,
    DateTime? addedDate,
    String? notes,
  }) {
    return FavoriteFoodModel(
      foodProduct: foodProduct ?? this.foodProduct,
      addedDate: addedDate ?? this.addedDate,
      notes: notes ?? this.notes,
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'food_product_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FoodProductModelAdapter extends TypeAdapter<FoodProductModel> {
  @override
  final int typeId = 10;

  @override
  FoodProductModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FoodProductModel(
      barcode: fields[0] as String,
      productName: fields[1] as String?,
      brands: fields[2] as String?,
      quantity: fields[3] as String?,
      imageUrl: fields[4] as String?,
      imageFrontUrl: fields[5] as String?,
      imageIngredientsUrl: fields[6] as String?,
      imageNutritionUrl: fields[7] as String?,
      nutriScore: fields[8] as String?,
      novaGroup: fields[9] as int?,
      ecoscore: fields[10] as String?,
      nutritionValues: fields[11] as NutritionValuesModel?,
      ingredients: fields[12] as String?,
      allergens: (fields[13] as List?)?.cast<String>(),
      additives: (fields[14] as List?)?.cast<String>(),
      categories: (fields[15] as List?)?.cast<String>(),
      labels: (fields[16] as List?)?.cast<String>(),
      isVegan: fields[17] as bool?,
      isVegetarian: fields[18] as bool?,
      palmOilFree: fields[19] as bool?,
      lastUpdated: fields[20] as DateTime,
      servingSize: fields[21] as String?,
      packagingText: fields[22] as String?,
      countries: fields[23] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FoodProductModel obj) {
    writer
      ..writeByte(24)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.productName)
      ..writeByte(2)
      ..write(obj.brands)
      ..writeByte(3)
      ..write(obj.quantity)
      ..writeByte(4)
      ..write(obj.imageUrl)
      ..writeByte(5)
      ..write(obj.imageFrontUrl)
      ..writeByte(6)
      ..write(obj.imageIngredientsUrl)
      ..writeByte(7)
      ..write(obj.imageNutritionUrl)
      ..writeByte(8)
      ..write(obj.nutriScore)
      ..writeByte(9)
      ..write(obj.novaGroup)
      ..writeByte(10)
      ..write(obj.ecoscore)
      ..writeByte(11)
      ..write(obj.nutritionValues)
      ..writeByte(12)
      ..write(obj.ingredients)
      ..writeByte(13)
      ..write(obj.allergens)
      ..writeByte(14)
      ..write(obj.additives)
      ..writeByte(15)
      ..write(obj.categories)
      ..writeByte(16)
      ..write(obj.labels)
      ..writeByte(17)
      ..write(obj.isVegan)
      ..writeByte(18)
      ..write(obj.isVegetarian)
      ..writeByte(19)
      ..write(obj.palmOilFree)
      ..writeByte(20)
      ..write(obj.lastUpdated)
      ..writeByte(21)
      ..write(obj.servingSize)
      ..writeByte(22)
      ..write(obj.packagingText)
      ..writeByte(23)
      ..write(obj.countries);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodProductModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

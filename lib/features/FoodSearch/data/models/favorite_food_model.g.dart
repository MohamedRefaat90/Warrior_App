// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'favorite_food_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class FavoriteFoodModelAdapter extends TypeAdapter<FavoriteFoodModel> {
  @override
  final int typeId = 14;

  @override
  FavoriteFoodModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return FavoriteFoodModel(
      foodProduct: fields[0] as FoodProductModel,
      addedDate: fields[1] as DateTime,
      notes: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, FavoriteFoodModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.foodProduct)
      ..writeByte(1)
      ..write(obj.addedDate)
      ..writeByte(2)
      ..write(obj.notes);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FavoriteFoodModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

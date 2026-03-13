// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'nutrition_values_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NutritionValuesModelAdapter extends TypeAdapter<NutritionValuesModel> {
  @override
  final typeId = 15;

  @override
  NutritionValuesModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NutritionValuesModel(
      energyKcal: (fields[0] as num?)?.toDouble(),
      energyKj: (fields[1] as num?)?.toDouble(),
      proteins: (fields[2] as num?)?.toDouble(),
      carbohydrates: (fields[3] as num?)?.toDouble(),
      sugars: (fields[4] as num?)?.toDouble(),
      fat: (fields[5] as num?)?.toDouble(),
      saturatedFat: (fields[6] as num?)?.toDouble(),
      fiber: (fields[7] as num?)?.toDouble(),
      sodium: (fields[8] as num?)?.toDouble(),
      salt: (fields[9] as num?)?.toDouble(),
      servingSize: (fields[10] as num?)?.toDouble(),
      confidenceScores: (fields[11] as Map?)?.cast<String, double>(),
      requiresManualReview: fields[12] as bool?,
      ocrScannedAt: fields[13] as DateTime?,
      rawOcrText: fields[14] as String?,
      dataMode: fields[15] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, NutritionValuesModel obj) {
    writer
      ..writeByte(16)
      ..writeByte(0)
      ..write(obj.energyKcal)
      ..writeByte(1)
      ..write(obj.energyKj)
      ..writeByte(2)
      ..write(obj.proteins)
      ..writeByte(3)
      ..write(obj.carbohydrates)
      ..writeByte(4)
      ..write(obj.sugars)
      ..writeByte(5)
      ..write(obj.fat)
      ..writeByte(6)
      ..write(obj.saturatedFat)
      ..writeByte(7)
      ..write(obj.fiber)
      ..writeByte(8)
      ..write(obj.sodium)
      ..writeByte(9)
      ..write(obj.salt)
      ..writeByte(10)
      ..write(obj.servingSize)
      ..writeByte(11)
      ..write(obj.confidenceScores)
      ..writeByte(12)
      ..write(obj.requiresManualReview)
      ..writeByte(13)
      ..write(obj.ocrScannedAt)
      ..writeByte(14)
      ..write(obj.rawOcrText)
      ..writeByte(15)
      ..write(obj.dataMode);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NutritionValuesModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

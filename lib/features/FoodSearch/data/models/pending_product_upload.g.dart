// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_product_upload.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingProductUploadAdapter extends TypeAdapter<PendingProductUpload> {
  @override
  final int typeId = 20;

  @override
  PendingProductUpload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingProductUpload(
      barcode: fields[0] as String,
      productData: (fields[1] as Map).cast<String, dynamic>(),
      nutritionFacts: fields[2] as NutritionValuesModel?,
      imagePath: fields[3] as String?,
      timestamp: fields[4] as DateTime?,
      retryCount: fields[5] as int,
      operationType: fields[6] as SyncOperationType,
    );
  }

  @override
  void write(BinaryWriter writer, PendingProductUpload obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.barcode)
      ..writeByte(1)
      ..write(obj.productData)
      ..writeByte(2)
      ..write(obj.nutritionFacts)
      ..writeByte(3)
      ..write(obj.imagePath)
      ..writeByte(4)
      ..write(obj.timestamp)
      ..writeByte(5)
      ..write(obj.retryCount)
      ..writeByte(6)
      ..write(obj.operationType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingProductUploadAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

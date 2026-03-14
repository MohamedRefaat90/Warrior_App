// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_product_upload.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingProductUploadAdapter extends TypeAdapter<PendingProductUpload> {
  @override
  final typeId = 20;

  @override
  PendingProductUpload read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingProductUpload(
      id: fields[0] as String,
      product: fields[1] as FoodProductModel,
      queuedAt: fields[2] as DateTime,
      retryCount: fields[3] == null ? 0 : (fields[3] as num).toInt(),
      status: fields[4] == null
          ? PendingUploadStatus.pending
          : fields[4] as PendingUploadStatus,
      lastAttemptAt: fields[5] as DateTime?,
      failureReason: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingProductUpload obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.product)
      ..writeByte(2)
      ..write(obj.queuedAt)
      ..writeByte(3)
      ..write(obj.retryCount)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.lastAttemptAt)
      ..writeByte(6)
      ..write(obj.failureReason);
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

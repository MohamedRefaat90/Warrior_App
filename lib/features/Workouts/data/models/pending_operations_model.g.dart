// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pending_operations_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PendingOperationAdapter extends TypeAdapter<PendingOperation> {
  @override
  final int typeId = 5;

  @override
  PendingOperation read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PendingOperation(
      entityType: fields[0] as String,
      operationType: fields[1] as SyncOperationType,
      workout: fields[2] as WorkoutSetModel?,
      id: fields[3] as int?,
      exerciseId: fields[4] as int?,
      weight: fields[5] as num?,
      timestamp: fields[6] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, PendingOperation obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.entityType)
      ..writeByte(1)
      ..write(obj.operationType)
      ..writeByte(2)
      ..write(obj.workout)
      ..writeByte(3)
      ..write(obj.id)
      ..writeByte(4)
      ..write(obj.exerciseId)
      ..writeByte(5)
      ..write(obj.weight)
      ..writeByte(6)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PendingOperationAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class SyncOperationTypeAdapter extends TypeAdapter<SyncOperationType> {
  @override
  final int typeId = 6;

  @override
  SyncOperationType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return SyncOperationType.create;
      case 1:
        return SyncOperationType.update;
      case 2:
        return SyncOperationType.delete;
      default:
        return SyncOperationType.create;
    }
  }

  @override
  void write(BinaryWriter writer, SyncOperationType obj) {
    switch (obj) {
      case SyncOperationType.create:
        writer.writeByte(0);
        break;
      case SyncOperationType.update:
        writer.writeByte(1);
        break;
      case SyncOperationType.delete:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncOperationTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

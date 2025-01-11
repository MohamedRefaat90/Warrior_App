// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'muscle_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MuscleModelAdapter extends TypeAdapter<MuscleModel> {
  @override
  final int typeId = 2;

  @override
  MuscleModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MuscleModel(
      id: fields[0] as int,
      name: fields[1] as String,
      image: fields[2] as String,
      exerciseCount: fields[3] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MuscleModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.image)
      ..writeByte(3)
      ..write(obj.exerciseCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MuscleModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

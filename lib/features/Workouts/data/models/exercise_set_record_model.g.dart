// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_set_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseSetRecordModelAdapter
    extends TypeAdapter<ExerciseSetRecordModel> {
  @override
  final int typeId = 7;

  @override
  ExerciseSetRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseSetRecordModel(
      id: fields[0] as int,
      setNumber: fields[1] as int,
      reps: fields[2] as int,
      weight: fields[3] as num,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseSetRecordModel obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.setNumber)
      ..writeByte(2)
      ..write(obj.reps)
      ..writeByte(3)
      ..write(obj.weight);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSetRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

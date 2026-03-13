// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'exercise_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ExerciseModelAdapter extends TypeAdapter<ExerciseModel> {
  @override
  final typeId = 1;

  @override
  ExerciseModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ExerciseModel(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      description: fields[2] as String,
      image: fields[3] as String,
      video: fields[4] as String,
      targetedMuscles: fields[5] as String,
      muscleID: (fields[6] as num).toInt(),
      muscle: fields[7] as String,
      equipmentType: fields[8] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ExerciseModel obj) {
    writer
      ..writeByte(9)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.image)
      ..writeByte(4)
      ..write(obj.video)
      ..writeByte(5)
      ..write(obj.targetedMuscles)
      ..writeByte(6)
      ..write(obj.muscleID)
      ..writeByte(7)
      ..write(obj.muscle)
      ..writeByte(8)
      ..write(obj.equipmentType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

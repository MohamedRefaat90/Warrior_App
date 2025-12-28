// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'workoutset_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WorkoutItemModelAdapter extends TypeAdapter<WorkoutItemModel> {
  @override
  final int typeId = 4;

  @override
  WorkoutItemModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutItemModel(
      exercise: fields[0] as ExerciseModel,
      lastWeight: fields[1] as num,
      sets: (fields[2] as List?)?.cast<ExerciseSetRecordModel>(),
      previousMaxWeight: fields[3] as num?,
      weightChange: fields[4] as num?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutItemModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.exercise)
      ..writeByte(1)
      ..write(obj.lastWeight)
      ..writeByte(2)
      ..write(obj.sets)
      ..writeByte(3)
      ..write(obj.previousMaxWeight)
      ..writeByte(4)
      ..write(obj.weightChange);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutItemModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class WorkoutSetModelAdapter extends TypeAdapter<WorkoutSetModel> {
  @override
  final int typeId = 3;

  @override
  WorkoutSetModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return WorkoutSetModel(
      id: fields[0] as int?,
      name: fields[1] as String?,
      description: fields[2] as String?,
      createdAt: fields[3] as DateTime?,
      updatedAt: fields[4] as DateTime?,
      workoutItems: (fields[5] as List?)?.cast<WorkoutItemModel>(),
      group: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, WorkoutSetModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.updatedAt)
      ..writeByte(5)
      ..write(obj.workoutItems)
      ..writeByte(6)
      ..write(obj.group);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WorkoutSetModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

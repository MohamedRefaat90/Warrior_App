// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:hive/hive.dart';
part 'workoutset_model.g.dart';

@HiveType(typeId: 4)
class WorkoutItemModel {
  @HiveField(0)
  final ExerciseModel exercise;

  @HiveField(1)
  num lastWeight;

  // @HiveField(2)
  // final String? equipmentType;

  WorkoutItemModel({
    required this.exercise,
    required this.lastWeight,
    // this.equipmentType,
  });

  factory WorkoutItemModel.fromJson(String source) =>
      WorkoutItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutItemModel.fromMap(Map<String, dynamic> map) {
    return WorkoutItemModel(
      exercise: map['exercise'] is ExerciseModel
          ? map['exercise'] as ExerciseModel
          : ExerciseModel.fromMap(map['exercise'] as Map<String, dynamic>),
      lastWeight: double.parse(map['last_weight'].toString()),
      // equipmentType: map['equipment_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'exercise': exercise.toMap(),
      'last_weight': lastWeight,
    };

    // if (equipmentType != null) {
    //   map['equipment_type'] = equipmentType;
    // }

    return map;
  }

  String toJson() => json.encode(toMap());
}

@HiveType(typeId: 3)
class WorkoutSetModel extends HiveObject {
  @HiveField(0)
  final int? id;
  @HiveField(1)
  final String? name;
  @HiveField(2)
  final String? description;
  @HiveField(3)
  final DateTime? createdAt;
  @HiveField(4)
  final DateTime? updatedAt;
  @HiveField(5)
  final List<WorkoutItemModel>? workoutItems;

  WorkoutSetModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.workoutItems,
  });

  factory WorkoutSetModel.fromJson(String source) =>
      WorkoutSetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      createdAt: DateTime.parse(
          map['created_at'] as String? ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(
          map['updated_at'] as String? ?? DateTime.now().toIso8601String()),
      workoutItems: (map['workout_items'] as List<dynamic>?)
              ?.map((x) => WorkoutItemModel.fromMap(x as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'created_at': createdAt?.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'workout_items': workoutItems?.map((x) => x.toMap()).toList(),
    };
  }

  WorkoutSetModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<WorkoutItemModel>? workoutItems,
  }) {
    return WorkoutSetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      workoutItems: workoutItems ?? this.workoutItems,
    );
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:hive/hive.dart';

part 'exercise_model.g.dart';

@HiveType(typeId: 1)
class ExerciseModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final String image;

  @HiveField(4)
  final String video;

  @HiveField(5)
  final String targetedMuscles;

  @HiveField(6)
  final int muscleID;

  @HiveField(7)
  final String muscle;

  @HiveField(8)
  final String? equipmentType;

  ExerciseModel({
    required this.id,
    required this.name,
    required this.description,
    required this.image,
    required this.video,
    required this.targetedMuscles,
    required this.muscleID,
    required this.muscle,
    required this.equipmentType,
  });

  factory ExerciseModel.fromJson(String source) =>
      ExerciseModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      image: map['image'] as String? ?? '',
      video: map['video'] as String? ?? '',
      targetedMuscles: map['targetedMuscles'] as String? ?? '',
      muscleID: map['muscle'] as int? ?? 0,
      muscle: map['muscle_name'] as String? ?? '',
      equipmentType: map['equipment_type'] as String?,
    );
  }

  ExerciseModel copyWith({
    int? id,
    String? name,
    String? description,
    String? image,
    String? video,
    String? targetedMuscles,
    int? muscleID,
    String? muscle,
    String? equipmentType,
  }) {
    return ExerciseModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      image: image ?? this.image,
      video: video ?? this.video,
      targetedMuscles: targetedMuscles ?? this.targetedMuscles,
      muscleID: muscleID ?? this.muscleID,
      muscle: muscle ?? this.muscle,
      equipmentType: equipmentType ?? this.equipmentType,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'image': image,
      'video': video,
      'targetedMuscles': targetedMuscles,
      'muscle': muscleID,
      'muscle_name': muscle,
      'equipment_type': equipmentType,
    };
  }
}

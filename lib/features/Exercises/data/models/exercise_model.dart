import 'dart:convert';

class ExerciseModel {
  final int id;
  final String name;
  final String description;
  final String image;
  final String gif;
  final String targetedMuscles;
  final int muscleID;
  final String muscle;

  ExerciseModel(
      {required this.id,
      required this.name,
      required this.description,
      required this.image,
      required this.gif,
      required this.targetedMuscles,
      required this.muscleID,
      required this.muscle});

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'name': name,
      'description': description,
      'git': gif,
      'image': image,
      'targetedMuscles': targetedMuscles,
      'muscle': muscleID,
      'muscle_name': muscle,
    };
  }

  factory ExerciseModel.fromMap(Map<String, dynamic> map) {
    return ExerciseModel(
      id: map['id'] as int,
      name: map['name'] as String,
      description: map['description'] as String,
      image: map['image'] as String,
      gif: map['gif'] as String,
      targetedMuscles: map['targetedMuscles'] as String,
      muscleID: map['muscle'] as int,
      muscle: map['muscle_name'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory ExerciseModel.fromJson(String source) =>
      ExerciseModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

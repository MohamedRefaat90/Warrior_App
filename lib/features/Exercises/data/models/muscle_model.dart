// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class MuscleModel {
  final int id;
  final String name;
  final String image;
  final int exerciseCount;

  MuscleModel(
      {required this.id,
      required this.name,
      required this.image,
      required this.exerciseCount});

  factory MuscleModel.fromMap(Map<String, dynamic> map) {
    return MuscleModel(
      id: map['id'] as int,
      name: map['name'] as String,
      image: map['image'] as String,
      exerciseCount: map['exercise_count'] as int,
    );
  }

  factory MuscleModel.fromJson(String source) =>
      MuscleModel.fromMap(json.decode(source) as Map<String, dynamic>);
}

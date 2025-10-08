// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';
import 'package:hive/hive.dart';

part 'muscle_model.g.dart';

@HiveType(typeId: 2)
class MuscleModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String image;

  @HiveField(3)
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
}

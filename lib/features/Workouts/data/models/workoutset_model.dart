// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class WorkoutItemModel {
  final int exerciseId;
  final double lastWeight;
  final String? equipmentType;

  WorkoutItemModel({
    required this.exerciseId,
    required this.lastWeight,
    this.equipmentType,
  });

  factory WorkoutItemModel.fromJson(String source) =>
      WorkoutItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutItemModel.fromMap(Map<String, dynamic> map) {
    return WorkoutItemModel(
      exerciseId: map['exercise_id'] as int,
      lastWeight: double.parse(map['last_weight'].toString()),
      equipmentType: map['equipment_type'] as String?,
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'exercise_id': exerciseId,
      'last_weight': lastWeight,
    };

    if (equipmentType != null) {
      map['equipment_type'] = equipmentType;
    }

    return map;
  }

  String toJson() => json.encode(toMap());
}

class WorkoutSetModel {
  final int? id;
  final String? name;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;
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

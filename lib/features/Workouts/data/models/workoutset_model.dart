import 'dart:convert';

class WorkoutItemModel {
  final int exerciseId;
  final String lastWeight;
  WorkoutItemModel({
    required this.exerciseId,
    required this.lastWeight,
  });

  factory WorkoutItemModel.fromJson(String source) =>
      WorkoutItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutItemModel.fromMap(Map<String, dynamic> map) {
    return WorkoutItemModel(
      exerciseId: map['exercise_id'] as int,
      lastWeight: map['last_weight'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'exercise_id': exerciseId,
      'last_weight': lastWeight,
    };
  }
}

class WorkoutSetModel {
  final int id;
  final String name;
  final String description;
  final String user;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<WorkoutItemModel> workoutItems;

  WorkoutSetModel({
    required this.id,
    required this.name,
    required this.description,
    required this.user,
    required this.createdAt,
    required this.updatedAt,
    required this.workoutItems,
  });

  factory WorkoutSetModel.fromJson(String source) =>
      WorkoutSetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    return WorkoutSetModel(
      id: map['id'] as int? ?? 0,
      name: map['name'] as String? ?? '',
      description: map['description'] as String? ?? '',
      user: map['user'] as String? ?? '',
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
      'user': user,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt.millisecondsSinceEpoch,
      'workout_items': workoutItems.map((x) => x.toMap()).toList(),
    };
  }
}

// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:hive/hive.dart';

part 'workoutset_model.g.dart';

@HiveType(typeId: 4)
class WorkoutItemModel {
  @HiveField(0)
  final ExerciseModel exercise;

  @HiveField(1)
  num lastWeight;

  WorkoutItemModel({
    required this.exercise,
    required this.lastWeight,
  });

  factory WorkoutItemModel.fromJson(String source) =>
      WorkoutItemModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutItemModel.fromMap(Map<String, dynamic> map) {
    try {
      // Safely parse exercise
      ExerciseModel exercise;
      if (map['exercise'] is ExerciseModel) {
        exercise = map['exercise'] as ExerciseModel;
      } else if (map['exercise'] is Map<String, dynamic>) {
        exercise =
            ExerciseModel.fromMap(map['exercise'] as Map<String, dynamic>);
      } else {
        throw Exception('Invalid exercise data');
      }

      // Safely parse last weight
      num lastWeight = 0.0;
      try {
        if (map['last_weight'] != null) {
          lastWeight = double.parse(map['last_weight'].toString());
        }
      } catch (e) {
        TalkerService.warning(
            'Error parsing last_weight, defaulting to 0.0', 'WORKOUT_ITEM', e);
        lastWeight = 0.0;
      }

      return WorkoutItemModel(
        exercise: exercise,
        lastWeight: lastWeight,
      );
    } catch (e) {
      TalkerService.error('Error parsing WorkoutItemModel', 'WORKOUT_ITEM', e);
      rethrow; // Re-throw to be caught by the parent parser
    }
  }

  WorkoutItemModel copyWith({
    ExerciseModel? exercise,
    num? lastWeight,
  }) {
    return WorkoutItemModel(
      exercise: exercise ?? this.exercise,
      lastWeight: lastWeight ?? this.lastWeight,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'exercise': exercise.toMap(),
      'last_weight': lastWeight,
    };

    return map;
  }
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
    try {
      // Safely parse workout items with better error handling
      List<WorkoutItemModel> workoutItems = [];

      if (map['workout_items'] != null) {
        final workoutItemsData = map['workout_items'];
        if (workoutItemsData is List) {
          for (var item in workoutItemsData) {
            try {
              if (item is Map<String, dynamic>) {
                workoutItems.add(WorkoutItemModel.fromMap(item));
              }
            } catch (e) {
              // Skip invalid workout items instead of failing completely
              TalkerService.warning(
                  'Skipping invalid workout item', 'WORKOUT_SET', e);
              continue;
            }
          }
        }
      }

      return WorkoutSetModel(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        createdAt: _parseDateTime(map['created_at']),
        updatedAt: _parseDateTime(map['updated_at']),
        workoutItems: workoutItems,
      );
    } catch (e) {
      // If all else fails, return a minimal valid object
      TalkerService.error('Error parsing WorkoutSetModel', 'WORKOUT_SET', e);
      return WorkoutSetModel(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? 'Unknown Workout',
        description: map['description'] as String? ?? '',
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        workoutItems: [],
      );
    }
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

  // Helper method to safely parse DateTime
  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue == null) return DateTime.now();

    try {
      if (dateValue is String) {
        return DateTime.parse(dateValue);
      } else if (dateValue is int) {
        return DateTime.fromMillisecondsSinceEpoch(dateValue);
      }
    } catch (e) {
      TalkerService.warning('Error parsing date', 'WORKOUT_SET', e);
    }

    return DateTime.now();
  }
}

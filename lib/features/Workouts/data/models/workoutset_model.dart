// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Exercises/data/models/exercise_model.dart';
import 'package:Warrior/features/Workouts/data/models/exercise_set_record_model.dart';
import 'package:hive_ce/hive.dart';

part 'workoutset_model.g.dart';

@HiveType(typeId: 4)
class WorkoutItemModel {
  @HiveField(0)
  final ExerciseModel exercise;

  @HiveField(1)
  final num lastWeight;

  @HiveField(2)
  final List<ExerciseSetRecordModel>? sets;

  @HiveField(3)
  final num? previousMaxWeight;

  @HiveField(4)
  final num? weightChange;

  WorkoutItemModel({
    required this.exercise,
    required this.lastWeight,
    this.sets,
    this.previousMaxWeight,
    this.weightChange,
  });

  factory WorkoutItemModel.fromMap(Map<String, dynamic> map) {
    try {
      // Safely parse exercise
      ExerciseModel exercise;
      final data = map.containsKey('exercise') ? map['exercise'] : map;
      if (data is Map<String, dynamic>) {
        exercise = ExerciseModel.fromMap(data);
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

      // Safely parse sets array
      List<ExerciseSetRecordModel>? sets;
      try {
        final setsData = map['sets'];
        if (setsData != null && setsData is List) {
          sets = [];
          for (var setItem in setsData) {
            try {
              if (setItem is Map<String, dynamic>) {
                sets.add(ExerciseSetRecordModel.fromMap(setItem));
              }
            } catch (e) {
              TalkerService.warning(
                  'Skipping invalid set record', 'WORKOUT_ITEM', e);
              continue;
            }
          }
        }
      } catch (e) {
        TalkerService.warning(
            'Error parsing sets, defaulting to null', 'WORKOUT_ITEM', e);
        sets = null;
      }

      // Safely parse previous_max_weight
      num? previousMaxWeight;
      try {
        if (map['previous_max_weight'] != null) {
          previousMaxWeight =
              double.tryParse(map['previous_max_weight'].toString());
        }
      } catch (e) {
        TalkerService.warning(
            'Error parsing previous_max_weight', 'WORKOUT_ITEM', e);
        previousMaxWeight = null;
      }

      // Safely parse weight_change
      num? weightChange;
      try {
        if (map['weight_change'] != null) {
          weightChange = double.tryParse(map['weight_change'].toString());
        }
      } catch (e) {
        TalkerService.warning('Error parsing weight_change', 'WORKOUT_ITEM', e);
        weightChange = null;
      }

      return WorkoutItemModel(
        exercise: exercise,
        lastWeight: lastWeight,
        sets: sets,
        previousMaxWeight: previousMaxWeight,
        weightChange: weightChange,
      );
    } catch (e) {
      TalkerService.error('Error parsing WorkoutItemModel', 'WORKOUT_ITEM', e);
      rethrow; // Re-throw to be caught by the parent parser
    }
  }

  WorkoutItemModel copyWith({
    ExerciseModel? exercise,
    num? lastWeight,
    List<ExerciseSetRecordModel>? sets,
    num? previousMaxWeight,
    num? weightChange,
  }) {
    return WorkoutItemModel(
      exercise: exercise ?? this.exercise,
      lastWeight: lastWeight ?? this.lastWeight,
      sets: sets ?? this.sets,
      previousMaxWeight: previousMaxWeight ?? this.previousMaxWeight,
      weightChange: weightChange ?? this.weightChange,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'exercise': exercise.toMap(),
      'last_weight': lastWeight,
    };

    if (sets != null) {
      map['sets'] = sets!.map((s) => s.toMap()).toList();
    }
    if (previousMaxWeight != null) {
      map['previous_max_weight'] = previousMaxWeight;
    }
    if (weightChange != null) {
      map['weight_change'] = weightChange;
    }

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
  @HiveField(6)
  final String? group;

  WorkoutSetModel({
    this.id,
    this.name,
    this.description,
    this.createdAt,
    this.updatedAt,
    this.workoutItems,
    this.group,
  });

  // factory WorkoutSetModel.fromJson(String source) =>
  //     WorkoutSetModel.fromMap(json.decode(source) as Map<String, dynamic>);

  factory WorkoutSetModel.fromMap(Map<String, dynamic> map) {
    try {
      // Safely parse workout items with better error handling
      List<WorkoutItemModel> workoutItems = [];
      final data = map.containsKey('workout_items')
          ? map['workout_items']
          : map['exercises'];
      if (data != null && data is List) {
        for (var item in data) {
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

      return WorkoutSetModel(
        id: map['id'] as int? ?? 0,
        name: map['name'] as String? ?? '',
        description: map['description'] as String? ?? '',
        createdAt: _parseDateTime(map['created_at']),
        updatedAt: _parseDateTime(map['updated_at']),
        workoutItems: workoutItems,
        group: map['group'] as String? ?? '',
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
    String? group,
    List<WorkoutItemModel>? workoutItems,
  }) {
    return WorkoutSetModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      group: group ?? this.group,
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

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    if (other is! WorkoutSetModel) return false;

    // If both have server IDs, compare by ID
    if (id != null && id! > 0 && other.id != null && other.id! > 0) {
      return id == other.id;
    }

    // For offline workouts (no ID), compare by name + createdAt
    return name == other.name && createdAt == other.createdAt;
  }

  @override
  int get hashCode {
    if (id != null && id! > 0) return id.hashCode;
    return Object.hash(name, createdAt);
  }
}

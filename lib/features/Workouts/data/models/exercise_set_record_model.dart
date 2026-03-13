// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:Warrior/core/services/talker_service.dart';
import 'package:hive_ce/hive.dart';

part 'exercise_set_record_model.g.dart';

/// Represents an individual set record within a workout exercise.
/// Contains the reps and weight for a single set.
@HiveType(typeId: 7)
class ExerciseSetRecordModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final int setNumber;

  @HiveField(2)
  final int reps;

  @HiveField(3)
  final num weight;

  const ExerciseSetRecordModel({
    required this.id,
    required this.setNumber,
    required this.reps,
    required this.weight,
  });

  factory ExerciseSetRecordModel.fromMap(Map<String, dynamic> map) {
    try {
      return ExerciseSetRecordModel(
        id: _parseInt(map['id'], 'id', defaultValue: 0),
        setNumber: _parseInt(map['set_number'], 'set_number', defaultValue: 1),
        reps: _parseInt(map['reps'], 'reps', defaultValue: 0),
        weight: _parseNum(map['weight'], 'weight', defaultValue: 0.0),
      );
    } catch (e) {
      TalkerService.error(
        'Error parsing ExerciseSetRecordModel',
        'EXERCISE_SET_RECORD',
        e,
      );
      rethrow;
    }
  }

  ExerciseSetRecordModel copyWith({
    int? id,
    int? setNumber,
    int? reps,
    num? weight,
  }) {
    return ExerciseSetRecordModel(
      id: id ?? this.id,
      setNumber: setNumber ?? this.setNumber,
      reps: reps ?? this.reps,
      weight: weight ?? this.weight,
    );
  }

  String toJson() => json.encode(toMap());

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'set_number': setNumber,
      'reps': reps,
      'weight': weight,
    };
  }

  /// Safely parse an integer value with defensive error handling.
  static int _parseInt(
    dynamic value,
    String fieldName, {
    required int defaultValue,
  }) {
    if (value == null) return defaultValue;

    try {
      if (value is int) return value;
      if (value is num) return value.toInt();
      if (value is String) {
        final parsed = int.tryParse(value);
        if (parsed != null) return parsed;
      }
    } catch (e) {
      TalkerService.warning(
        'Error parsing $fieldName, defaulting to $defaultValue',
        'EXERCISE_SET_RECORD',
        e,
      );
    }

    return defaultValue;
  }

  /// Safely parse a numeric value with defensive error handling.
  static num _parseNum(
    dynamic value,
    String fieldName, {
    required num defaultValue,
  }) {
    if (value == null) return defaultValue;

    try {
      if (value is num) return value;
      if (value is String) {
        final parsed = double.tryParse(value);
        if (parsed != null) return parsed;
      }
    } catch (e) {
      TalkerService.warning(
        'Error parsing $fieldName, defaulting to $defaultValue',
        'EXERCISE_SET_RECORD',
        e,
      );
    }

    return defaultValue;
  }
}

import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('WorkoutSetModel Tests', () {
    test('should parse valid workout set data', () {
      final validData = {
        'id': 1,
        'name': 'Test Workout',
        'description': 'A test workout',
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
        'workout_items': [
          {
            'exercise': {
              'id': 1,
              'name': 'Push-ups',
              'description': 'Basic push-up',
              'image': '',
              'video': '',
              'targetedMuscles': 'Chest',
              'muscle': 1,
              'muscle_name': 'Chest',
              'equipment_type': 'bodyweight',
            },
            'last_weight': '10.5',
          }
        ],
      };

      final workoutSet = WorkoutSetModel.fromMap(validData);

      expect(workoutSet.id, equals(1));
      expect(workoutSet.name, equals('Test Workout'));
      expect(workoutSet.description, equals('A test workout'));
      expect(workoutSet.workoutItems?.length, equals(1));
      expect(workoutSet.workoutItems?.first.lastWeight, equals(10.5));
    });

    test('should handle null workout_items gracefully', () {
      final dataWithNullItems = {
        'id': 1,
        'name': 'Test Workout',
        'description': 'A test workout',
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
        'workout_items': null,
      };

      final workoutSet = WorkoutSetModel.fromMap(dataWithNullItems);

      expect(workoutSet.id, equals(1));
      expect(workoutSet.name, equals('Test Workout'));
      expect(workoutSet.workoutItems, isEmpty);
    });

    test('should handle malformed workout_items gracefully', () {
      final dataWithMalformedItems = {
        'id': 1,
        'name': 'Test Workout',
        'description': 'A test workout',
        'created_at': '2023-01-01T00:00:00Z',
        'updated_at': '2023-01-01T00:00:00Z',
        'workout_items': [
          'invalid_item', // This should be skipped
          {
            'exercise': {
              'id': 1,
              'name': 'Push-ups',
              'description': 'Basic push-up',
              'image': '',
              'video': '',
              'targetedMuscles': 'Chest',
              'muscle': 1,
              'muscle_name': 'Chest',
              'equipment_type': 'bodyweight',
            },
            'last_weight': '10.5',
          },
          null, // This should be skipped
        ],
      };

      final workoutSet = WorkoutSetModel.fromMap(dataWithMalformedItems);

      expect(workoutSet.id, equals(1));
      expect(workoutSet.name, equals('Test Workout'));
      expect(workoutSet.workoutItems?.length, equals(1)); // Only valid item
    });

    test('should handle invalid date formats gracefully', () {
      final dataWithInvalidDates = {
        'id': 1,
        'name': 'Test Workout',
        'description': 'A test workout',
        'created_at': 'invalid_date',
        'updated_at': null,
        'workout_items': [],
      };

      final workoutSet = WorkoutSetModel.fromMap(dataWithInvalidDates);

      expect(workoutSet.id, equals(1));
      expect(workoutSet.name, equals('Test Workout'));
      expect(workoutSet.createdAt, isA<DateTime>());
      expect(workoutSet.updatedAt, isA<DateTime>());
    });

    test('should handle completely malformed data gracefully', () {
      final malformedData = {
        'invalid': 'data',
        'workout_items': 'not_a_list',
      };

      final workoutSet = WorkoutSetModel.fromMap(malformedData);

      expect(workoutSet.id, equals(0));
      expect(workoutSet.name, equals(''));
      expect(workoutSet.workoutItems, isEmpty);
      expect(workoutSet.createdAt, isA<DateTime>());
      expect(workoutSet.updatedAt, isA<DateTime>());
    });

    test('should handle missing required fields gracefully', () {
      final dataWithMissingFields = <String, dynamic>{};

      final workoutSet = WorkoutSetModel.fromMap(dataWithMissingFields);

      expect(workoutSet.id, equals(0));
      expect(workoutSet.name, equals(''));
      expect(workoutSet.description, equals(''));
      expect(workoutSet.workoutItems, isEmpty);
    });
  });

  group('WorkoutItemModel Tests', () {
    test('should parse valid workout item data', () {
      final validData = {
        'exercise': {
          'id': 1,
          'name': 'Push-ups',
          'description': 'Basic push-up',
          'image': '',
          'video': '',
          'targetedMuscles': 'Chest',
          'muscle': 1,
          'muscle_name': 'Chest',
          'equipment_type': 'bodyweight',
        },
        'last_weight': '15.5',
      };

      final workoutItem = WorkoutItemModel.fromMap(validData);

      expect(workoutItem.exercise.id, equals(1));
      expect(workoutItem.exercise.name, equals('Push-ups'));
      expect(workoutItem.lastWeight, equals(15.5));
    });

    test('should handle invalid last_weight gracefully', () {
      final dataWithInvalidWeight = {
        'exercise': {
          'id': 1,
          'name': 'Push-ups',
          'description': 'Basic push-up',
          'image': '',
          'video': '',
          'targetedMuscles': 'Chest',
          'muscle': 1,
          'muscle_name': 'Chest',
          'equipment_type': 'bodyweight',
        },
        'last_weight': 'invalid_weight',
      };

      final workoutItem = WorkoutItemModel.fromMap(dataWithInvalidWeight);

      expect(workoutItem.exercise.id, equals(1));
      expect(workoutItem.lastWeight, equals(0.0)); // Default value
    });

    test('should handle null last_weight gracefully', () {
      final dataWithNullWeight = {
        'exercise': {
          'id': 1,
          'name': 'Push-ups',
          'description': 'Basic push-up',
          'image': '',
          'video': '',
          'targetedMuscles': 'Chest',
          'muscle': 1,
          'muscle_name': 'Chest',
          'equipment_type': 'bodyweight',
        },
        'last_weight': null,
      };

      final workoutItem = WorkoutItemModel.fromMap(dataWithNullWeight);

      expect(workoutItem.exercise.id, equals(1));
      expect(workoutItem.lastWeight, equals(0.0)); // Default value
    });
  });
}

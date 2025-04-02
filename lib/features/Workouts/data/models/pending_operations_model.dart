import 'package:Warrior/features/Workouts/data/models/workoutset_model.dart';
import 'package:hive/hive.dart';

part 'pending_operations_model.g.dart';

@HiveType(typeId: 6)
enum SyncOperationType {
  @HiveField(0)
  create,

  @HiveField(1)
  update,

  @HiveField(2)
  delete
}

@HiveType(typeId: 5)
class PendingOperation extends HiveObject {
  @HiveField(0)
  final String entityType; // e.g., "workout", "workout_weight"

  @HiveField(1)
  final SyncOperationType operationType;

  @HiveField(2)
  final WorkoutSetModel? workout;

  @HiveField(3)
  final int? id;

  @HiveField(4)
  final int? exerciseId;

  @HiveField(5)
  final num? weight;

  @HiveField(6)
  final DateTime timestamp;

  PendingOperation({
    required this.entityType,
    required this.operationType,
    this.workout,
    this.id,
    this.exerciseId,
    this.weight,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

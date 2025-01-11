import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class WorkoutScreen extends ConsumerStatefulWidget {
  const WorkoutScreen({super.key});

  @override
  ConsumerState<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends ConsumerState<WorkoutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('WorkoutScreen'),
      ),
      body: Container(),
    );
  }

  @override
  void initState() {
    HiveManager.exercisesBox.clear();
    HiveManager.musclesBox.clear();
    super.initState();
  }
}

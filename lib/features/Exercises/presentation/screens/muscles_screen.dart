import 'package:Warrior/core/functions/save_to_hive.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/core/widgets/refresh_widget.dart';
import 'package:Warrior/features/Exercises/data/models/muscle_model.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscles_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

class MusclesScreen extends ConsumerStatefulWidget {
  const MusclesScreen({super.key});

  @override
  ConsumerState<MusclesScreen> createState() => _MusclesScreenState();
}

class _MusclesScreenState extends ConsumerState<MusclesScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Muscles',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontFamily: "Kings",
                  fontSize: 30)),
          centerTitle: true,
        ),
        body: ConnectivityChecker.isOnline!
            ? ref.watch(musclesProvider).when(
                loading: () => const Loader(),
                data: (muscles) {
                  saveToHive(HiveBoxes.musclesBox, muscles);
                  return MusclesListView(muscles: muscles);
                },
                error: (error, stackTrace) => RefreshWidget(musclesProvider))
            : ValueListenableBuilder(
                valueListenable: HiveBoxes.musclesBox.listenable(),
                builder: (context, Box<MuscleModel> box, _) {
                  if (box.values.isEmpty) {
                    return const Center(child: Text('No muscles found.'));
                  }

                  final muscles = box.values.toList();
                  return MusclesListView(muscles: muscles);
                },
              ));
  }

  @override
  void initState() {
    debugPrint('*************************************************');
    debugPrint("Exercise Objects => ${HiveBoxes.exercisesBox.length}");
    debugPrint("Muscles Objects => ${HiveBoxes.musclesBox.length}");
    debugPrint('*************************************************');
    super.initState();
  }
}

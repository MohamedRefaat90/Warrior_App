import 'package:Warrior/core/functions/save_to_hive.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/hive_boxes.dart';
import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscles_listview.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MusclesScreen extends ConsumerStatefulWidget {
  const MusclesScreen({super.key});

  @override
  ConsumerState<MusclesScreen> createState() => _MusclesScreenState();
}

class _MusclesScreenState extends ConsumerState<MusclesScreen> {
  @override
  Widget build(BuildContext context) {
    ref.watch(musclesProvider);
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
                error: (error, stackTrace) => Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: Card(
                          elevation: 3,
                          child: Padding(
                            padding: const EdgeInsets.all(10),
                            child: Text(error.toString()),
                          ),
                        ),
                      ),
                    ))
            : MusclesListView(muscles: HiveBoxes.musclesBox.values.toList()));
  }
}

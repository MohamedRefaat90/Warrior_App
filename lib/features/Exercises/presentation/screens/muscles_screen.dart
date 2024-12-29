import 'package:Warrior/core/widgets/loader.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:Warrior/features/Exercises/presentation/widgets/muscle_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        body: ref.watch(musclesProvider).when(
            loading: () => const Loader(),
            data: (muscles) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 5),
                  child: ListView.separated(
                      shrinkWrap: true,
                      itemBuilder: (context, index) =>
                          MuscleTile(muscle: muscles[index]),
                      separatorBuilder: (context, index) => 10.verticalSpace,
                      itemCount: muscles.length),
                ),
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
                )));
  }
}

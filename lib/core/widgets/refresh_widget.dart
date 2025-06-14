import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class RefreshWidget extends ConsumerWidget {
  final StateNotifierProvider provider;

  const RefreshWidget(this.provider, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        child: Card(
          elevation: 3,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(10),
                child: Text("Something went wrong!"),
              ),
              CustomBTN(
                  widget: const Text("Refresh"),
                  color: Colors.black,
                  padding: 10,
                  width: 70.w,
                  press: () => ref.refresh(musclesProvider))
            ],
          ),
        ),
      ),
    );
  }
}

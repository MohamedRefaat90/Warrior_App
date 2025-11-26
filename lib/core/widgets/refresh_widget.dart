import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Exercises/presentation/providers/muscle_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RefreshWidget extends ConsumerWidget {
  final NotifierProvider provider;

  const RefreshWidget(this.provider, {super.key});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: context.smallSpacing),
        child: Card(
          elevation: 3,
          child: Padding(
            padding: context.cardPadding,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "Something went wrong!",
                  style: Theme.of(context).textTheme.bodyLarge,
                ),
                SizedBox(height: context.smallSpacing),
                CustomBTN(
                    widget: const Text("Refresh"),
                    color: Colors.black,
                    padding: 10,
                    width: ResponsiveUtils.value<double>(
                      context,
                      mobile: 100,
                      tablet: 120,
                      desktop: 140,
                    ),
                    press: () => ref.refresh(musclesProvider))
              ],
            ),
          ),
        ),
      ),
    );
  }
}

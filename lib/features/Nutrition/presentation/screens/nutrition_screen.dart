import 'package:Warrior/core/widgets/native_ad_widget.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('nutritionScreen'.tr(context)),
      ),
      body: const Column(
        children: [
          NativeAdWidget(),
          Expanded(child: Center(child: Text('Coming Soon'))),
        ],
      ),
    );
  }
}

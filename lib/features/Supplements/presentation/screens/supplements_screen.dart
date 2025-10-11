import 'package:Warrior/core/widgets/native_ad_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SupplementsScreen extends ConsumerStatefulWidget {
  const SupplementsScreen({super.key});

  @override
  ConsumerState<SupplementsScreen> createState() => _SupplementsScreenState();
}

class _SupplementsScreenState extends ConsumerState<SupplementsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SupplementsScreen'),
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

import 'package:Warrior/features/FoodSearch/domain/entities/product_entity.dart';
import 'package:Warrior/features/FoodSearch/presentation/widgets/product_card.dart';
import 'package:flutter/material.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ProductCard(
            product: ProductEntity(
          barcode: "sssssssssssssssssssssssssss",
          lastUpdated: DateTime.now(),
        )),
      ),
    );
  }
}

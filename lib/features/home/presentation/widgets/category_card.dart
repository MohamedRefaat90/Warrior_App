import 'package:Warrior/features/Home/data/model/category_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  const CategoryCard({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.pushNamed(category.navigateTo),
      splashFactory: NoSplash.splashFactory,
      child: Card(
        elevation: 5,
        child: Padding(
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Image.asset(
                category.image,
                height: 100,
              ),
              Text(category.title,
                  style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins")),
            ],
          ),
        ),
      ),
    );
  }
}

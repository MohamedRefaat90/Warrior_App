import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/features/Home/data/models/category_item.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatelessWidget {
  final CategoryItem category;
  const CategoryCard({super.key, required this.category});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.pushNamed(category.navigateTo),
      child: Card(
        elevation: 10,
        shadowColor: AppColors.black.withAlpha(250),
        child: Padding(
          padding: context.cardPadding,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: Image.asset(
                      category.image,
                      width: constraints.maxWidth * 0.6,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: context.smallSpacing),
                  Text(
                    category.title,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          fontFamily: "poppins",
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/features/Home/data/models/category_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
          padding: const EdgeInsets.all(5.0),
          child: Column(
            children: [
              Image.asset(
                category.image,
                width: 90.w,
                height: category.title == "Food Search" ? 70.h : 70.h,
              ),
              7.verticalSpace,
              Text(category.title,
                  style: TextStyle(
                      fontSize: 12.sp,
                      fontWeight: FontWeight.bold,
                      fontFamily: "poppins")),
            ],
          ),
        ),
      ),
    );
  }
}

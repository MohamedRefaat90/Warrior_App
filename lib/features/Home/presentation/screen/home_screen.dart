import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/functions/checkAndShowReviewDialog.dart';
import 'package:Warrior/core/functions/checkForForceUpdate.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/Home/presentation/provider/home_provider.dart';
import 'package:Warrior/features/Home/presentation/widgets/category_card.dart';
import 'package:Warrior/features/Home/presentation/widgets/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            padding: EdgeInsets.only(left: 16.w),
            icon: Stack(
              alignment: Alignment.center,
              children: [
                Transform.rotate(
                  angle: -0.80,
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Transform.rotate(
                      angle: 0.80,
                      child: Icon(
                        Icons.menu,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: const FancyDrawer(),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // const BannerAdWidget(),
                const Spacer(),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: ref.read(homeProvider).categoryItems.length - 1,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CategoryCard(
                        category: ref.read(homeProvider).categoryItems[index]);
                  },
                ),
                SizedBox(height: 0.01.sh),
                SizedBox(
                  width: 175.w,
                  height: 120.h,
                  child: CategoryCard(
                      category: ref.read(homeProvider).categoryItems.last),
                ),
                const Spacer(),
                SizedBox(width: 1.sw, child: const BannerAdWidget()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ConnectivityChecker.isOnline ?? false) {
        checkAndShowReviewDialog(context);
        checkForForceUpdate(ref, context);
      }
    });
  }
}

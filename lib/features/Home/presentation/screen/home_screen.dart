import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/functions/checkAndShowReviewDialog.dart';
import 'package:Warrior/core/functions/checkForForceUpdate.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Home/presentation/provider/home_provider.dart';
import 'package:Warrior/features/Home/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'logout',
        onPressed: () async {
          await ref.read(loginProvider.notifier).logout();
          TalkerService.info('User logged out from home screen', 'HOME');
          if (context.mounted) {
            context.pushReplacementNamed(AppRouters.login);
          }
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.logout, color: AppColors.white),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const BannerAdWidget(),
                const Spacer(),
                GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: 2,
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CategoryCard(
                      category: ref.read(homeProvider).categoryItems[index],
                    );
                  },
                ),
                SizedBox(height: 0.01.sh),
                CategoryCard(
                  category: ref.read(homeProvider).categoryItems[2],
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

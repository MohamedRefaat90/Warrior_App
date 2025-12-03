import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/functions/checkAndShowReviewDialog.dart';
import 'package:Warrior/core/functions/checkForForceUpdate.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/utils/responsive_utils.dart';
import 'package:Warrior/core/widgets/banner_ad_widget.dart';
import 'package:Warrior/features/Home/presentation/provider/home_provider.dart';
import 'package:Warrior/features/Home/presentation/widgets/category_card.dart';
import 'package:Warrior/features/Home/presentation/widgets/fancy_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final String lang = ref.watch(appSettingsProvider).locale.languageCode;
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (context) => IconButton(
            padding: lang == 'ar'
                ? EdgeInsets.only(
                    right: ResponsiveUtils.horizontalPadding(context))
                : EdgeInsets.only(
                    left: ResponsiveUtils.horizontalPadding(context)),
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
                      child: Icon(Icons.menu, color: Colors.white, size: 22),
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
          padding: EdgeInsets.symmetric(
              horizontal: ResponsiveUtils.horizontalPadding(context)),
          child: Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: ResponsiveUtils.maxContentWidth,
              ),
              child: Column(
                children: [
                  const Spacer(),
                  GridView.builder(
                    shrinkWrap: true,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: ResponsiveUtils.getGridColumns(context),
                      mainAxisSpacing: 16,
                      crossAxisSpacing: 16,
                      childAspectRatio: 1.2,
                    ),
                    itemCount: ref.read(homeProvider).categoryItems.length - 1,
                    physics: const NeverScrollableScrollPhysics(),
                    itemBuilder: (context, index) {
                      return CategoryCard(
                          category:
                              ref.read(homeProvider).categoryItems[index]);
                    },
                  ),
                  SizedBox(height: context.screenHeight * 0.02),
                  SizedBox(
                      width: context.screenWidth * 0.44,
                      height: context.screenHeight * 0.167,
                      child: CategoryCard(
                          category: ref.read(homeProvider).categoryItems.last)),
                  const Spacer(),
                  const BannerAdWidget(),
                ],
              ),
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

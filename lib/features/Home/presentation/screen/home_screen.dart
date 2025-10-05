import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/storage_keys.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/shared_pref.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/widgets/custom_btn.dart';
import 'package:Warrior/features/Home/data/repo/home_repo.dart';
import 'package:Warrior/features/Home/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routers.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   ref.read(homeRepo);
    // });
    final numberOfWorkouts =
        SharedPref.getInt(StorageKeys.numberOfWorkouts) ?? 0;
    if (numberOfWorkouts == 2) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          content: Text(
              'Thank you for using Warrior! Would you like to rate the app?'),
          actions: [
            CustomBTN(
                widget: Text('Rate the app'),
                color: AppColors.black,
                padding: 12,
                width: double.infinity,
                press: () => AppServices.inAppReview.openStoreListing())
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        heroTag: 'logout',
        onPressed: () async {
          await SecureStorageHandler.delete(key: StorageKeys.token);
          TalkerService.info('User logged out from home screen', 'HOME');
          context.pushReplacementNamed(AppRouters.login);
        },
        backgroundColor: Colors.red,
        child: const Icon(Icons.logout, color: AppColors.white),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Consumer(
              builder: (context, ref, child) => GridView.builder(
                  shrinkWrap: true,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 10,
                    crossAxisSpacing: 10,
                    childAspectRatio: 1.2,
                  ),
                  itemCount: ref.read(homeRepo).length,
                  physics: NeverScrollableScrollPhysics(),
                  itemBuilder: (context, index) {
                    return CategoryCard(category: ref.read(homeRepo)[index]);
                  }),
            ),
          ],
        ),
      ),
    );
  }
}

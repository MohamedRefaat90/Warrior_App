import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/services/secure_storage_handler.dart';
import 'package:Warrior/features/Home/data/repo/home_repo.dart';
import 'package:Warrior/features/Home/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/routers.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      floatingActionButton: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FloatingActionButton(
            heroTag: 'logout',
            onPressed: () async {
              await SecureStorageHandler.delete(key: 'Token');
              context.goNamed(AppRouters.login);
              debugPrint('Logged out');
            },
            backgroundColor: Colors.red,
            child: const Icon(Icons.logout, color: AppColors.white),
          ),
          15.verticalSpace,
          FloatingActionButton(
            heroTag: 'clear',
            onPressed: () async {
              await SecureStorageHandler.storage.deleteAll();
              // context.goNamed(AppRouters.login);
              debugPrint('SecureStorage Cleared');
            },
            backgroundColor: Colors.black,
            child: const Icon(Icons.clear_all, color: AppColors.white),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            GridView.builder(
                shrinkWrap: true,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 10,
                  crossAxisSpacing: 10,
                  childAspectRatio: 1.2,
                ),
                itemCount: ref.read(homeRepo).length,
                itemBuilder: (context, index) => CategoryCard(
                      category: ref.read(homeRepo)[index],
                    )),
          ],
        ),
      ),
    );
  }
}

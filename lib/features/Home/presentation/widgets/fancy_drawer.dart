import 'dart:ui';

import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Home/presentation/widgets/fancy_drawer_item.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:go_router/go_router.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:share_plus/share_plus.dart';

class FancyDrawer extends ConsumerStatefulWidget {
  const FancyDrawer({super.key});

  @override
  ConsumerState<FancyDrawer> createState() => _FancyDrawerState();
}

class _FancyDrawerState extends ConsumerState<FancyDrawer> {
  String _version = 'Loading...';

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryColor!,
              AppColors.red!,
              AppColors.primaryColor!.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              SizedBox(height: 30.h),
              // Premium Logo Section with Glow Effect
              Stack(
                alignment: Alignment.center,
                children: [
                  // Glow effect
                  Container(
                    width: 180.w,
                    height: 180.w,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.white.withValues(alpha: 0.3),
                          blurRadius: 40,
                          spreadRadius: 20,
                        ),
                      ],
                    ),
                  ),
                  // Logo Container
                  Container(
                    width: 150.w,
                    height: 150.w,
                    padding: EdgeInsets.all(0.w),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.black.withValues(alpha: 0.2),
                          blurRadius: 20,
                          offset: const Offset(0, 10),
                        ),
                      ],
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/splash.png',
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Icon(
                            Icons.fitness_center,
                            size: 80.sp,
                            color: AppColors.primaryColor,
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10.h),
              // Animated Title
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    AppColors.white,
                    AppColors.white.withValues(alpha: 0.8),
                  ],
                ).createShader(bounds),
                child: Text(
                  'WARRIOR',
                  style: TextStyle(
                    fontSize: 32.sp,
                    fontWeight: FontWeight.w900,
                    fontFamily: "kings",
                    letterSpacing: 3,
                    color: AppColors.white,
                    shadows: [
                      Shadow(
                        color: AppColors.black.withValues(alpha: 0.3),
                        offset: const Offset(0, 3),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 8.h),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 6.h),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20.r),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  '💪 Unleash Your Power',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13.sp,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              SizedBox(height: 20.h),
              // Glass Menu Items
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 12.w),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30.r),
                    border: Border.all(
                      color: AppColors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.black.withValues(alpha: 0.1),
                        blurRadius: 20,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(30.r),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              AppColors.white.withValues(alpha: 0.2),
                              AppColors.white.withValues(alpha: 0.1),
                            ],
                          ),
                        ),
                        child: Column(
                          children: [
                            SizedBox(height: 15.h),
                            FancyDrawerItem(
                              icon: Icons.share_rounded,
                              title: 'Share App',
                              subtitle: 'Spread the warrior spirit',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.blue.shade400,
                                  Colors.purple.shade400,
                                ],
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await SharePlus.instance.share(ShareParams(
                                  text:
                                      'Check out the Warrior App for amazing workout routines! Download it here: https://play.google.com/store/apps/details?id=com.warrior90.app',
                                ));
                                TalkerService.info(
                                    'User shared the app', 'HOME');
                              },
                            ),
                            SizedBox(height: 16.h),
                            FancyDrawerItem(
                              icon: Icons.star_rounded,
                              title: 'Rate App',
                              subtitle: 'Support Us ⭐',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.amber.shade400,
                                  Colors.orange.shade300,
                                ],
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await AppServices.inAppReview
                                    .openStoreListing();
                                TalkerService.info(
                                    'User opened rate app', 'HOME');
                              },
                            ),
                            SizedBox(height: 16.h),
                            FancyDrawerItem(
                              icon: Icons.logout_rounded,
                              title: 'Logout',
                              subtitle: 'Take a rest warrior',
                              gradient: LinearGradient(
                                colors: [
                                  Colors.red.shade400,
                                  Colors.orange.shade400,
                                ],
                              ),
                              onTap: () async {
                                Navigator.pop(context);
                                await ref.read(loginProvider.notifier).logout();
                                TalkerService.info(
                                  'User logged out from home screen',
                                  'HOME',
                                );
                                if (context.mounted) {
                                  context
                                      .pushReplacementNamed(AppRouters.login);
                                }
                              },
                            ),
                            const Spacer(),
                            // Footer
                            Padding(
                              padding: EdgeInsets.only(bottom: 20.h),
                              child: Text(
                                _version,
                                style: TextStyle(
                                  color: AppColors.white.withValues(alpha: 0.6),
                                  fontSize: 11.sp,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(height: 10.h),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    _loadVersion();
  }

  Future<void> _loadVersion() async {
    final packageInfo = await PackageInfo.fromPlatform();
    setState(() {
      _version = 'Version ${packageInfo.version}';
    });
  }
}

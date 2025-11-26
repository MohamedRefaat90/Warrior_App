import 'package:Warrior/core/constants/colors.dart';
import 'package:Warrior/core/constants/routers.dart';
import 'package:Warrior/core/localization/translation_extension.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/features/Auth/presentation/provider/login_provider.dart';
import 'package:Warrior/features/Home/presentation/widgets/fancy_drawer_item.dart';
import 'package:Warrior/features/Home/presentation/widgets/logo_section.dart';
import 'package:Warrior/features/Home/presentation/widgets/settings_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
              AppColors.primaryColor,
              AppColors.red,
              AppColors.primaryColor.withValues(alpha: 0.7),
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // SizedBox(height: 30.h),
              // Premium Logo Section with Glow Effect
              LogoSection(),
              // SizedBox(height: 10.h),
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
                    fontSize: 32,
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
              // SizedBox(height: 8.h),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.white.withValues(alpha: 0.3),
                    width: 1.5,
                  ),
                ),
                child: Text(
                  context.l10n.unleashYourPower,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              const SizedBox(height: 10),
              // Settings Section - ExpansionTile
              SettingsSection(),
              const SizedBox(height: 8),
              // Glass Menu Items
              Flexible(
                fit: FlexFit.loose,
                flex: 3,
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: AppColors.white.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(30),
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
                    borderRadius: BorderRadius.circular(30),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.white.withValues(alpha: 0.25),
                            AppColors.white.withValues(alpha: 0.15),
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 10),
                          FancyDrawerItem(
                            icon: Icons.share_rounded,
                            title: context.l10n.shareApp,
                            subtitle: context.l10n.spreadTheWarriorSpirit,
                            gradient: LinearGradient(
                              colors: [
                                Colors.blue.shade400,
                                Colors.purple.shade400,
                              ],
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await SharePlus.instance.share(ShareParams(
                                text: context.l10n.shareAppMessage,
                              ));
                              TalkerService.info('User shared the app', 'HOME');
                            },
                          ),
                          const SizedBox(height: 8),
                          FancyDrawerItem(
                            icon: Icons.star_rounded,
                            title: context.l10n.rateApp,
                            subtitle: context.l10n.supportUs,
                            gradient: LinearGradient(
                              colors: [
                                Colors.amber.shade400,
                                Colors.orange.shade300,
                              ],
                            ),
                            onTap: () async {
                              Navigator.pop(context);
                              await AppServices.inAppReview.openStoreListing();
                              TalkerService.info(
                                  'User opened rate app', 'HOME');
                            },
                          ),
                          const SizedBox(height: 8),
                          FancyDrawerItem(
                            icon: Icons.logout_rounded,
                            title: context.l10n.logout,
                            subtitle: context.l10n.takeARest,
                            gradient: LinearGradient(
                              colors: [
                                Colors.red.shade400,
                                Colors.orange.shade400,
                              ],
                            ),
                            onTap: () {
                              Navigator.pop(context);
                              ref.read(loginProvider.notifier).logout();
                              TalkerService.info(
                                'User logged out from home screen',
                                'HOME',
                              );
                              if (context.mounted) {
                                context.pushReplacementNamed(AppRouters.login);
                              }
                            },
                          ),
                          // Footer
                          Padding(
                            padding: const EdgeInsets.only(top: 10, bottom: 5),
                            child: Text(
                              _version,
                              style: TextStyle(
                                color: AppColors.white.withValues(alpha: 0.6),
                                fontSize: 11,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
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
    if (mounted) {
      setState(() {
        _version = '${context.l10n.version} ${packageInfo.version}';
      });
    }
  }
}

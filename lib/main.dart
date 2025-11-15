import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/app_open_ad_manager.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/theme/app_theme.dart';
import 'package:Warrior/core/theme/theme_provider.dart';
import 'package:Warrior/routing.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:oktoast/oktoast.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:talker_riverpod_logger/talker_riverpod_logger_observer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app services
  await AppServices.init();

  // Initialize Open Food Facts API
  OpenFoodAPIConfiguration.userAgent =
      UserAgent(name: 'Warrior App', version: '1.1.0', system: 'Flutter');
  OpenFoodAPIConfiguration.globalLanguages = [
    OpenFoodFactsLanguage.ENGLISH,
    OpenFoodFactsLanguage.ARABIC,
  ];

  // Initialize Sentry and run app
  await SentryFlutter.init(
    (options) {
      options.dsn =
          'https://c6b8807846be7a792b6107aa37edd95c@o4510028648677376.ingest.de.sentry.io/4510028651888720';
      options.tracesSampleRate = kDebugMode ? 1.0 : 0.2;
      options.environment = kDebugMode ? 'development' : 'production';
    },
    appRunner: () => runApp(
      ProviderScope(
        observers: [
          TalkerRiverpodObserver(talker: TalkerService.instance),
        ],
        child: SentryWidget(
          child: kDebugMode
              ? DevicePreview(
                  enabled: true,
                  builder: (context) => const WarriorApp(),
                )
              : const WarriorApp(),
        ),
      ),
    ),
  );
}

// Set to true when you need to test different screen sizes
const bool _useDevicePreview = false;

/// Main app widget with Riverpod, Sentry integration, and lifecycle management
class WarriorApp extends ConsumerStatefulWidget {
  const WarriorApp({super.key});

  @override
  ConsumerState<WarriorApp> createState() => _WarriorAppState();
}

/// Sync status indicator widget
class _SyncIndicator extends ConsumerWidget {
  const _SyncIndicator();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isSync = ref.watch(syncServiceProvider);
    if (!isSync) return const SizedBox.shrink();

    return Container(
      width: 80.w,
      height: 25.h,
      alignment: Alignment.center,
      margin: EdgeInsets.only(bottom: 70.h),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(50),
        color: Colors.black87,
      ),
      child: Lottie.asset(
        AppAssets.loader,
        errorBuilder: (context, error, stackTrace) {
          TalkerService.warning(
            'Failed to load sync animation',
            'LOTTIE',
            error,
          );
          return const SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(
              color: Colors.white,
              strokeWidth: 2,
            ),
          );
        },
      ),
    );
  }
}

class _WarriorAppState extends ConsumerState<WarriorApp>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    // Initialize connectivity checker
    ConnectivityChecker.initialize(ref);

    // Watch theme mode from provider
    final themeMode = ref.watch(themeModeProvider);

    return ScreenUtilInit(
      designSize: const Size(360, 690),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, child) {
        return OKToast(
          child: Stack(
            alignment: Alignment.bottomCenter,
            children: [
              MaterialApp.router(
                title: 'Warrior',
                debugShowCheckedModeBanner: false,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                routerConfig: RoutersManager.router,
                // DevicePreview configuration
                locale:
                    _useDevicePreview ? DevicePreview.locale(context) : null,
                builder: _useDevicePreview ? DevicePreview.appBuilder : null,
              ),
              // Sync indicator overlay
              const _SyncIndicator(),
            ],
          ),
        );
      },
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Show app open ad when app resumes
    if (state == AppLifecycleState.resumed) {
      AppOpenAdManager.instance.showAdIfAvailable();
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _precacheAssets();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  /// Precache frequently used asset images for better performance
  Future<void> _precacheAssets() async {
    try {
      // Precache home screen category images
      await Future.wait([
        precacheImage(
          const AssetImage('assets/images/home/Aps.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/home/workout.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/home/Calculator.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/home/Supplements.png'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/home/nutrition.png'),
          context,
        ),
        // Precache onboarding images
        precacheImage(
          const AssetImage('assets/images/onboarding/1.webp'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/onboarding/2.webp'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/images/onboarding/3.webp'),
          context,
        ),
        precacheImage(
          const AssetImage('assets/splash.png'),
          context,
        ),
      ]);

      TalkerService.info('Assets precached successfully', 'PERFORMANCE');
    } catch (e) {
      TalkerService.warning('Failed to precache some assets', 'PERFORMANCE', e);
    }
  }
}

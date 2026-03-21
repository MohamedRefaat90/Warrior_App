import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/localization/arb/app_localizations.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/app_open_ad_manager.dart';
import 'package:Warrior/features/Home/presentation/provider/system_settings_provider.dart';
import 'package:Warrior/core/services/off_credentials_service.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/core/services/talker_service.dart';
import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:Warrior/core/theme/app_theme.dart';
import 'package:Warrior/routing.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lottie/lottie.dart';
import 'package:oktoast/oktoast.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize app services
  await AppServices.init();

  // Initialize Open Food Facts API
  OpenFoodAPIConfiguration.userAgent =
      UserAgent(name: 'Warrior App', version: '1.1.0', system: 'Flutter');

  // Load OFF credentials injected at build time via --dart-define-from-file
  const offUserId = String.fromEnvironment('OPENFOODFACTS_USER_ID');
  const offPassword = String.fromEnvironment('OPENFOODFACTS_PASSWORD');
  if (offUserId.isNotEmpty && offPassword.isNotEmpty) {
    OpenFoodFactsCredentialsService.saveCredentials(
        userId: offUserId, password: offPassword);
  }

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
          // TalkerRiverpodObserver(talker: TalkerService.instance),
        ],
        child: SentryWidget(
          child: kDebugMode
              ? DevicePreview(
                  enabled: false,
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
    final syncState = ref.watch(syncServiceProvider);
    if (!syncState.isLoading) return const SizedBox.shrink();

    return Container(
      width: 80,
      height: 25,
      alignment: Alignment.center,
      margin: const EdgeInsets.only(bottom: 70),
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
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Initialize connectivity checker once
    ConnectivityChecker.initialize(ref);
  }

  @override
  Widget build(BuildContext context) {
    // Watch app settings from provider
    final appSettings = ref.watch(appSettingsProvider);

    return OKToast(
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          MaterialApp.router(
            title: 'Warrior',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: appSettings.themeMode,
            locale: _useDevicePreview
                ? DevicePreview.locale(context)
                : appSettings.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('ar'),
            ],
            routerConfig: RoutersManager.router,
            // routerConfig: GoRouter(
            //   routes: [
            //     GoRoute(
            //       path: '/',
            //       builder: (context, state) => const TestScreen(),
            //     ),
            //   ],
            // ),
            // DevicePreview configuration
            builder: _useDevicePreview ? DevicePreview.appBuilder : null,
          ),
          // Sync indicator overlay
          const _SyncIndicator(),
        ],
      ),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Show app open ad when app resumes — respects the showAds flag
    if (state == AppLifecycleState.resumed) {
      final showAds = ref.read(systemSettingsProvider).showAds;
      AppOpenAdManager.instance.showAdIfAvailable(showAds: showAds);
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

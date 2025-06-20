import 'package:Warrior/core/constants/assets.dart';
import 'package:Warrior/core/network/connectivity.dart';
import 'package:Warrior/core/services/logger.dart';
import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/core/services/sync.dart';
import 'package:Warrior/routing.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:lottie/lottie.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  // Ensure Flutter is properly initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize logger first
  AppLogger.init();

  // Wrap main initialization in error handling
  try {
    // await dotenv.load();
    await AppServices.init();

    AppLogger.info('App initialization completed successfully');

    // Only use DevicePreview in debug mode
    if (kDebugMode) {
      runApp(DevicePreview(
        enabled: true,
        builder: (context) => const AppWrapper(),
      ));
    } else {
      runApp(const AppWrapper());
    }
  } catch (error, stackTrace) {
    AppLogger.error('Failed to initialize app', 'MAIN', error, stackTrace);

    // Fallback app for initialization failures
    runApp(MaterialApp(
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Failed to start app',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text(
                kDebugMode ? error.toString() : 'Please restart the app',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    ));
  }
}

class AppWrapper extends StatelessWidget {
  const AppWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: ErrorBoundary(
        child: const Warrior(),
        onError: (error, stackTrace) {
          AppLogger.error('Widget error boundary triggered', 'ERROR_BOUNDARY',
              error, stackTrace);
        },
      ),
    );
  }
}

class ErrorBoundary extends StatefulWidget {
  final Widget child;
  final void Function(Object error, StackTrace stackTrace)? onError;

  const ErrorBoundary({
    super.key,
    required this.child,
    this.onError,
  });

  @override
  State<ErrorBoundary> createState() => _ErrorBoundaryState();
}

class Warrior extends ConsumerWidget {
  const Warrior({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      ConnectivityChecker.initialize(ref);

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
                  theme: ThemeData(
                    colorScheme: ColorScheme.fromSeed(
                      seedColor: const Color.fromARGB(255, 168, 11, 11),
                    ),
                    useMaterial3: true,
                  ),
                  routerConfig: RoutersManager.router,
                  // Add locale configuration for production
                  locale: DevicePreview.locale(context),
                  builder: DevicePreview.appBuilder,
                ),
                // Show sync indicator safely
                Consumer(
                  builder: (context, ref, child) {
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
                          AppLogger.warning(
                              'Failed to load sync animation', 'LOTTIE', error);
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
                  },
                ),
              ],
            ),
          );
        },
      );
    } catch (error, stackTrace) {
      AppLogger.error(
          'Error in Warrior widget build', 'WARRIOR', error, stackTrace);

      // Return a minimal error UI
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.warning, size: 48, color: Colors.orange),
                const SizedBox(height: 16),
                const Text('App Error'),
                if (kDebugMode) ...[
                  const SizedBox(height: 8),
                  Text(error.toString())
                ],
              ],
            ),
          ),
        ),
      );
    }
  }
}

class _ErrorBoundaryState extends State<ErrorBoundary> {
  Object? _error;
  StackTrace? _stackTrace;

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.white,
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 64,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Something went wrong',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    !kDebugMode
                        ? _error.toString()
                        : 'An unexpected error occurred. Please restart the app.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        // _error = null;
                        // _stackTrace = null;
                        AppLogger.error('Error Boundary', 'ERROR_BOUNDARY',
                            _error, _stackTrace);
                      });
                    },
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return widget.child;
  }

  @override
  void initState() {
    super.initState();
    FlutterError.onError = (details) {
      setState(() {
        _error = details.exception;
        _stackTrace = details.stack;
      });
      widget.onError
          ?.call(details.exception, details.stack ?? StackTrace.current);
    };
  }
}

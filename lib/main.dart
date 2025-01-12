import 'package:Warrior/core/services/services.dart';
import 'package:Warrior/routing.dart';
import 'package:device_preview/device_preview.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await AppServices.init();

  runApp(DevicePreview(
      enabled: !kReleaseMode,
      builder: (context) {
        return const ProviderScope(child: Warrior());
      }));
}

class Warrior extends StatelessWidget {
  const Warrior({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
        designSize: const Size(360, 690),
        minTextAdapt: true,
        splitScreenMode: true,
        builder: (_, child) {
          return MaterialApp.router(
            title: 'Warrior',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                  seedColor: const Color.fromARGB(255, 168, 11, 11)),
              useMaterial3: true,
            ),
            routerConfig: RoutersManager.router,
          );
        });
  }
}

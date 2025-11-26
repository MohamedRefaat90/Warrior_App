import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Animated language toggle switcher for EN/AR
/// Features smooth transitions and visual feedback for current language
class LanguageToggleSwitcher extends ConsumerWidget {
  const LanguageToggleSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(appSettingsProvider.select((s) => s.locale));
    final isArabic = locale.languageCode == 'ar';

    return GestureDetector(
      onTap: () {
        final newLocale = isArabic ? const Locale('en') : const Locale('ar');
        ref.read(appSettingsProvider.notifier).setLanguage(newLocale);
      },
      child: Container(
        width: 70,
        height: 35,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          gradient: LinearGradient(
            colors: isArabic
                ? [
                    const Color(0xFF059669),
                    const Color(0xFF10B981),
                  ]
                : [
                    const Color(0xFF7C3AED),
                    const Color(0xFF9333EA),
                  ],
          ),
          boxShadow: [
            BoxShadow(
              color: isArabic
                  ? Colors.green.withValues(alpha: 0.3)
                  : Colors.purple.withValues(alpha: 0.3),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: Stack(
          children: [
            // Animated circle
            AnimatedAlign(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
              alignment:
                  isArabic ? Alignment.centerRight : Alignment.centerLeft,
              child: Container(
                width: 28,
                height: 28,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder: (child, animation) {
                      return FadeTransition(
                        opacity: animation,
                        child: ScaleTransition(
                          scale: animation,
                          child: child,
                        ),
                      );
                    },
                    child: Text(
                      isArabic ? 'ع' : 'EN',
                      key: ValueKey(isArabic),
                      style: TextStyle(
                        color: isArabic
                            ? const Color(0xFF10B981)
                            : const Color(0xFF9333EA),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

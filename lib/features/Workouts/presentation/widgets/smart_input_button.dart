import 'package:Warrior/core/settings/app_settings_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class SmartInputButton extends ConsumerWidget {
  final String label;
  final String value;
  final VoidCallback onTap;
  final Color? color;
  final bool isDark;

  const SmartInputButton({
    super.key,
    required this.label,
    required this.value,
    required this.onTap,
    this.color,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appSettings = ref.watch(appSettingsProvider.notifier);
    final primaryColor = color ?? Theme.of(context).primaryColor;
    final backgroundColor =
        isDark ? primaryColor.withOpacity(0.15) : primaryColor.withOpacity(0.1);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: primaryColor.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              label,
              style: TextStyle(
                fontFamily: appSettings.fontFamily(),
                fontSize: 11,
                fontWeight: FontWeight.w500,
                color: isDark ? Colors.white70 : Colors.black54,
              ),
            ),
            const SizedBox(height: 2),
            Text(value,
                style: const TextStyle(
                  fontFamily: "Poppins",
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  height: 1.2,
                ) // Can't easily use custom color here without context, defaults are fine
                ),
          ],
        ),
      ),
    );
  }
}

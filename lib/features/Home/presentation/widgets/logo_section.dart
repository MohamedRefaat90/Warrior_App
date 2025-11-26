import 'package:Warrior/core/constants/colors.dart';
import 'package:flutter/material.dart';

class LogoSection extends StatelessWidget {
  const LogoSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Glow effect
        Container(
          width: 170,
          height: 170,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppColors.white.withValues(alpha: 0.3),
                blurRadius: 25,
                spreadRadius: 10,
              ),
            ],
          ),
        ),
        // Logo Container
        Container(
          width: 150,
          height: 150,
          padding: const EdgeInsets.all(0),
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
                  size: 80,
                  color: AppColors.primaryColor,
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}

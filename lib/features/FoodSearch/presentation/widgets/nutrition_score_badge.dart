import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

Color getScoreColor(String score) {
  switch (score) {
    case 'A':
      return const Color(0xFF038141); // Dark Green
    case 'B':
      return const Color(0xFF85BB2F); // Light Green
    case 'C':
      return const Color(0xFFFECC02); // Yellow
    case 'D':
      return const Color(0xFFEE8100); // Orange
    case 'E':
      return const Color(0xFFE63E11); // Red
    default:
      return Colors.grey;
  }
}

/// Badge widget for displaying Nutri-Score (A-E)
/// Color-coded from dark green (A) to red (E)
class NutritionScoreBadge extends StatelessWidget {
  final String? nutriScore;
  final double size;
  final bool animated;

  const NutritionScoreBadge(
      {super.key,
      required this.nutriScore,
      this.size = 40,
      this.animated = true});

  @override
  Widget build(BuildContext context) {
    if (nutriScore == null || nutriScore!.isEmpty) {
      return SizedBox(width: size, height: size);
    }

    final score = nutriScore! != 'UNKNOWN' && nutriScore! != 'NOT-APPLICABLE'
        ? nutriScore!.toUpperCase()
        : 'N/A';
    final color = getScoreColor(score);

    Widget badge = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          score,
          style: TextStyle(
            color: Colors.white,
            fontSize: score == "N/A" ? 10 : 15,
            fontWeight: FontWeight.bold,
            fontFamily: 'Poppins',
          ),
        ),
      ),
    );

    if (animated) {
      badge = badge.animate().scale(
            duration: 300.ms,
            curve: Curves.easeOutBack,
          );
    }

    return badge;
  }
}

/// Shield-style Nutri-Score badge
class NutritionScoreShield extends StatelessWidget {
  final String? nutriScore;
  final double width;
  final double height;

  const NutritionScoreShield({
    super.key,
    required this.nutriScore,
    this.width = 60,
    this.height = 80,
  });

  @override
  Widget build(BuildContext context) {
    if (nutriScore == null || nutriScore!.isEmpty) {
      return SizedBox(width: width, height: height);
    }

    final score = nutriScore! != 'UNKNOWN' && nutriScore! != 'NOT-APPLICABLE'
        ? nutriScore!.toUpperCase()
        : 'N/A';
    final color = getScoreColor(score);

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'NUTRI',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          Text(
            'SCORE',
            style: TextStyle(
              color: Colors.white,
              fontSize: width * 0.15,
              fontWeight: FontWeight.w600,
              fontFamily: 'Poppins',
            ),
          ),
          const SizedBox(height: 4),
          Container(
            width: width * 0.6,
            height: width * 0.6,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                score,
                style: TextStyle(
                  color: color,
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Poppins',
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

/// Pie chart widget for macronutrient visualization
class MacroPieChart extends StatefulWidget {
  final double proteinPercent;
  final double carbsPercent;
  final double fatsPercent;
  final double proteinGrams;
  final double carbsGrams;
  final double fatsGrams;

  const MacroPieChart({
    super.key,
    required this.proteinPercent,
    required this.carbsPercent,
    required this.fatsPercent,
    required this.proteinGrams,
    required this.carbsGrams,
    required this.fatsGrams,
  });

  @override
  State<MacroPieChart> createState() => _MacroPieChartState();
}

class _MacroPieChartState extends State<MacroPieChart> {
  int touchedIndex = -1;

  @override
  Widget build(BuildContext context) {
    return PieChart(
      PieChartData(
        pieTouchData: PieTouchData(
          touchCallback: (FlTouchEvent event, pieTouchResponse) {
            setState(() {
              if (!event.isInterestedForInteractions ||
                  pieTouchResponse == null ||
                  pieTouchResponse.touchedSection == null) {
                touchedIndex = -1;
                return;
              }
              touchedIndex =
                  pieTouchResponse.touchedSection!.touchedSectionIndex;
            });
          },
        ),
        borderData: FlBorderData(show: false),
        sectionsSpace: 2,
        centerSpaceRadius: 60.r,
        sections: [
          // Protein section
          PieChartSectionData(
            color: Colors.blue,
            value: widget.proteinPercent,
            title: '${widget.proteinPercent.toStringAsFixed(0)}%',
            radius: touchedIndex == 0 ? 110.r : 100.r,
            titleStyle: TextStyle(
              fontSize: touchedIndex == 0 ? 18.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                ),
              ],
            ),
            badgeWidget: touchedIndex == 0
                ? _buildBadge(
                    'Protein\n${widget.proteinGrams.toStringAsFixed(0)}g',
                    Colors.blue)
                : null,
            badgePositionPercentageOffset: 1.3,
          ),
          // Carbs section
          PieChartSectionData(
            color: Colors.green,
            value: widget.carbsPercent,
            title: '${widget.carbsPercent.toStringAsFixed(0)}%',
            radius: touchedIndex == 1 ? 110.r : 100.r,
            titleStyle: TextStyle(
              fontSize: touchedIndex == 1 ? 18.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                ),
              ],
            ),
            badgeWidget: touchedIndex == 1
                ? _buildBadge('Carbs\n${widget.carbsGrams.toStringAsFixed(0)}g',
                    Colors.green)
                : null,
            badgePositionPercentageOffset: 1.3,
          ),
          // Fats section
          PieChartSectionData(
            color: Colors.orange,
            value: widget.fatsPercent,
            title: '${widget.fatsPercent.toStringAsFixed(0)}%',
            radius: touchedIndex == 2 ? 110.r : 100.r,
            titleStyle: TextStyle(
              fontSize: touchedIndex == 2 ? 18.sp : 16.sp,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              shadows: [
                const Shadow(
                  color: Colors.black26,
                  blurRadius: 2,
                ),
              ],
            ),
            badgeWidget: touchedIndex == 2
                ? _buildBadge('Fats\n${widget.fatsGrams.toStringAsFixed(0)}g',
                    Colors.orange)
                : null,
            badgePositionPercentageOffset: 1.3,
          ),
        ],
      ),
      swapAnimationDuration: const Duration(milliseconds: 750),
      swapAnimationCurve: Curves.easeInOutCubic,
    );
  }

  Widget _buildBadge(String text, Color color) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.r),
        boxShadow: [
          BoxShadow(
            color: color.withValues(alpha: 0.4),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 12.sp,
          fontWeight: FontWeight.bold,
          color: Colors.white,
          height: 1.2,
        ),
      ),
    );
  }
}

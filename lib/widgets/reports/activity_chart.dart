import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../common/glass_card.dart';

class ActivityChart extends StatelessWidget {
  const ActivityChart({super.key});

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.5,
      child: GlassCard(
        padding: const EdgeInsets.all(24),
        child: BarChart(
          BarChartData(
            gridData: FlGridData(show: false),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  getTitlesWidget: (double value, TitleMeta meta) {
                    const style = TextStyle(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    );
                    switch (value.toInt()) {
                      case 0: return const Text('M', style: style);
                      case 1: return const Text('T', style: style);
                      case 2: return const Text('W', style: style);
                      case 3: return const Text('T', style: style);
                      case 4: return const Text('F', style: style);
                      case 5: return const Text('S', style: style);
                      case 6: return const Text('S', style: style);
                      default: return const Text('', style: style);
                    }
                  },
                ),
              ),
            ),
            borderData: FlBorderData(show: false),
            barGroups: [
               makeGroupData(0, 8, 4),
               makeGroupData(1, 10, 6),
               makeGroupData(2, 14, 8),
               makeGroupData(3, 15, 7),
               makeGroupData(4, 13, 9),
               makeGroupData(5, 10, 5),
               makeGroupData(6, 16, 10),
            ],
          ),
        ),
      ),
    );
  }
  
  BarChartGroupData makeGroupData(int x, double y1, double y2) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y1,
          color: AppColors.primaryBlue,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
        BarChartRodData(
          toY: y2,
          color: AppColors.softBlue,
          width: 8,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}

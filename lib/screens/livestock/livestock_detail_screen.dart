import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/livestock.dart';
import '../../widgets/common/radial_background.dart';
import '../../widgets/common/glass_card.dart';
import 'package:fl_chart/fl_chart.dart';

class LivestockDetailScreen extends StatelessWidget {
  final Livestock livestock;

  const LivestockDetailScreen({super.key, required this.livestock});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: Text(livestock.name, style: const TextStyle(color: AppColors.deepBlue)),
          leading: const BackButton(color: AppColors.deepBlue),
          actions: [
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryBlue),
              onPressed: () {},
            ),
          ],
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              GlassCard(
                padding: const EdgeInsets.all(24),
                child: Column(
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: AppColors.softBlue,
                      child: Icon(Icons.pets, size: 40, color: AppColors.primaryBlue),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      livestock.tagId,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBlue,
                          ),
                    ),
                    Text(
                      livestock.species,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStatItem('Status', livestock.status),
                        _buildStatItem('Battery', '85%'),
                        _buildStatItem('Last Sync', '2m ago'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Activity History',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
              ),
              const SizedBox(height: 8),

              // Activity Chart
              SizedBox(
                height: 200,
                child: GlassCard(
                  padding: const EdgeInsets.only(right: 16, left: 0, top: 24, bottom: 12),
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(show: false),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            getTitlesWidget: (value, meta) {
                              switch (value.toInt()) {
                                case 0: return const Text('Mon');
                                case 2: return const Text('Wed');
                                case 4: return const Text('Fri');
                                case 6: return const Text('Sun');
                              }
                              return const Text('');
                            },
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      minX: 0,
                      maxX: 6,
                      minY: 0,
                      maxY: 100,
                      lineBarsData: [
                        LineChartBarData(
                          spots: [
                            const FlSpot(0, 40),
                            const FlSpot(1, 65),
                            const FlSpot(2, 55),
                            const FlSpot(3, 80),
                            const FlSpot(4, 75),
                            const FlSpot(5, 88),
                            const FlSpot(6, 45),
                          ],
                          isCurved: true,
                          color: AppColors.primaryBlue,
                          barWidth: 4,
                          isStrokeCapRound: true,
                          dotData: FlDotData(show: false),
                          belowBarData: BarAreaData(
                            show: true,
                            color: AppColors.primaryBlue.withOpacity(0.2),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Map Placeholder
              Text(
                 'Current Location',
                 style: Theme.of(context).textTheme.titleMedium?.copyWith(
                       fontWeight: FontWeight.bold,
                       color: AppColors.deepBlue,
                     ),
              ),
              const SizedBox(height: 8),
              Container(
                height: 200,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.grey[300],
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.map, size: 40, color: Colors.grey),
                      Text('Map View Placeholder', style: TextStyle(color: Colors.grey[600])),
                      Text('Lat: ${livestock.latitude}, Lng: ${livestock.longitude}', style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: AppColors.deepBlue,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

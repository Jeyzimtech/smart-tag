import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class HerdConfigurationScreen extends StatelessWidget {
  const HerdConfigurationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Herd Configuration', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildHerdCard('Herd A', 120, 'North Pasture'),
            _buildHerdCard('Herd B', 95, 'South Field'),
            _buildHerdCard('Herd C', 80, 'East Grazing Area'),
            _buildHerdCard('Herd D', 55, 'West Paddock'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildHerdCard(String name, int count, String location) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: AppColors.primaryBlue.withOpacity(0.2),
            child: const Icon(Icons.group, color: AppColors.primaryBlue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text('$count animals \u2022 $location', style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          IconButton(icon: const Icon(Icons.edit), onPressed: () {}),
        ],
      ),
    );
  }
}

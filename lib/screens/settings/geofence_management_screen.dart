import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class GeofenceManagementScreen extends StatelessWidget {
  const GeofenceManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Geofence Management', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildGeofenceCard('North Pasture', '40.7150, -74.0080', true),
            _buildGeofenceCard('South Field', '40.7100, -74.0040', true),
            _buildGeofenceCard('East Grazing Area', '40.7120, -74.0020', false),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () {},
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildGeofenceCard(String name, String coords, bool active) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(Icons.fence, color: active ? Colors.green : Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text(coords, style: const TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Switch(value: active, onChanged: (v) {}),
        ],
      ),
    );
  }
}

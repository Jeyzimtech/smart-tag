import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class SyncDataScreen extends StatelessWidget {
  const SyncDataScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Sync Data', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    _buildSyncItem('Livestock Data', 'Last synced: 2 mins ago', Icons.pets),
                    const Divider(),
                    _buildSyncItem('GPS Locations', 'Last synced: 5 mins ago', Icons.location_on),
                    const Divider(),
                    _buildSyncItem('Sensor Readings', 'Last synced: 1 min ago', Icons.sensors),
                    const Divider(),
                    _buildSyncItem('Alerts & Notifications', 'Last synced: 3 mins ago', Icons.notifications),
                    const SizedBox(height: 24),
                    ElevatedButton.icon(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Syncing data...')));
                      },
                      icon: const Icon(Icons.sync),
                      label: const Text('Sync All Data'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSyncItem(String title, String subtitle, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      trailing: const Icon(Icons.check_circle, color: Colors.green),
    );
  }
}

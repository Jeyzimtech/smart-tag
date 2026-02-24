import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/radial_background.dart';
import '../services/database_helper.dart';
import 'settings/profile_screen.dart';
import 'settings/change_password_screen.dart';
import 'settings/farm_details_screen.dart';
import 'settings/geofence_management_screen.dart';
import 'settings/herd_configuration_screen.dart';
import 'settings/sync_data_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Settings', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildSection('Account', [
              _buildSettingItem(context, Icons.person, 'Profile', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
              }),
              _buildSettingItem(context, Icons.lock, 'Change Password', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen()));
              }),
              _buildSettingItem(context, Icons.email, 'Email Preferences', () {}),
            ]),
            _buildSection('Farm Settings', [
              _buildSettingItem(context, Icons.agriculture, 'Farm Details', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const FarmDetailsScreen()));
              }),
              _buildSettingItem(context, Icons.fence, 'Geofence Management', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const GeofenceManagementScreen()));
              }),
              _buildSettingItem(context, Icons.group, 'Herd Configuration', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const HerdConfigurationScreen()));
              }),
            ]),
            _buildSection('Notifications', [
              _buildSwitchItem(Icons.notifications, 'Push Notifications', true, (v) {}),
              _buildSwitchItem(Icons.email, 'Email Alerts', true, (v) {}),
              _buildSwitchItem(Icons.sms, 'SMS Alerts', false, (v) {}),
            ]),
            _buildSection('IoT Devices', [
              _buildSettingItem(context, Icons.bluetooth, 'Connected Tags', () {}),
              _buildSettingItem(context, Icons.wifi, 'Network Settings', () {}),
              _buildSettingItem(context, Icons.sync, 'Sync Data', () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const SyncDataScreen()));
              }),
              _buildSettingItem(context, Icons.delete_forever, 'Clear All Data', () async {
                final confirm = await showDialog<bool>(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Clear All Data'),
                    content: const Text('This will delete all livestock records. Continue?'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
                      ElevatedButton(
                        onPressed: () => Navigator.pop(ctx, true),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                        child: const Text('Clear'),
                      ),
                    ],
                  ),
                );
                if (confirm == true) {
                  await DatabaseHelper.instance.clearAllData();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All data cleared')),
                    );
                  }
                }
              }),
            ]),
            _buildSection('About', [
              _buildSettingItem(context, Icons.info, 'App Version', () {}),
              _buildSettingItem(context, Icons.privacy_tip, 'Privacy Policy', () {}),
              _buildSettingItem(context, Icons.description, 'Terms of Service', () {}),
            ]),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Logout'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.deepBlue)),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.7),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(children: items),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildSettingItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16),
      onTap: onTap,
    );
  }

  Widget _buildSwitchItem(IconData icon, String title, bool value, Function(bool) onChanged) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryBlue),
      title: Text(title),
      trailing: Switch(value: value, onChanged: onChanged),
    );
  }
}
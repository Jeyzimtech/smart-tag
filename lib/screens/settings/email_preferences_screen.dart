import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class EmailPreferencesScreen extends StatelessWidget {
  const EmailPreferencesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Email Preferences', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const Text('Configure your email notification preferences', style: TextStyle(fontSize: 16)),
            const SizedBox(height: 20),
            _buildInfoCard('Coming Soon', 'Email preference configuration will be available in the next update.'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String message) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text(message),
          ],
        ),
      ),
    );
  }
}

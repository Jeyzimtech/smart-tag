import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Alerts', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(height: 100),
                  Icon(Icons.notifications_none, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                  const SizedBox(height: 16),
                  Text(
                    'No alerts yet',
                    style: TextStyle(fontSize: 18, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

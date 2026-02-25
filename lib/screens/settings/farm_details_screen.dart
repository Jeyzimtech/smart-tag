import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class FarmDetailsScreen extends StatelessWidget {
  const FarmDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Farm Details', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                TextFormField(
                  initialValue: 'Green Valley Farm',
                  decoration: const InputDecoration(labelText: 'Farm Name', prefixIcon: Icon(Icons.agriculture)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: '1234 Farm Road, County',
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: '500 acres',
                  decoration: const InputDecoration(labelText: 'Farm Size', prefixIcon: Icon(Icons.landscape)),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  initialValue: 'John Doe',
                  decoration: const InputDecoration(labelText: 'Owner Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Farm details saved')));
                  },
                  child: const Text('Save Changes'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

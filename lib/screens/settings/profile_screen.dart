import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Profile', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              CircleAvatar(
                radius: 50,
                backgroundColor: AppColors.primaryBlue,
                child: const Icon(Icons.person, size: 50, color: Colors.white),
              ),
              const SizedBox(height: 16),
              const Text('John Doe', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              const Text('Farm Manager', style: TextStyle(color: AppColors.textSecondary)),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    TextFormField(
                      initialValue: 'John Doe',
                      decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'john.doe@farm.com',
                      decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: '+1 234 567 8900',
                      decoration: const InputDecoration(labelText: 'Phone', prefixIcon: Icon(Icons.phone)),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      initialValue: 'Farm Manager',
                      decoration: const InputDecoration(labelText: 'Role', prefixIcon: Icon(Icons.work)),
                    ),
                    const SizedBox(height: 24),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile updated')));
                      },
                      child: const Text('Save Changes'),
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
}

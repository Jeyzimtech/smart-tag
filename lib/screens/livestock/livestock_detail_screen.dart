import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/livestock.dart';
import '../../widgets/common/radial_background.dart';
import '../../widgets/common/glass_card.dart';

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
          title: Text('Tag: ${livestock.tagId}', style: const TextStyle(color: AppColors.deepBlue)),
          leading: const BackButton(color: AppColors.deepBlue),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                        _buildStatItem('Breed', livestock.breed),
                        _buildStatItem('Herd', livestock.herd),
                        _buildStatItem('Status', livestock.status.toUpperCase()),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              
              Text(
                'Livestock Information',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: AppColors.deepBlue,
                    ),
              ),
              const SizedBox(height: 8),
              
              GlassCard(
                child: Column(
                  children: [
                    _buildInfoRow('Tag ID', livestock.tagId),
                    _buildInfoRow('Species', livestock.species),
                    _buildInfoRow('Breed', livestock.breed),
                    _buildInfoRow('Herd', livestock.herd),
                    _buildInfoRow('Status', livestock.status.toUpperCase()),
                    _buildInfoRow('Registered', livestock.dateRegistered.toString().split(' ')[0]),
                    if (livestock.temperature != null)
                      _buildInfoRow('Temperature', '${livestock.temperature}°C'),
                    if (livestock.activityLevel != null)
                      _buildInfoRow('Activity', '${livestock.activityLevel}%'),
                    if (livestock.latitude != null && livestock.longitude != null)
                      _buildInfoRow('Location', 'Lat: ${livestock.latitude}, Lng: ${livestock.longitude}'),
                  ],
                ),
              ),
              
              const SizedBox(height: 24),
              
              if (livestock.latitude != null && livestock.longitude != null) ...[
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
                        Text('Map View', style: TextStyle(color: Colors.grey[600])),
                        Text('Lat: ${livestock.latitude}, Lng: ${livestock.longitude}', 
                            style: TextStyle(fontSize: 12, color: Colors.grey[600])),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: AppColors.deepBlue,
            ),
          ),
        ],
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

import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/livestock.dart';
import '../common/glass_card.dart';

class LivestockCard extends StatelessWidget {
  final Livestock livestock;
  final VoidCallback onTap;

  const LivestockCard({
    super.key,
    required this.livestock,
    required this.onTap,
  });

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return AppColors.error;
      case 'warning':
        return AppColors.warning;
      case 'normal':
      default:
        return AppColors.success;
    }
  }

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      margin: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          // Avatar / Image
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              livestock.species.toLowerCase() == 'cow' 
                  ? Icons.grass 
                  : Icons.pets, 
              color: AppColors.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          
          // Details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      livestock.name,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBlue,
                          ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(livestock.status).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: _getStatusColor(livestock.status).withOpacity(0.5)),
                      ),
                      child: Text(
                        livestock.status.toUpperCase(),
                        style: TextStyle(
                          color: _getStatusColor(livestock.status),
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  'Tag ID: ${livestock.tagId}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    _buildMetric(Icons.thermostat, '${livestock.temperature}°C'),
                    const SizedBox(width: 16),
                    _buildMetric(Icons.speed, '${livestock.activityLevel}% Act'),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(Icons.chevron_right, color: AppColors.textSecondary),
        ],
      ),
    );
  }

  Widget _buildMetric(IconData icon, String value) {
    return Row(
      children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 4),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

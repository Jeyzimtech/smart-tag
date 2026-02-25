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
      case 'active':
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
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.softBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white, width: 2),
            ),
            child: Icon(
              livestock.species.toLowerCase() == 'cattle' 
                  ? Icons.grass 
                  : livestock.species.toLowerCase() == 'sheep'
                  ? Icons.cloud
                  : Icons.pets, 
              color: AppColors.primaryBlue,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Tag: ${livestock.tagId}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppColors.deepBlue,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  livestock.breed,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  'Herd: ${livestock.herd}',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppColors.textSecondary,
                      ),
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
}

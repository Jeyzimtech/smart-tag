import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';

class DeletedLivestockScreen extends StatelessWidget {
  const DeletedLivestockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final deletedAnimals = _getDeletedLivestock();
    
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Deleted Livestock', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          iconTheme: const IconThemeData(color: AppColors.deepBlue),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: deletedAnimals.length,
          itemBuilder: (context, index) {
            final animal = deletedAnimals[index];
            return _buildDeletedCard(animal);
          },
        ),
      ),
    );
  }

  Widget _buildDeletedCard(Map<String, dynamic> animal) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.red.withOpacity(0.2),
                  child: const Icon(Icons.delete, color: Colors.red),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tag #${animal['tagId']}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${animal['breed']} - ${animal['category']}',
                        style: TextStyle(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Reason for Removal:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(animal['reason']),
                  const SizedBox(height: 8),
                  Text(
                    'Deleted: ${animal['deletedDate']}',
                    style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Map<String, dynamic>> _getDeletedLivestock() {
    return [
      {'tagId': '2345', 'breed': 'Holstein', 'category': 'Cattle', 'reason': 'Deceased - Natural causes', 'deletedDate': '2024-01-15'},
      {'tagId': '6789', 'breed': 'Merino', 'category': 'Sheep', 'reason': 'Sold to another farm', 'deletedDate': '2024-01-10'},
      {'tagId': '4567', 'breed': 'Angus', 'category': 'Cattle', 'reason': 'Sent to market', 'deletedDate': '2024-01-05'},
    ];
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/radial_background.dart';
import 'livestock/add_livestock_form.dart';
import 'livestock/livestock_list_screen.dart';
import 'livestock/deleted_livestock_screen.dart';

class LivestockScreen extends StatelessWidget {
  const LivestockScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Livestock', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: AppColors.deepBlue),
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (_) => const DeletedLivestockScreen()));
              },
            ),
          ],
        ),
        body: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildCategoryCard(context, 'Cattle', 0, 'assets/icons/cattle.svg', Colors.brown),
            _buildCategoryCard(context, 'Sheep', 0, 'assets/icons/sheep.svg', Colors.grey),
            _buildCategoryCard(context, 'Goats', 0, 'assets/icons/goat.svg', Colors.orange),
            _buildCategoryCard(context, 'Pigs', 0, 'assets/icons/pig.svg', Colors.pink),
          ],
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (_) => const AddLivestockForm()));
          },
          icon: const Icon(Icons.add),
          label: const Text('Add Tag'),
          backgroundColor: AppColors.primaryBlue,
        ),
      ),
    );
  }

  Widget _buildCategoryCard(BuildContext context, String category, int count, String svgPath, Color color) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.2),
          child: SvgPicture.asset(svgPath, width: 24, height: 24, colorFilter: ColorFilter.mode(color, BlendMode.srcIn)),
        ),
        title: Text(category, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text('$count animals'),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => LivestockListScreen(category: category)),
          );
        },
      ),
    );
  }
}
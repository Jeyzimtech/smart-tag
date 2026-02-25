import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/livestock.dart';
import '../../services/database_helper.dart';
import '../../widgets/common/radial_background.dart';
import '../../widgets/common/glass_card.dart';
import '../livestock/livestock_detail_screen.dart';

class ConnectedTagsScreen extends StatefulWidget {
  const ConnectedTagsScreen({super.key});

  @override
  State<ConnectedTagsScreen> createState() => _ConnectedTagsScreenState();
}

class _ConnectedTagsScreenState extends State<ConnectedTagsScreen> {
  List<Livestock> _tags = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTags();
  }

  Future<void> _loadTags() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllLivestock();
    setState(() {
      _tags = data.map((e) => Livestock.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Connected Tags', style: TextStyle(color: AppColors.deepBlue)),
          leading: const BackButton(color: AppColors.deepBlue),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
              onPressed: _loadTags,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _tags.isEmpty
                ? const Center(child: Text('No tags connected'))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _tags.length,
                    itemBuilder: (context, index) {
                      final tag = _tags[index];
                      return GlassCard(
                        margin: const EdgeInsets.only(bottom: 12),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: AppColors.softBlue,
                            child: Icon(Icons.sensors, color: AppColors.primaryBlue),
                          ),
                          title: Text(
                            tag.tagId,
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text('${tag.species} - ${tag.breed}'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => LivestockDetailScreen(livestock: tag),
                              ),
                            );
                          },
                        ),
                      );
                    },
                  ),
      ),
    );
  }
}

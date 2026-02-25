import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../widgets/common/radial_background.dart';
import '../widgets/common/glass_card.dart';
import '../services/database_helper.dart';
import '../models/livestock.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  List<Livestock> _livestock = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllLivestock();
    setState(() {
      _livestock = data.map((e) => Livestock.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Map<String, int> _getSpeciesCount() {
    Map<String, int> counts = {};
    for (var animal in _livestock) {
      counts[animal.species] = (counts[animal.species] ?? 0) + 1;
    }
    return counts;
  }

  Map<String, int> _getHerdCount() {
    Map<String, int> counts = {};
    for (var animal in _livestock) {
      counts[animal.herd] = (counts[animal.herd] ?? 0) + 1;
    }
    return counts;
  }

  @override
  Widget build(BuildContext context) {
    final speciesCount = _getSpeciesCount();
    final herdCount = _getHerdCount();

    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Reports', style: TextStyle(color: AppColors.deepBlue, fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
              onPressed: _loadData,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : _livestock.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.assessment_outlined, size: 80, color: AppColors.textSecondary.withOpacity(0.3)),
                        const SizedBox(height: 16),
                        Text('No data available', style: TextStyle(fontSize: 18, color: AppColors.textSecondary)),
                        const SizedBox(height: 8),
                        Text('Add livestock to generate reports', style: TextStyle(fontSize: 14, color: AppColors.textSecondary)),
                      ],
                    ),
                  )
                : ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.pets, color: AppColors.primaryBlue),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Total Livestock',
                                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.deepBlue,
                                        ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Text(
                                '${_livestock.length}',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: AppColors.primaryBlue,
                                    ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      
                      Text(
                        'By Species',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...speciesCount.entries.map((entry) => GlassCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.softBlue,
                                child: Icon(Icons.category, color: AppColors.primaryBlue),
                              ),
                              title: Text(entry.key),
                              trailing: Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          )),
                      const SizedBox(height: 16),
                      
                      Text(
                        'By Herd',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                      ),
                      const SizedBox(height: 8),
                      ...herdCount.entries.map((entry) => GlassCard(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: AppColors.softBlue,
                                child: Icon(Icons.group, color: AppColors.primaryBlue),
                              ),
                              title: Text(entry.key),
                              trailing: Text(
                                '${entry.value}',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: AppColors.primaryBlue,
                                ),
                              ),
                            ),
                          )),
                    ],
                  ),
      ),
    );
  }
}

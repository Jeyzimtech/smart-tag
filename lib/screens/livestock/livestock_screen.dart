import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../models/livestock.dart';
import '../../widgets/common/radial_background.dart';
import '../../widgets/livestock/livestock_card.dart';
import '../../services/database_helper.dart';
import 'add_livestock_form.dart';
import 'livestock_detail_screen.dart';

class LivestockScreen extends StatefulWidget {
  const LivestockScreen({super.key});

  @override
  State<LivestockScreen> createState() => _LivestockScreenState();
}

class _LivestockScreenState extends State<LivestockScreen> with AutomaticKeepAliveClientMixin {
  List<Livestock> _livestockList = [];
  bool _isLoading = true;

  @override
  bool get wantKeepAlive => false;

  @override
  void initState() {
    super.initState();
    print('DEBUG: LivestockScreen initState called');
    _loadLivestock();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadLivestock();
  }

  Future<void> _loadLivestock() async {
    setState(() => _isLoading = true);
    final data = await DatabaseHelper.instance.getAllLivestock();
    print('DEBUG: Loaded ${data.length} livestock from database');
    for (var item in data) {
      print('DEBUG: Tag ${item['tagId']} - ${item['species']} - Status: ${item['status']}');
    }
    setState(() {
      _livestockList = data.map((e) => Livestock.fromMap(e)).toList();
      _isLoading = false;
    });
  }

  Map<String, List<Livestock>> _groupBySpecies() {
    final Map<String, List<Livestock>> grouped = {
      'Cattle': [],
      'Sheep': [],
      'Goat': [],
      'Pig': [],
    };
    
    for (var livestock in _livestockList) {
      final species = livestock.species;
      if (grouped.containsKey(species)) {
        grouped[species]!.add(livestock);
      } else {
        grouped[species] = [livestock];
      }
    }
    
    // Remove empty sections
    grouped.removeWhere((key, value) => value.isEmpty);
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final groupedLivestock = _groupBySpecies();
    
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Livestock',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                  ),
                  IconButton(
                    onPressed: _loadLivestock,
                    icon: const Icon(Icons.refresh, color: AppColors.primaryBlue),
                  ),
                ],
              ),
            ),
            
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'Search by Tag ID',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white.withOpacity(0.8),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _livestockList.isEmpty
                      ? const Center(child: Text('No livestock added yet'))
                      : ListView(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          children: groupedLivestock.entries.map((entry) {
                            return Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 8),
                                  child: Text(
                                    entry.key,
                                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                          fontWeight: FontWeight.bold,
                                          color: AppColors.deepBlue,
                                        ),
                                  ),
                                ),
                                ...entry.value.map((livestock) => LivestockCard(
                                      livestock: livestock,
                                      onTap: () async {
                                        await Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) => LivestockDetailScreen(livestock: livestock),
                                          ),
                                        );
                                        _loadLivestock();
                                      },
                                    )),
                                const SizedBox(height: 16),
                              ],
                            );
                          }).toList(),
                        ),
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () async {
            await Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const AddLivestockForm()),
            );
            _loadLivestock();
          },
          backgroundColor: AppColors.primaryBlue,
          child: const Icon(Icons.add, color: Colors.white),
        ),
      ),
    );
  }
}

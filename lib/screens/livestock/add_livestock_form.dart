import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/common/radial_background.dart';
import '../../widgets/common/glass_card.dart';
import '../../services/database_helper.dart';

class AddLivestockForm extends StatefulWidget {
  const AddLivestockForm({super.key});

  @override
  State<AddLivestockForm> createState() => _AddLivestockFormState();
}

class _AddLivestockFormState extends State<AddLivestockForm> {
  final _formKey = GlobalKey<FormState>();
  final _tagIdController = TextEditingController();
  final _breedController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedSpecies = 'Cattle';
  final List<String> _speciesOptions = ['Cattle', 'Sheep', 'Goat', 'Pig'];
  String _selectedHerd = 'Herd A';
  final List<String> _herdOptions = ['Herd A', 'Herd B', 'Herd C', 'Herd D'];

  @override
  void dispose() {
    _tagIdController.dispose();
    _breedController.dispose();
    _ageController.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          title: const Text('Add New Livestock', style: TextStyle(color: AppColors.deepBlue)),
          leading: const BackButton(color: AppColors.deepBlue),
        ),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: GlassCard(
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    'Animal Details',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: AppColors.deepBlue,
                        ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Tag ID
                  TextFormField(
                    controller: _tagIdController,
                    decoration: const InputDecoration(
                      labelText: 'Tag ID',
                      prefixIcon: Icon(Icons.qr_code),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Breed
                  TextFormField(
                    controller: _breedController,
                    decoration: const InputDecoration(
                      labelText: 'Breed',
                      prefixIcon: Icon(Icons.pets),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Age
                  TextFormField(
                    controller: _ageController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Age (years)',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  
                  // Species Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedSpecies,
                    decoration: const InputDecoration(
                      labelText: 'Species',
                      prefixIcon: Icon(Icons.category),
                    ),
                    items: _speciesOptions.map((String species) {
                      return DropdownMenuItem<String>(
                        value: species,
                        child: Text(species),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedSpecies = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Herd Dropdown
                  DropdownButtonFormField<String>(
                    value: _selectedHerd,
                    decoration: const InputDecoration(
                      labelText: 'Bovine Herd',
                      prefixIcon: Icon(Icons.group),
                    ),
                    items: _herdOptions.map((String herd) {
                      return DropdownMenuItem<String>(
                        value: herd,
                        child: Text(herd),
                      );
                    }).toList(),
                    onChanged: (newValue) {
                      setState(() {
                        _selectedHerd = newValue!;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  
                  // Date Registered
                  TextFormField(
                    initialValue: DateTime.now().toString().split(' ')[0],
                    decoration: const InputDecoration(
                      labelText: 'Date Registered',
                      prefixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                  ),
                  
                  const SizedBox(height: 32),
                  
                  ElevatedButton(
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        await DatabaseHelper.instance.insertLivestock({
                          'tagId': _tagIdController.text,
                          'breed': _breedController.text,
                          'age': int.parse(_ageController.text),
                          'species': _selectedSpecies,
                          'herd': _selectedHerd,
                          'dateRegistered': DateTime.now().toIso8601String(),
                          'synced': 0,
                        });
                        
                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Livestock added successfully')),
                          );
                          Navigator.pop(context);
                        }
                      }
                    },
                    child: const Text('Register Livestock'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

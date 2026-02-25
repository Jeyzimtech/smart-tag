import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../../services/tag_auth_service.dart';
import '../../services/iot_tag_service.dart';
import '../../core/theme/app_colors.dart';

class DevicePairingScreen extends StatefulWidget {
  const DevicePairingScreen({super.key});

  @override
  State<DevicePairingScreen> createState() => _DevicePairingScreenState();
}

class _DevicePairingScreenState extends State<DevicePairingScreen> {
  late IoTTagService _iotTagService;
  late TagAuthService _tagAuthService;
  bool _isScanning = false;
  List<ScanResult> _scanResults = [];

  @override
  void initState() {
    super.initState();
    _iotTagService = Provider.of<IoTTagService>(context, listen: false);
    _tagAuthService = Provider.of<TagAuthService>(context, listen: false);
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    try {
      _scanResults = await _iotTagService.scanForDevices();
      setState(() {});
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Scan error: $e')),
      );
    } finally {
      setState(() => _isScanning = false);
    }
  }

  Future<void> _pairDevice(BluetoothDevice device) async {
    try {
      // Connect to the device
      await _iotTagService.connectToDevice(device);
      
      // Register device to current user
      final userId = Provider.of<TagAuthService>(context, listen: false).autoAuthUserId;
      if (userId != null) {
        await _tagAuthService.registerDeviceToUser(device.remoteId.str, userId);
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Device paired successfully!')),
          );
          Navigator.pop(context, device);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Pairing error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pair Livestock Tag'),
        backgroundColor: AppColors.primaryBlue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Available Devices',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: _isScanning ? null : _startScan,
              icon: _isScanning
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.search),
              label: Text(_isScanning ? 'Scanning...' : 'Scan for Devices'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _scanResults.isEmpty
                  ? Center(
                      child: Text(
                        _isScanning ? 'Searching for devices...' : 'No devices found. Tap Scan to search.',
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _scanResults.length,
                      itemBuilder: (context, index) {
                        final device = _scanResults[index].device;
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          child: ListTile(
                            title: Text(
                              device.platformName.isNotEmpty ? device.platformName : 'Unknown Device',
                            ),
                            subtitle: Text('ID: ${device.remoteId}'),
                            trailing: ElevatedButton(
                              onPressed: () => _pairDevice(device),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryBlue,
                              ),
                              child: const Text('Pair'),
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

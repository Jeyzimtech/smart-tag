import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:smart_tag_app/services/iot_tag_service.dart';

class IoTTagScreen extends StatefulWidget {
  const IoTTagScreen({super.key});

  @override
  State<IoTTagScreen> createState() => _IoTTagScreenState();
}

class _IoTTagScreenState extends State<IoTTagScreen> {
  List<ScanResult> _scanResults = [];
  bool _isScanning = false;

  Future<void> _scanDevices() async {
    setState(() => _isScanning = true);
    final service = context.read<IoTTagService>();
    try {
      final results = await service.scanForDevices();
      setState(() {
        _scanResults = results;
        _isScanning = false;
      });
    } catch (e) {
      setState(() => _isScanning = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Scan failed: $e')),
        );
      }
    }
  }

  Future<void> _connectToDevice(BluetoothDevice device) async {
    final service = context.read<IoTTagService>();
    try {
      await service.connectToDevice(device);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connected successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Connection failed: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('IoT Tag Connection')),
      body: Consumer<IoTTagService>(
        builder: (context, service, _) {
          if (service.isConnected) {
            return _buildConnectedView(service);
          }
          return _buildScanView();
        },
      ),
      floatingActionButton: Consumer<IoTTagService>(
        builder: (context, service, _) {
          if (service.isConnected) return const SizedBox.shrink();
          return FloatingActionButton(
            onPressed: _isScanning ? null : _scanDevices,
            child: _isScanning ? const CircularProgressIndicator() : const Icon(Icons.search),
          );
        },
      ),
    );
  }

  Widget _buildConnectedView(IoTTagService service) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Text('Connected to: ${service.connectedDevice?.platformName ?? "Unknown"}'),
          const SizedBox(height: 20),
          Text('Data: ${service.tagData}'),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => service.disconnect(),
            child: const Text('Disconnect'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanView() {
    return ListView.builder(
      itemCount: _scanResults.length,
      itemBuilder: (context, index) {
        final result = _scanResults[index];
        return ListTile(
          title: Text(result.device.platformName.isEmpty ? 'Unknown' : result.device.platformName),
          subtitle: Text(result.device.remoteId.toString()),
          trailing: Text('${result.rssi} dBm'),
          onTap: () => _connectToDevice(result.device),
        );
      },
    );
  }
}

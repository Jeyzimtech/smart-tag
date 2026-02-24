import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/iot_tag_data_service.dart';

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  Timer? _updateTimer;

  @override
  void initState() {
    super.initState();
    _startLiveUpdates();
  }

  @override
  void dispose() {
    _updateTimer?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  void _startLiveUpdates() {
    _updateTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {}); // Trigger rebuild to pull latest from provider
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<IoTTagDataService>(
      builder: (context, dataService, child) {
        // Use device location if available, otherwise default to a fallback (e.g., NY)
        final currentPos =
            (dataService.latitude != 0.0 && dataService.longitude != 0.0)
            ? LatLng(dataService.latitude, dataService.longitude)
            : const LatLng(40.7128, -74.0060);

        return Scaffold(
          appBar: AppBar(
            backgroundColor: AppColors.primaryBlue,
            title: const Text('Live Tracking'),
            actions: [
              IconButton(
                icon: const Icon(Icons.my_location),
                onPressed: () {
                  _mapController.move(currentPos, 15.0);
                },
              ),
            ],
          ),
          body: FlutterMap(
            mapController: _mapController,
            options: MapOptions(initialCenter: currentPos, initialZoom: 15.0),
            children: [
              TileLayer(
                urlTemplate:
                    'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                userAgentPackageName: 'group1.com',
              ),
              if (dataService.latitude != 0.0 && dataService.longitude != 0.0)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: currentPos,
                      width: 80.0,
                      height: 80.0,
                      child: GestureDetector(
                        onTap: () {
                          // Simple dialog to show info when marker is tapped
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('ESP32 Device'),
                              content: Text(
                                'Temp: ${dataService.temperature}°C\nSatellites: ${dataService.satellites}',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Close'),
                                ),
                              ],
                            ),
                          );
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.red,
                          size: 40.0,
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}

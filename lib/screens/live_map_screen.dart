import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/iot_tag_data_service.dart';
import 'movement_history_screen.dart'; // We will create this hereafter

class LiveMapScreen extends StatefulWidget {
  const LiveMapScreen({super.key});

  @override
  State<LiveMapScreen> createState() => _LiveMapScreenState();
}

class _LiveMapScreenState extends State<LiveMapScreen> {
  final MapController _mapController = MapController();
  Timer? _updateTimer;

  // Polygon Drawing State
  bool _isDrawingPolygon = false;
  List<LatLng> _drawnPolygon = [];

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

  void _showTagDetailsSheet(
    BuildContext context,
    IoTTagDataService dataService,
    LatLng currentPos,
  ) {
    bool isEnabled = dataService.geofenceEnabled;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent, // Allow custom rounded corners
      builder: (ctx) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setSheetState) {
            return Padding(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(ctx).viewInsets.bottom,
              ),
              child: Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: const Color(0xFF222222), // Dark grey from screenshot
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.white24, width: 1),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- HEADER SECTION ---
                    Row(
                      children: [
                        const Text(
                          'ID:',
                          style: TextStyle(
                            color: Colors.redAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'TAG ID_${dataService.deviceId.replaceAll('ESP32_', '')}', // Cleaned up ID display
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    // Coordinates Location
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on_outlined,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${currentPos.latitude.toStringAsFixed(6)}°, ${currentPos.longitude.toStringAsFixed(6)}°',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Temperature / Climate
                    Row(
                      children: [
                        const Icon(
                          Icons.thermostat_outlined,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Text(
                          '${dataService.temperature.toStringAsFixed(1)}°C',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // Health / Status Bar (Static placeholder mapping to screenshot)
                    Row(
                      children: [
                        const Icon(
                          Icons.favorite,
                          color: Colors.redAccent,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Row(
                          children: List.generate(10, (index) {
                            return Container(
                              margin: const EdgeInsets.only(right: 3),
                              width: 8,
                              height: 16,
                              decoration: BoxDecoration(
                                color: index < 7
                                    ? Colors.green
                                    : Colors.grey.shade800,
                                borderRadius: BorderRadius.circular(2),
                              ),
                            );
                          }),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),

                    // --- ACTIVITY MONITOR SECTION ---
                    Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 20,
                        horizontal: 16,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(
                          0xFF632E27,
                        ), // Dark Reddish Brown Background
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'ACTIVITY MONITOR',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              letterSpacing: 1.5,
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            children: [
                              // Pasture Use (Heatmap Placeholder)
                              Expanded(
                                child: Column(
                                  children: [
                                    const Text(
                                      'PASTURE USE',
                                      style: TextStyle(
                                        color: Colors.white70,
                                        fontSize: 12,
                                        letterSpacing: 1.0,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    Container(
                                      height: 100,
                                      decoration: BoxDecoration(
                                        color: const Color(
                                          0xFFC0C0C0,
                                        ), // Lighter Grey
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: const Center(
                                        child: Icon(
                                          Icons.map,
                                          size: 50,
                                          color: Colors.black26,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 20),
                              // Track History Button
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.pop(ctx);
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const MovementHistoryScreen(),
                                      ),
                                    );
                                  },
                                  child: Column(
                                    children: [
                                      const Text(
                                        'TRACK',
                                        style: TextStyle(
                                          color: Colors.white70,
                                          fontSize: 12,
                                          letterSpacing: 1.0,
                                        ),
                                      ),
                                      const SizedBox(height: 12),
                                      Container(
                                        height: 100,
                                        decoration: BoxDecoration(
                                          color: const Color(
                                            0xFFC0C0C0,
                                          ), // Lighter Grey
                                          borderRadius: BorderRadius.circular(
                                            8,
                                          ),
                                        ),
                                        child: const Center(
                                          child: Icon(
                                            Icons.route,
                                            size: 50,
                                            color: Colors.blueAccent,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // --- GEOFENCE CONTROLS ---
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 8),
                      child: Divider(color: Colors.white24, thickness: 1),
                    ),
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: const Text(
                        'Enable Geofence',
                        style: TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      value: isEnabled,
                      activeColor: Colors.white,
                      activeTrackColor: Colors.blueAccent,
                      inactiveThumbColor: Colors.grey.shade400,
                      inactiveTrackColor: Colors.grey.shade800,
                      onChanged: (val) async {
                        setSheetState(() => isEnabled = val);
                        await dataService.updateGeofenceSettings(
                          enabled: val,
                          points: dataService.geofencePoints,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              Navigator.pop(ctx);
                              setState(() {
                                _isDrawingPolygon = true;
                                _drawnPolygon = List.from(
                                  dataService.geofencePoints,
                                );
                              });
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                              size: 18,
                            ),
                            label: const Text(
                              'Draw',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () async {
                              await dataService.updateGeofenceSettings(
                                enabled: false,
                                points: [],
                              );
                              if (ctx.mounted) {
                                Navigator.pop(ctx);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Geofence Cleared'),
                                  ),
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.delete,
                              color: Colors.redAccent,
                              size: 18,
                            ),
                            label: const Text(
                              'Clear',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 16,
                              ),
                            ),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.transparent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(24),
                                side: const BorderSide(
                                  color: Colors.redAccent,
                                  width: 1.5,
                                ),
                              ),
                              padding: const EdgeInsets.symmetric(vertical: 14),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
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
          body: Stack(
            children: [
              FlutterMap(
                mapController: _mapController,
                options: MapOptions(
                  initialCenter: currentPos,
                  initialZoom: 15.0,
                  onTap: (tapPosition, point) {
                    if (_isDrawingPolygon) {
                      setState(() {
                        _drawnPolygon.add(point);
                      });
                    }
                  },
                ),
                children: [
                  TileLayer(
                    urlTemplate:
                        'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                    userAgentPackageName: 'group1.com',
                  ),
                  if (dataService.geofenceEnabled &&
                      dataService.geofencePoints.isNotEmpty &&
                      !_isDrawingPolygon)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: dataService.geofencePoints,
                          color: AppColors.primaryBlue.withValues(alpha: 0.2),
                          borderColor: AppColors.primaryBlue,
                          borderStrokeWidth: 2,
                        ),
                      ],
                    ),
                  if (_isDrawingPolygon && _drawnPolygon.isNotEmpty)
                    PolygonLayer(
                      polygons: [
                        Polygon(
                          points: _drawnPolygon,
                          color: Colors.orange.withValues(alpha: 0.3),
                          borderColor: Colors.deepOrange,
                          borderStrokeWidth: 3,
                        ),
                      ],
                    ),
                  if (_isDrawingPolygon && _drawnPolygon.isNotEmpty)
                    MarkerLayer(
                      markers: _drawnPolygon
                          .map(
                            (p) => Marker(
                              point: p,
                              width: 12,
                              height: 12,
                              child: const CircleAvatar(
                                backgroundColor: Colors.deepOrange,
                              ),
                            ),
                          )
                          .toList(),
                    ),
                  if (dataService.latitude != 0.0 &&
                      dataService.longitude != 0.0)
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: currentPos,
                          width: 80.0,
                          height: 80.0,
                          child: GestureDetector(
                            onTap: () {
                              if (!_isDrawingPolygon) {
                                _showTagDetailsSheet(
                                  context,
                                  dataService,
                                  currentPos,
                                );
                              }
                            },
                            child: Icon(
                              Icons.location_on,
                              color: dataService.geofenceStatus == 'outside'
                                  ? Colors.red
                                  : Colors.green,
                              size: 40.0,
                            ),
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              if (_isDrawingPolygon)
                Positioned(
                  bottom: 30,
                  left: 20,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 10),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Text(
                          'Tap map to draw polygon corners',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  _isDrawingPolygon = false;
                                  _drawnPolygon.clear();
                                });
                              },
                              child: const Text(
                                'Cancel',
                                style: TextStyle(color: Colors.red),
                              ),
                            ),
                            TextButton(
                              onPressed: () {
                                setState(() {
                                  if (_drawnPolygon.isNotEmpty)
                                    _drawnPolygon.removeLast();
                                });
                              },
                              child: const Text(
                                'Undo',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                if (_drawnPolygon.length < 3) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Draw at least 3 points'),
                                    ),
                                  );
                                  return;
                                }
                                await dataService.updateGeofenceSettings(
                                  enabled: true,
                                  points: _drawnPolygon,
                                );
                                setState(() {
                                  _isDrawingPolygon = false;
                                });
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Polygon Saved'),
                                    ),
                                  );
                                }
                              },
                              child: const Text('Save'),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}

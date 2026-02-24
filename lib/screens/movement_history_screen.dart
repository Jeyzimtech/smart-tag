import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import '../../core/theme/app_colors.dart';
import '../../services/iot_tag_data_service.dart';

class MovementHistoryScreen extends StatefulWidget {
  const MovementHistoryScreen({super.key});

  @override
  State<MovementHistoryScreen> createState() => _MovementHistoryScreenState();
}

class _MovementHistoryScreenState extends State<MovementHistoryScreen> {
  DateTime _selectedDate = DateTime.now();
  List<LatLng> _movementPath = [];
  bool _isLoading = false;
  int _timeOutside = 0; // in minutes
  int _breachCount = 0;
  double _totalDistance = 0.0; // in meters

  @override
  void initState() {
    super.initState();
    _fetchMovementHistory();
  }

  Future<void> _fetchMovementHistory() async {
    setState(() {
      _isLoading = true;
      _movementPath = [];
      _timeOutside = 0;
      _breachCount = 0;
      _totalDistance = 0.0;
    });

    final dataService = Provider.of<IoTTagDataService>(context, listen: false);
    String dateStr = DateFormat('yyyy-MM-dd').format(_selectedDate);

    // We filter timestamps between 08:00:00 and 17:00:00 as requested
    String startTime = "08:00:00";
    String endTime = "17:00:00";

    final ref = FirebaseDatabase.instance.ref(
      'tags/${dataService.deviceId}/movementLogs/$dateStr',
    );

    try {
      final snapshot = await ref
          .orderByKey()
          .startAt(startTime)
          .endAt(endTime)
          .get();

      if (snapshot.exists) {
        final data = Map<String, dynamic>.from(snapshot.value as Map);

        // Sort timestamps
        var sortedKeys = data.keys.toList()..sort();

        List<LatLng> path = [];
        String lastStatus = "inside";
        LatLng? lastPoint;

        for (var key in sortedKeys) {
          var log = Map<String, dynamic>.from(data[key]);
          double lat = double.tryParse(log['lat']?.toString() ?? '0') ?? 0.0;
          double lng = double.tryParse(log['lng']?.toString() ?? '0') ?? 0.0;
          String status = log['status']?.toString() ?? 'inside';

          if (lat != 0.0 && lng != 0.0) {
            LatLng currentPoint = LatLng(lat, lng);
            path.add(currentPoint);

            // Calculate distance
            if (lastPoint != null) {
              const distance = Distance();
              _totalDistance += distance.as(
                LengthUnit.Meter,
                lastPoint,
                currentPoint,
              );
            }
            lastPoint = currentPoint;
          }

          if (status == "outside" && lastStatus == "inside") {
            _breachCount++;
          }

          // Rough estimate: Assuming logs are evenly spaced or if status is outside, we could count minutes.
          // For simplicity without exact diffs, we count entries (e.g. 1 entry = 1 min outside if logged per min).
          if (status == "outside") {
            _timeOutside += 1; // Assuming 1 log per minute roughly
          }

          lastStatus = status;
        }

        setState(() {
          _movementPath = path;
        });
      }
    } catch (e) {
      debugPrint("Error fetching history: \$e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppColors.primaryBlue,
            colorScheme: ColorScheme.light(primary: AppColors.primaryBlue),
            buttonTheme: const ButtonThemeData(
              textTheme: ButtonTextTheme.primary,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
      _fetchMovementHistory();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movement History (8AM-5PM)'),
        backgroundColor: AppColors.primaryBlue,
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildStatCard(
                  'Distance',
                  '${_totalDistance.toStringAsFixed(0)} m',
                  Icons.directions_run,
                ),
                _buildStatCard('Outside', '$_timeOutside min', Icons.timer),
                _buildStatCard(
                  'Breaches',
                  '$_breachCount',
                  Icons.warning_amber_rounded,
                ),
              ],
            ),
          ),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _movementPath.isEmpty
                ? const Center(child: Text("No movement data for this day."))
                : FlutterMap(
                    options: MapOptions(
                      // Center map on the first point of the path or default
                      initialCenter: _movementPath.isNotEmpty
                          ? _movementPath.first
                          : const LatLng(0, 0),
                      initialZoom: 15.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                        userAgentPackageName: 'group1.com',
                      ),
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: _movementPath,
                            color: Colors.blueAccent,
                            strokeWidth: 4.0,
                          ),
                        ],
                      ),
                      MarkerLayer(
                        markers: _movementPath.isNotEmpty
                            ? [
                                Marker(
                                  point: _movementPath.first,
                                  child: const Icon(
                                    Icons.play_circle_fill,
                                    color: Colors.green,
                                    size: 30,
                                  ),
                                ),
                                Marker(
                                  point: _movementPath.last,
                                  child: const Icon(
                                    Icons.stop_circle,
                                    color: Colors.red,
                                    size: 30,
                                  ),
                                ),
                              ]
                            : [],
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: AppColors.primaryBlue),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        Text(title, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}

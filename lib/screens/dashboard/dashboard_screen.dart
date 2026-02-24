import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../services/auth_service.dart';
import '../../services/iot_tag_data_service.dart';
import '../../widgets/common/radial_background.dart';
import '../alerts_screen.dart';
import '../live_map_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize connection check
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IoTTagDataService>().checkDeviceConnection();
    });
  }

  void _handleLogout() async {
    final confirmed =
        await showDialog<bool>(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Confirm Logout'),
              content: const Text('Are you sure you want to logout?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Logout',
                    style: TextStyle(color: AppColors.error),
                  ),
                ),
              ],
            );
          },
        ) ??
        false;

    if (!confirmed) return;

    try {
      await context.read<AuthService>().signOut();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Logout failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return RadialBackground(
      child: CustomScrollView(
        slivers: [
          // App Bar
          SliverAppBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            floating: true,
            title: Consumer<IoTTagDataService>(
              builder: (context, dataService, _) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Farm Overview',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.deepBlue,
                          ),
                    ),
                    Text(
                      '${dataService.temperature.toStringAsFixed(1)}°C • ${dataService.getTemperatureStatus()}',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                );
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(
                  Icons.notifications_outlined,
                  color: AppColors.deepBlue,
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AlertsScreen()),
                  );
                },
              ),
              PopupMenuButton<String>(
                icon: const CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: Icon(Icons.person, color: Colors.white),
                ),
                itemBuilder: (BuildContext context) => [
                  const PopupMenuItem<String>(
                    value: 'profile',
                    child: ListTile(
                      leading: Icon(Icons.person),
                      title: Text('Profile'),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                  const PopupMenuDivider(),
                  PopupMenuItem<String>(
                    value: 'logout',
                    child: ListTile(
                      leading: const Icon(Icons.logout, color: AppColors.error),
                      title: const Text(
                        'Logout',
                        style: TextStyle(color: AppColors.error),
                      ),
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ],
                onSelected: (String value) {
                  if (value == 'logout') {
                    _handleLogout();
                  }
                },
              ),
              const SizedBox(width: 8),
            ],
          ),

          // Sensor Data Cards
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverToBoxAdapter(
              child: Consumer<IoTTagDataService>(
                builder: (context, dataService, _) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Connection Status
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: dataService.isConnected
                              ? Colors.green.withOpacity(0.1)
                              : Colors.red.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: dataService.isConnected
                                ? Colors.green
                                : Colors.red,
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              dataService.isConnected
                                  ? Icons.check_circle
                                  : Icons.warning,
                              color: dataService.isConnected
                                  ? Colors.green
                                  : Colors.red,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    dataService.isConnected
                                        ? '🟢 Device Connected'
                                        : '🔴 Device Disconnected',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                  Text(
                                    'Last Updated: ${dataService.lastUpdated}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  if (!dataService.isConnected &&
                                      dataService.errorMessage != null)
                                    Padding(
                                      padding: const EdgeInsets.only(top: 4),
                                      child: Text(
                                        dataService.errorMessage!,
                                        style: const TextStyle(
                                          fontSize: 12,
                                          color: Colors.red,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Sensor Data Grid
                      GridView(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 1.1,
                              mainAxisSpacing: 12,
                              crossAxisSpacing: 12,
                            ),
                        children: [
                          // Temperature Card
                          _buildSensorCard(
                            context,
                            icon: Icons.thermostat,
                            title: 'Temperature',
                            value:
                                '${dataService.temperature.toStringAsFixed(1)}°C',
                            subtitle: dataService.getTemperatureStatus(),
                            color: _getTemperatureColor(
                              dataService.temperature,
                            ),
                          ),

                          // Humidity Card
                          _buildSensorCard(
                            context,
                            icon: Icons.opacity,
                            title: 'Humidity',
                            value:
                                '${dataService.humidity.toStringAsFixed(1)}%',
                            subtitle: 'Relative',
                            color: Colors.blue,
                          ),

                          // GPS Status Card
                          _buildSensorCard(
                            context,
                            icon: Icons.location_on,
                            title: 'GPS Status',
                            value: '${dataService.satellites} Satellites',
                            subtitle: dataService.getGPSStatus(),
                            color: Colors.purple,
                          ),

                          // Movement Card
                          _buildSensorCard(
                            context,
                            icon: Icons.motion_photos_on,
                            title: 'Movement',
                            value:
                                '${(dataService.accelX).toStringAsFixed(2)}g',
                            subtitle: dataService.getMovementStatus(),
                            color: Colors.orange,
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      // Detailed Sensor Info
                      Text(
                        'Detailed Information',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                      ),
                      const SizedBox(height: 12),

                      Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.7),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _buildDetailRow(
                              'Temperature',
                              '${dataService.temperature.toStringAsFixed(2)}°C',
                            ),
                            _buildDetailRow(
                              'Humidity',
                              '${dataService.humidity.toStringAsFixed(2)}%',
                            ),
                            _buildDetailRow(
                              'Latitude',
                              '${dataService.latitude.toStringAsFixed(6)}',
                            ),
                            _buildDetailRow(
                              'Longitude',
                              '${dataService.longitude.toStringAsFixed(6)}',
                            ),
                            _buildDetailRow(
                              'Satellites',
                              dataService.satellites.toString(),
                            ),
                            _buildDetailRow(
                              'Accel X',
                              '${dataService.accelX.toStringAsFixed(4)}g',
                            ),
                            _buildDetailRow(
                              'Accel Y',
                              '${dataService.accelY.toStringAsFixed(4)}g',
                            ),
                            _buildDetailRow(
                              'Accel Z',
                              '${dataService.accelZ.toStringAsFixed(4)}g',
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Live Monitoring
                      Text(
                        'Live Monitoring',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppColors.deepBlue,
                            ),
                      ),
                      const SizedBox(height: 12),

                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => const LiveMapScreen(),
                            ),
                          );
                        },
                        child: Container(
                          height: 200,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.7),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    if (dataService.latitude != 0 &&
                                        dataService.longitude != 0)
                                      Expanded(
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: FlutterMap(
                                            options: MapOptions(
                                              initialCenter: LatLng(
                                                dataService.latitude,
                                                dataService.longitude,
                                              ),
                                              initialZoom: 15.0,
                                              interactionOptions:
                                                  const InteractionOptions(
                                                    flags: InteractiveFlag
                                                        .none, // Disable panning/zooming
                                                  ),
                                            ),
                                            children: [
                                              TileLayer(
                                                urlTemplate:
                                                    'https://a.basemaps.cartocdn.com/rastertiles/voyager/{z}/{x}/{y}@2x.png',
                                                userAgentPackageName:
                                                    'group1.com',
                                              ),
                                              MarkerLayer(
                                                markers: [
                                                  Marker(
                                                    point: LatLng(
                                                      dataService.latitude,
                                                      dataService.longitude,
                                                    ),
                                                    width: 40.0,
                                                    height: 40.0,
                                                    child: const Icon(
                                                      Icons.location_on,
                                                      color: Colors.red,
                                                      size: 40.0,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    else
                                      Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.map,
                                            size: 80,
                                            color: AppColors.primaryBlue
                                                .withOpacity(0.3),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(
                                            'Waiting for GPS Data...',
                                            style: TextStyle(
                                              color: AppColors.primaryBlue
                                                  .withOpacity(0.6),
                                              fontSize: 12,
                                            ),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                              ),
                              Positioned(
                                bottom: 16,
                                left: 16,
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const LiveMapScreen(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    '📍 Tap to view live map',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 14,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSensorCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required String subtitle,
    required Color color,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3), width: 2),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 11, color: Colors.grey),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14, color: Colors.grey)),
          Text(
            value,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.deepBlue,
            ),
          ),
        ],
      ),
    );
  }

  Color _getTemperatureColor(double temp) {
    if (temp < 10) return Colors.blue;
    if (temp < 20) return Colors.cyan;
    if (temp < 25) return Colors.green;
    if (temp < 30) return Colors.orange;
    return Colors.red;
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';

class IoTTagDataService extends ChangeNotifier {
  late FirebaseDatabase _realtimeDb;

  // Environmental Data
  double _temperature = 0.0;
  double _humidity = 0.0;

  // GPS Data
  double _latitude = 0.0;
  double _longitude = 0.0;
  int _satellites = 0;

  // Accelerometer Data
  double _accelX = 0.0;
  double _accelY = 0.0;
  double _accelZ = 0.0;

  // Status
  bool _isConnected = false;
  DateTime _lastUpdated = DateTime.now();
  String _deviceId = 'ESP32_001';
  String? _errorMessage;

  // Getters
  double get temperature => _temperature;
  double get humidity => _humidity;
  double get latitude => _latitude;
  double get longitude => _longitude;
  int get satellites => _satellites;
  double get accelX => _accelX;
  double get accelY => _accelY;
  double get accelZ => _accelZ;
  bool get isConnected => _isConnected;

  String get lastUpdated {
    return _lastUpdated.toString().split('.').first;
  }

  String get deviceId => _deviceId;
  String? get errorMessage => _errorMessage;

  StreamSubscription? _environmentalSubscription;
  StreamSubscription? _gpsSubscription;
  StreamSubscription? _accelSubscription;

  IoTTagDataService() {
    // Initialize Firebase Realtime Database with explicit URL
    _realtimeDb = FirebaseDatabase.instance
      ..databaseURL =
          'https://ceres-tag-8115b-default-rtdb.asia-southeast1.firebasedatabase.app';

    debugPrint('🚀 IoTTagDataService Initializing...');
    _startListeningToData();
    debugPrint('✅ IoTTagDataService Ready - Listening to Firebase paths');
  }

  /// Start listening to all device data from Firebase
  void _startListeningToData() {
    debugPrint('📡 Starting Firebase listeners for device: $_deviceId');
    _listenToEnvironmental();
    _listenToGPS();
    _listenToAccelerometer();
  }

  /// Listen to environmental data (temperature & humidity)
  void _listenToEnvironmental() {
    String path = '/devices/$_deviceId/environment';
    debugPrint('🔍 Connecting to Firebase path: $path');

    _environmentalSubscription = _realtimeDb
        .ref(path)
        .onValue
        .listen(
          (event) {
            try {
              if (event.snapshot.exists) {
                debugPrint(
                  '📡 Data received from Firebase: ${event.snapshot.value}',
                );
                final data = Map<String, dynamic>.from(
                  event.snapshot.value as Map,
                );

                _temperature =
                    double.tryParse(data['temperature']?.toString() ?? '0') ??
                    0.0;
                _humidity =
                    double.tryParse(data['humidity']?.toString() ?? '0') ?? 0.0;

                _isConnected = true;
                _errorMessage = null;
                _lastUpdated = DateTime.now();

                debugPrint(
                  '✅ Environmental Data Updated - Temp: $_temperature°C, Humidity: $_humidity%',
                );
                notifyListeners();
              } else {
                debugPrint(
                  '⚠️ No data at path: $path - ESP32 may not have sent data yet',
                );
                _isConnected = false;
                _errorMessage = 'No data at path: $path';
                notifyListeners();
              }
            } catch (e) {
              debugPrint('❌ Error reading environmental data: $e');
              _isConnected = false;
              _errorMessage = 'Error parsing data: $e';
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('❌ Environmental listener error: $error');
            _isConnected = false;
            _errorMessage = 'Access error: $error (Check Firebase Rules)';
            notifyListeners();
          },
        );
  }

  /// Listen to GPS data (location)
  void _listenToGPS() {
    String path = '/devices/$_deviceId/gps';

    _gpsSubscription = _realtimeDb
        .ref(path)
        .onValue
        .listen(
          (event) {
            try {
              if (event.snapshot.exists) {
                final data = Map<String, dynamic>.from(
                  event.snapshot.value as Map,
                );

                _latitude =
                    double.tryParse(data['latitude']?.toString() ?? '0') ?? 0.0;
                _longitude =
                    double.tryParse(data['longitude']?.toString() ?? '0') ??
                    0.0;
                _satellites =
                    int.tryParse(data['satellites']?.toString() ?? '0') ?? 0;

                _isConnected = true;
                _errorMessage = null;
                _lastUpdated = DateTime.now();

                debugPrint(
                  '✓ GPS Data Updated - Lat: $_latitude, Lon: $_longitude, Satellites: $_satellites',
                );
                notifyListeners();
              } else {
                _isConnected = false;
                _errorMessage = 'No GPS data at path: $path';
                notifyListeners();
              }
            } catch (e) {
              debugPrint('Error reading GPS data: $e');
              _isConnected = false;
              _errorMessage = 'Error parsing GPS data: $e';
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('GPS listener error: $error');
            _isConnected = false;
            _errorMessage = 'GPS access error: $error (Check Firebase Rules)';
            notifyListeners();
          },
        );
  }

  /// Listen to accelerometer data (movement)
  void _listenToAccelerometer() {
    String path = '/devices/$_deviceId/accel';

    _accelSubscription = _realtimeDb
        .ref(path)
        .onValue
        .listen(
          (event) {
            try {
              if (event.snapshot.exists) {
                final data = Map<String, dynamic>.from(
                  event.snapshot.value as Map,
                );

                _accelX = double.tryParse(data['x']?.toString() ?? '0') ?? 0.0;
                _accelY = double.tryParse(data['y']?.toString() ?? '0') ?? 0.0;
                _accelZ = double.tryParse(data['z']?.toString() ?? '0') ?? 0.0;

                _isConnected = true;
                _errorMessage = null;
                _lastUpdated = DateTime.now();

                debugPrint(
                  '✓ Accelerometer Data Updated - X: $_accelX, Y: $_accelY, Z: $_accelZ',
                );
                notifyListeners();
              } else {
                _isConnected = false;
                _errorMessage = 'No accelerometer data at path: $path';
                notifyListeners();
              }
            } catch (e) {
              debugPrint('Error reading accelerometer data: $e');
              _isConnected = false;
              _errorMessage = 'Error parsing accel data: $e';
              notifyListeners();
            }
          },
          onError: (error) {
            debugPrint('Accelerometer listener error: $error');
            _isConnected = false;
            _errorMessage = 'Accel access error: $error (Check Firebase Rules)';
            notifyListeners();
          },
        );
  }

  /// Check if device is connected
  Future<bool> checkDeviceConnection() async {
    try {
      final snapshot = await _realtimeDb.ref('/devices/$_deviceId').get();
      _isConnected = snapshot.exists;
      notifyListeners();
      return _isConnected;
    } catch (e) {
      debugPrint('Connection check error: $e');
      _isConnected = false;
      notifyListeners();
      return false;
    }
  }

  /// Get device location URL for Google Maps
  String getLocationUrl() {
    if (_latitude == 0 && _longitude == 0) {
      return 'https://maps.google.com/?q=0,0';
    }
    return 'https://maps.google.com/?q=$_latitude,$_longitude';
  }

  /// Sync data from cloud (manual sync)
  Future<void> syncFromCloud() async {
    try {
      debugPrint('🔄 Starting manual sync from Cloud...');

      // Refresh environmental data
      final envSnapshot = await _realtimeDb
          .ref('/devices/$_deviceId/environment')
          .get();
      if (envSnapshot.exists) {
        final data = Map<String, dynamic>.from(envSnapshot.value as Map);
        _temperature =
            double.tryParse(data['temperature']?.toString() ?? '0') ?? 0.0;
        _humidity = double.tryParse(data['humidity']?.toString() ?? '0') ?? 0.0;
      }

      // Refresh GPS data
      final gpsSnapshot = await _realtimeDb
          .ref('/devices/$_deviceId/gps')
          .get();
      if (gpsSnapshot.exists) {
        final data = Map<String, dynamic>.from(gpsSnapshot.value as Map);
        _latitude = double.tryParse(data['latitude']?.toString() ?? '0') ?? 0.0;
        _longitude =
            double.tryParse(data['longitude']?.toString() ?? '0') ?? 0.0;
        _satellites = int.tryParse(data['satellites']?.toString() ?? '0') ?? 0;
      }

      // Refresh accelerometer data
      final accelSnapshot = await _realtimeDb
          .ref('/devices/$_deviceId/accel')
          .get();
      if (accelSnapshot.exists) {
        final data = Map<String, dynamic>.from(accelSnapshot.value as Map);
        _accelX = double.tryParse(data['x']?.toString() ?? '0') ?? 0.0;
        _accelY = double.tryParse(data['y']?.toString() ?? '0') ?? 0.0;
        _accelZ = double.tryParse(data['z']?.toString() ?? '0') ?? 0.0;
      }

      _isConnected = true;
      _lastUpdated = DateTime.now();

      debugPrint('✓ Manual sync completed');
      notifyListeners();
    } catch (e) {
      debugPrint('Sync error: $e');
      _isConnected = false;
      notifyListeners();
    }
  }

  /// Get device temperature status
  String getTemperatureStatus() {
    if (_temperature < 10) return 'Cold';
    if (_temperature < 20) return 'Cool';
    if (_temperature < 25) return 'Normal';
    if (_temperature < 30) return 'Warm';
    return 'Hot';
  }

  /// Get GPS status
  String getGPSStatus() {
    if (_satellites == 0) return 'No Fix';
    if (_satellites < 4) return 'Poor';
    if (_satellites < 8) return 'Good';
    return 'Excellent';
  }

  /// Get movement status
  String getMovementStatus() {
    double magnitude =
        (_accelX * _accelX + _accelY * _accelY + _accelZ * _accelZ);
    if (magnitude < 0.1) return 'Stationary';
    if (magnitude < 0.5) return 'Slight Motion';
    if (magnitude < 1.0) return 'Moving';
    return 'High Activity';
  }

  @override
  void dispose() {
    _environmentalSubscription?.cancel();
    _gpsSubscription?.cancel();
    _accelSubscription?.cancel();
    super.dispose();
  }
}

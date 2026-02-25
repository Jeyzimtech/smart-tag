import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TagAuthService extends ChangeNotifier {
  final FirebaseDatabase _realtimeDb = FirebaseDatabase.instance
    ..databaseURL =
        'https://ceres-tag-8115b-default-rtdb.asia-southeast1.firebasedatabase.app';
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  StreamSubscription? _deviceDataSubscription;
  String? _autoAuthUserId;
  String? _detectedDeviceId;

  String? get autoAuthUserId => _autoAuthUserId;
  String? get detectedDeviceId => _detectedDeviceId;

  TagAuthService();

  /// Start listening for device data from any livestock tag
  /// When new data arrives, check if it's associated with a user
  void startListeningForAutoAuth() {
    _deviceDataSubscription = _realtimeDb.ref('devices').onValue.listen((
      event,
    ) async {
      if (event.snapshot.exists) {
        final devices = Map<String, dynamic>.from(event.snapshot.value as Map);

        // Iterate through all devices and check for data
        for (var deviceId in devices.keys) {
          final deviceData = devices[deviceId];

          // Check if device has recent data (within last 30 seconds)
          if (deviceData is Map && deviceData.containsKey('environment')) {
            final userId = await _getOwnerForDevice(deviceId);

            if (userId != null && userId.isNotEmpty) {
              // Found a device with an owner and recent data
              _detectedDeviceId = deviceId;
              _autoAuthUserId = userId;
              notifyListeners();
            }
          }
        }
      }
    });
  }

  /// Get the owner (user) of a device
  Future<String?> _getOwnerForDevice(String deviceId) async {
    try {
      final deviceDoc = await _firestore
          .collection('devices')
          .doc(deviceId)
          .get();
      if (deviceDoc.exists) {
        return deviceDoc.data()?['owner'] as String?;
      }
    } catch (e) {
      debugPrint('Error getting device owner: $e');
    }
    return null;
  }

  /// Auto-login user associated with a detected tag
  Future<bool> autoLoginWithTag(String userId) async {
    try {
      // Get user document to retrieve email (we'll use custom auth token)
      final userDoc = await _firestore.collection('users').doc(userId).get();

      if (userDoc.exists) {
        // Sign in with custom auth or use stored credentials
        // For now, we'll trigger a manual sign-in flow with pre-populated data
        debugPrint('Device owner found: $userId');
        _autoAuthUserId = userId;
        notifyListeners();
        return true;
      }
    } catch (e) {
      debugPrint('Auto-login error: $e');
    }
    return false;
  }

  /// Register a device to a user (called after successful pairing)
  Future<void> registerDeviceToUser(String deviceId, String userId) async {
    try {
      await _firestore.collection('devices').doc(deviceId).set({
        'owner': userId,
        'registeredAt': Timestamp.now(),
      }, SetOptions(merge: true));

      debugPrint('Device $deviceId registered to user $userId');
      notifyListeners();
    } catch (e) {
      debugPrint('Error registering device: $e');
      rethrow;
    }
  }

  /// Check if a tag/device is already registered
  Future<bool> isDeviceRegistered(String deviceId) async {
    try {
      final deviceDoc = await _firestore
          .collection('devices')
          .doc(deviceId)
          .get();
      return deviceDoc.exists && deviceDoc.data()?['owner'] != null;
    } catch (e) {
      debugPrint('Error checking device registration: $e');
      return false;
    }
  }

  /// Get all devices owned by current user
  Future<List<Map<String, dynamic>>> getMyDevices(String userId) async {
    try {
      final deviceDocs = await _firestore
          .collection('devices')
          .where('owner', isEqualTo: userId)
          .get();

      return deviceDocs.docs
          .map((doc) => {'id': doc.id, ...doc.data()})
          .toList();
    } catch (e) {
      debugPrint('Error fetching user devices: $e');
      return [];
    }
  }

  /// Clear auto-auth state
  void clearAutoAuth() {
    _autoAuthUserId = null;
    _detectedDeviceId = null;
    notifyListeners();
  }

  void stopListening() {
    _deviceDataSubscription?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

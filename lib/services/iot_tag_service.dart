import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class IoTTagService extends ChangeNotifier {
  BluetoothDevice? _connectedDevice;
  BluetoothCharacteristic? _dataCharacteristic;
  StreamSubscription? _deviceStateSubscription;
  StreamSubscription? _characteristicSubscription;
  
  bool _isConnected = false;
  String _tagData = '';
  
  bool get isConnected => _isConnected;
  String get tagData => _tagData;
  BluetoothDevice? get connectedDevice => _connectedDevice;

  // Arduino BLE service UUID (customize based on your Arduino setup)
  static const String serviceUUID = "4fafc201-1fb5-459e-8fcc-c5c9c331914b";
  static const String characteristicUUID = "beb5483e-36e1-4688-b7f5-ea07361b26a8";

  Future<List<ScanResult>> scanForDevices({Duration timeout = const Duration(seconds: 4)}) async {
    List<ScanResult> results = [];
    final subscription = FlutterBluePlus.scanResults.listen((r) => results = r);
    await FlutterBluePlus.startScan(timeout: timeout);
    await Future.delayed(timeout);
    await FlutterBluePlus.stopScan();
    await subscription.cancel();
    return results;
  }

  Future<void> connectToDevice(BluetoothDevice device) async {
    try {
      await device.connect();
      _connectedDevice = device;
      _isConnected = true;

      _deviceStateSubscription = device.connectionState.listen((state) {
        if (state == BluetoothConnectionState.disconnected) {
          _handleDisconnection();
        }
      });

      await _discoverServices();
      notifyListeners();
    } catch (e) {
      debugPrint('Connection error: $e');
      rethrow;
    }
  }

  Future<void> _discoverServices() async {
    if (_connectedDevice == null) return;

    List<BluetoothService> services = await _connectedDevice!.discoverServices();
    for (var service in services) {
      if (service.uuid.toString() == serviceUUID) {
        for (var characteristic in service.characteristics) {
          if (characteristic.uuid.toString() == characteristicUUID) {
            _dataCharacteristic = characteristic;
            await _subscribeToCharacteristic();
            break;
          }
        }
      }
    }
  }

  Future<void> _subscribeToCharacteristic() async {
    if (_dataCharacteristic == null) return;

    await _dataCharacteristic!.setNotifyValue(true);
    _characteristicSubscription = _dataCharacteristic!.lastValueStream.listen((value) {
      _tagData = String.fromCharCodes(value);
      notifyListeners();
    });
  }

  Future<void> sendCommand(String command) async {
    if (_dataCharacteristic == null) return;
    await _dataCharacteristic!.write(command.codeUnits);
  }

  void _handleDisconnection() {
    _isConnected = false;
    _connectedDevice = null;
    _dataCharacteristic = null;
    notifyListeners();
  }

  Future<void> disconnect() async {
    await _characteristicSubscription?.cancel();
    await _deviceStateSubscription?.cancel();
    await _connectedDevice?.disconnect();
    _handleDisconnection();
  }

  @override
  void dispose() {
    disconnect();
    super.dispose();
  }
}

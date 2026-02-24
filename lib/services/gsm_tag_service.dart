import 'dart:async';
import 'package:flutter/foundation.dart';
import 'database_helper.dart';

class GsmTagService extends ChangeNotifier {
  final DatabaseHelper _dbHelper = DatabaseHelper.instance;
  Timer? _pollingTimer;
  List<Map<String, dynamic>> _livestockData = [];
  
  List<Map<String, dynamic>> get livestockData => _livestockData;

  void startListening() {
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      _livestockData = await _dbHelper.getAllLivestock();
      notifyListeners();
    });
  }

  void stopListening() {
    _pollingTimer?.cancel();
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }
}

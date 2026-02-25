import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'database_helper.dart';

class SyncService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> syncToCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _syncLivestock(user.uid);
    await _syncDeletedLivestock(user.uid);
    await _syncSensorData(user.uid);
  }

  Future<void> _syncLivestock(String userId) async {
    final unsynced = await DatabaseHelper.instance.getUnsyncedData('livestock');
    
    for (var item in unsynced) {
      try {
        await _firestore.collection('livestock').add({
          ...item,
          'userId': userId,
          'syncedAt': FieldValue.serverTimestamp(),
        });
        await DatabaseHelper.instance.markAsSynced('livestock', item['id']);
      } catch (e) {
        print('Sync error: $e');
      }
    }
  }

  Future<void> _syncDeletedLivestock(String userId) async {
    final unsynced = await DatabaseHelper.instance.getUnsyncedData('deleted_livestock');
    
    for (var item in unsynced) {
      try {
        await _firestore.collection('deleted_livestock').add({
          ...item,
          'userId': userId,
          'syncedAt': FieldValue.serverTimestamp(),
        });
        await DatabaseHelper.instance.markAsSynced('deleted_livestock', item['id']);
      } catch (e) {
        print('Sync error: $e');
      }
    }
  }

  Future<void> _syncSensorData(String userId) async {
    final unsynced = await DatabaseHelper.instance.getUnsyncedData('sensor_data');
    
    for (var item in unsynced) {
      try {
        await _firestore.collection('sensor_data').add({
          ...item,
          'userId': userId,
          'syncedAt': FieldValue.serverTimestamp(),
        });
        await DatabaseHelper.instance.markAsSynced('sensor_data', item['id']);
      } catch (e) {
        print('Sync error: $e');
      }
    }
  }

  Future<void> syncFromCloud() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('livestock')
        .where('userId', isEqualTo: user.uid)
        .get();

    for (var doc in snapshot.docs) {
      final data = doc.data();
      await DatabaseHelper.instance.insertLivestock({
        'tagId': data['tagId'],
        'breed': data['breed'],
        'age': data['age'],
        'species': data['species'],
        'herd': data['herd'],
        'dateRegistered': data['dateRegistered'],
        'synced': 1,
      });
    }
  }
}

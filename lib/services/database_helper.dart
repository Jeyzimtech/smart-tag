import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('livestock.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE livestock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagId TEXT NOT NULL,
        breed TEXT NOT NULL,
        age INTEGER NOT NULL,
        species TEXT NOT NULL,
        herd TEXT NOT NULL,
        status TEXT DEFAULT 'active',
        dateRegistered TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE deleted_livestock (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagId TEXT NOT NULL,
        breed TEXT NOT NULL,
        category TEXT NOT NULL,
        reason TEXT NOT NULL,
        deletedDate TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE sensor_data (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        tagId TEXT NOT NULL,
        latitude REAL,
        longitude REAL,
        temperature REAL,
        humidity REAL,
        activity INTEGER,
        timestamp TEXT NOT NULL,
        synced INTEGER DEFAULT 0
      )
    ''');
  }

  Future<int> insertLivestock(Map<String, dynamic> livestock) async {
    final db = await database;
    return await db.insert('livestock', livestock);
  }

  Future<List<Map<String, dynamic>>> getAllLivestock() async {
    final db = await database;
    return await db.query('livestock', where: 'status = ?', whereArgs: ['active']);
  }

  Future<int> updateLivestock(int id, Map<String, dynamic> livestock) async {
    final db = await database;
    return await db.update('livestock', livestock, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> deleteLivestock(int id) async {
    final db = await database;
    return await db.update('livestock', {'status': 'deleted'}, where: 'id = ?', whereArgs: [id]);
  }

  Future<int> insertDeletedRecord(Map<String, dynamic> record) async {
    final db = await database;
    return await db.insert('deleted_livestock', record);
  }

  Future<List<Map<String, dynamic>>> getUnsyncedData(String table) async {
    final db = await database;
    return await db.query(table, where: 'synced = ?', whereArgs: [0]);
  }

  Future<int> markAsSynced(String table, int id) async {
    final db = await database;
    return await db.update(table, {'synced': 1}, where: 'id = ?', whereArgs: [id]);
  }

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('livestock');
    await db.delete('deleted_livestock');
    await db.delete('sensor_data');
  }

  Future close() async {
    final db = await database;
    db.close();
  }
}

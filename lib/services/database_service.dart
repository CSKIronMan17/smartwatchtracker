// lib/services/database_service.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/health_record.dart';

class DatabaseService {
  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, 'health_records.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE health_records(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            timestamp TEXT NOT NULL,
            heartRate INTEGER NOT NULL,
            steps INTEGER NOT NULL,
            isSynced INTEGER NOT NULL DEFAULT 0
          )
        ''');
      },
    );
  }

  Future<int> insertRecord(HealthRecord record) async {
    final db = await database;
    return await db.insert('health_records', record.toMap());
  }

  Future<List<HealthRecord>> getRecords({
    String? dateFilter,
    String orderBy = 'timestamp DESC',
    int limit = 50,
  }) async {
    final db = await database;
    
    String whereClause = '';
    List<dynamic> whereArgs = [];
    
    if (dateFilter != null) {
      whereClause = 'DATE(timestamp) = DATE(?)';
      whereArgs = [dateFilter];
    }

    final List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: whereClause.isEmpty ? null : whereClause,
      whereArgs: whereArgs.isEmpty ? null : whereArgs,
      orderBy: orderBy,
      limit: limit,
    );

    return List.generate(maps.length, (i) => HealthRecord.fromMap(maps[i]));
  }

  Future<List<String>> getDistinctDates() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.rawQuery('''
      SELECT DISTINCT DATE(timestamp) as date 
      FROM health_records 
      ORDER BY date DESC
    ''');
    
    return maps.map((map) => map['date'] as String).toList();
  }
}
// lib/database/database_helper.dart
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
//import '../models/health_record.dart';
import 'package:path_provider/path_provider.dart';

class DatabaseHelper {
  static final DatabaseHelper _instance = DatabaseHelper._internal();
  static Database? _database;

  factory DatabaseHelper() => _instance;

  DatabaseHelper._internal();

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final documentsDirectory = await getApplicationDocumentsDirectory();
    final path = join(documentsDirectory.path, 'health_monitor.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  Future<void> _onCreate(Database db, int version) async {
    // Health Records table
    await db.execute('''
      CREATE TABLE health_records (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        timestamp TEXT NOT NULL,
        heart_rate INTEGER NOT NULL,
        steps INTEGER NOT NULL,
        calories INTEGER NOT NULL DEFAULT 0,
        activity_minutes INTEGER NOT NULL DEFAULT 0,
        is_synced INTEGER NOT NULL DEFAULT 0,
        user_id TEXT NOT NULL,
        device_id TEXT,
        notes TEXT
      )
    ''');

    // Daily Summary table
    await db.execute('''
      CREATE TABLE daily_summaries (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        date TEXT NOT NULL,
        total_steps INTEGER NOT NULL DEFAULT 0,
        average_heart_rate INTEGER,
        total_calories INTEGER NOT NULL DEFAULT 0,
        total_activity_minutes INTEGER NOT NULL DEFAULT 0,
        user_id TEXT NOT NULL,
        is_synced INTEGER NOT NULL DEFAULT 0,
        UNIQUE(date, user_id)
      )
    ''');

    // Create indexes
    await db.execute(
      'CREATE INDEX idx_health_records_timestamp ON health_records(timestamp)',
    );
    await db.execute(
      'CREATE INDEX idx_health_records_user ON health_records(user_id)',
    );
    await db.execute(
      'CREATE INDEX idx_daily_summaries_date ON daily_summaries(date)',
    );
  }

  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    // Handle future database migrations here
  }
}

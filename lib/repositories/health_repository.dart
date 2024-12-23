// lib/repositories/health_repository.dart
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import '../models/health_record.dart';
import '../models/daily_summary.dart';

class HealthRepository {
  final DatabaseHelper _dbHelper;

  HealthRepository(this._dbHelper);

  // Health Records CRUD Operations
  Future<int> insertHealthRecord(HealthRecord record) async {
    final db = await _dbHelper.database;
    return await db.insert('health_records', record.toMap());
  }

  Future<List<HealthRecord>> getHealthRecords({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
    bool syncedOnly = false,
    int limit = 100,
    int offset = 0,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (userId != null) {
      whereConditions.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (startDate != null) {
      whereConditions.add('timestamp >= ?');
      whereArgs.add(startDate.toIso8601String());
    }

    if (endDate != null) {
      whereConditions.add('timestamp <= ?');
      whereArgs.add(endDate.toIso8601String());
    }

    if (syncedOnly) {
      whereConditions.add('is_synced = 1');
    }

    final String? whereClause = whereConditions.isNotEmpty 
      ? whereConditions.join(' AND ')
      : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'health_records',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'timestamp DESC',
      limit: limit,
      offset: offset,
    );

    return List.generate(maps.length, (i) => HealthRecord.fromMap(maps[i]));
  }

  Future<void> markRecordsAsSynced(List<int> recordIds) async {
    final db = await _dbHelper.database;
    await db.update(
      'health_records',
      {'is_synced': 1},
      where: 'id IN (${List.filled(recordIds.length, '?').join(', ')})',
      whereArgs: recordIds,
    );
  }

  Future<void> deleteOldRecords(DateTime before) async {
    final db = await _dbHelper.database;
    await db.delete(
      'health_records',
      where: 'timestamp < ? AND is_synced = 1',
      whereArgs: [before.toIso8601String()],
    );
  }

  // Daily Summaries Operations
  Future<void> updateDailySummary(DailySummary summary) async {
    final db = await _dbHelper.database;
    await db.insert(
      'daily_summaries',
      summary.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<DailySummary>> getDailySummaries({
    String? userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    final db = await _dbHelper.database;
    final List<String> whereConditions = [];
    final List<dynamic> whereArgs = [];

    if (userId != null) {
      whereConditions.add('user_id = ?');
      whereArgs.add(userId);
    }

    if (startDate != null) {
      whereConditions.add('date >= ?');
      whereArgs.add(startDate.toIso8601String().split('T')[0]);
    }

    if (endDate != null) {
      whereConditions.add('date <= ?');
      whereArgs.add(endDate.toIso8601String().split('T')[0]);
    }

    final String? whereClause = whereConditions.isNotEmpty 
      ? whereConditions.join(' AND ')
      : null;

    final List<Map<String, dynamic>> maps = await db.query(
      'daily_summaries',
      where: whereClause,
      whereArgs: whereArgs,
      orderBy: 'date DESC',
    );

    return List.generate(maps.length, (i) => DailySummary.fromMap(maps[i]));
  }

  // Statistics and Aggregations
  Future<Map<String, dynamic>> getStatistics({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    final db = await _dbHelper.database;
    final result = await db.rawQuery('''
      SELECT 
        AVG(heart_rate) as average_heart_rate,
        MAX(heart_rate) as max_heart_rate,
        MIN(heart_rate) as min_heart_rate,
        SUM(steps) as total_steps,
        SUM(calories) as total_calories,
        SUM(activity_minutes) as total_activity_minutes
      FROM health_records
      WHERE user_id = ? 
        AND timestamp BETWEEN ? AND ?
    ''', [
      userId,
      startDate.toIso8601String(),
      endDate.toIso8601String(),
    ]);

    return result.first;
  }

  Future<void> calculateDailySummary(String userId, DateTime date) async {
    //final db = await _dbHelper.database;
    final dayStart = DateTime(date.year, date.month, date.day);
    final dayEnd = dayStart.add(const Duration(days: 1));

    final records = await getHealthRecords(
      userId: userId,
      startDate: dayStart,
      endDate: dayEnd,
    );

    if (records.isEmpty) return;

    final summary = DailySummary(
      date: dayStart,
      userId: userId,
      totalSteps: records.fold(0, (sum, record) => sum + record.steps),
      averageHeartRate: records.fold(0, (sum, record) => sum + record.heartRate) ~/ records.length,
      totalCalories: records.fold(0, (sum, record) => sum + record.calories),
      totalActivityMinutes: records.fold(0, (sum, record) => sum + record.activityMinutes),
      isSynced: false,
    );

    await updateDailySummary(summary);
  }
}

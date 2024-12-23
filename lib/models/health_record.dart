// lib/models/health_record.dart
class HealthRecord {
  final int id;
  final DateTime timestamp;
  final int heartRate;
  final int steps;
  final bool isSynced;

  int calories;
  int activityMinutes;

  HealthRecord({
    required this.id,
    required this.timestamp,
    required this.heartRate,
    required this.steps,
    this.isSynced = false,
    required this.calories,
    required this.activityMinutes,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'timestamp': timestamp.toIso8601String(),
      'heartRate': heartRate,
      'steps': steps,
      'isSynced': isSynced ? 1 : 0,
    };
  }

  factory HealthRecord.fromMap(Map<String, dynamic> map) {
    return HealthRecord(
      id: map['id'],
      timestamp: DateTime.parse(map['timestamp']),
      heartRate: map['heartRate'],
      steps: map['steps'],
      isSynced: map['isSynced'] == 1,
      calories: map['calories'],
      activityMinutes: map['activityMinutes'],
    );
  }
}

// lib/models/daily_summary.dart
class DailySummary {
  final int? id;
  final DateTime date;
  final String userId;
  final int totalSteps;
  final int averageHeartRate;
  final int totalCalories;
  final int totalActivityMinutes;
  final bool isSynced;

  DailySummary({
    this.id,
    required this.date,
    required this.userId,
    required this.totalSteps,
    required this.averageHeartRate,
    required this.totalCalories,
    required this.totalActivityMinutes,
    required this.isSynced,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'date': date.toIso8601String().split('T')[0],
      'user_id': userId,
      'total_steps': totalSteps,
      'average_heart_rate': averageHeartRate,
      'total_calories': totalCalories,
      'total_activity_minutes': totalActivityMinutes,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory DailySummary.fromMap(Map<String, dynamic> map) {
    return DailySummary(
      id: map['id'],
      date: DateTime.parse(map['date']),
      userId: map['user_id'],
      totalSteps: map['total_steps'],
      averageHeartRate: map['average_heart_rate'],
      totalCalories: map['total_calories'],
      totalActivityMinutes: map['total_activity_minutes'],
      isSynced: map['is_synced'] == 1,
    );
  }
}
import 'dart:convert';

class WorkoutRecord {
  const WorkoutRecord({
    required this.id,
    required this.userId,
    required this.routineName,
    required this.completedAt,
    required this.totalDuration,
    required this.splits,
    required this.roxZoneSplits,
    this.avgHeartRate,
    this.totalCalories,
  });

  final String id;
  final String userId;
  final String routineName;
  final DateTime completedAt;
  final Duration totalDuration;
  final List<Duration> splits;
  final List<Duration> roxZoneSplits;
  final int? avgHeartRate;
  final double? totalCalories;

  Map<String, dynamic> toRow() => {
        'id': id,
        'user_id': userId,
        'routine_name': routineName,
        'completed_at': completedAt.millisecondsSinceEpoch,
        'total_duration_ms': totalDuration.inMilliseconds,
        'splits_json':
            jsonEncode(splits.map((d) => d.inMilliseconds).toList()),
        'rox_zone_splits_json':
            jsonEncode(roxZoneSplits.map((d) => d.inMilliseconds).toList()),
        'avg_heart_rate': avgHeartRate,
        'total_calories': totalCalories,
      };

  static WorkoutRecord fromRow(Map<String, dynamic> row) {
    List<Duration> _parseDurations(String json) =>
        (jsonDecode(json) as List)
            .map((ms) => Duration(milliseconds: ms as int))
            .toList();

    return WorkoutRecord(
      id: row['id'] as String,
      userId: row['user_id'] as String,
      routineName: row['routine_name'] as String,
      completedAt: DateTime.fromMillisecondsSinceEpoch(
          row['completed_at'] as int),
      totalDuration:
          Duration(milliseconds: row['total_duration_ms'] as int),
      splits: _parseDurations(row['splits_json'] as String),
      roxZoneSplits:
          _parseDurations(row['rox_zone_splits_json'] as String),
      avgHeartRate: row['avg_heart_rate'] as int?,
      totalCalories: row['total_calories'] as double?,
    );
  }

  WorkoutRecord copyWith({
    String? id,
    String? userId,
    String? routineName,
    DateTime? completedAt,
    Duration? totalDuration,
    List<Duration>? splits,
    List<Duration>? roxZoneSplits,
    int? avgHeartRate,
    double? totalCalories,
  }) =>
      WorkoutRecord(
        id: id ?? this.id,
        userId: userId ?? this.userId,
        routineName: routineName ?? this.routineName,
        completedAt: completedAt ?? this.completedAt,
        totalDuration: totalDuration ?? this.totalDuration,
        splits: splits ?? this.splits,
        roxZoneSplits: roxZoneSplits ?? this.roxZoneSplits,
        avgHeartRate: avgHeartRate ?? this.avgHeartRate,
        totalCalories: totalCalories ?? this.totalCalories,
      );
}

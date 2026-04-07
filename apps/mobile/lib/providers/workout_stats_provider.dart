import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_record.dart';
import '../models/predefined_routines.dart';
import 'workout_history_provider.dart';

class WorkoutStats {
  const WorkoutStats({
    required this.routineName,
    required this.records,
    required this.totalTimeSeries,
    required this.splitsByExercise,
  });

  factory WorkoutStats.empty(String routineName) => WorkoutStats(
        routineName: routineName,
        records: const [],
        totalTimeSeries: const [],
        splitsByExercise: const {},
      );

  final String routineName;

  /// Records sorted oldest → newest (for chart X axis ordering).
  final List<WorkoutRecord> records;

  /// (completedAt, totalDuration) oldest → newest.
  final List<(DateTime, Duration)> totalTimeSeries;

  /// Key = exercise name, value = list of (completedAt, split) oldest → newest.
  final Map<String, List<(DateTime, Duration)>> splitsByExercise;

  bool get hasEnoughData => records.length >= 2;
}

/// Family keyed by routineName. Computes synchronously from loaded history.
final workoutStatsProvider =
    Provider.family<WorkoutStats, String>((ref, routineName) {
  final historyAsync = ref.watch(workoutHistoryProvider);
  return historyAsync.when(
    data: (allRecords) {
      // Filter to this routine, sort oldest → newest for charts.
      final records = allRecords
          .where((r) => r.routineName == routineName)
          .toList()
        ..sort((a, b) => a.completedAt.compareTo(b.completedAt));

      if (records.isEmpty) return WorkoutStats.empty(routineName);

      final totalTimeSeries = records
          .map((r) => (r.completedAt, r.totalDuration))
          .toList();

      // Build per-exercise split series.
      // Exercise names come from predefined routines.
      final routine = PredefinedRoutines.byName(routineName);
      final splitsByExercise = <String, List<(DateTime, Duration)>>{};

      if (routine != null) {
        for (var i = 0; i < routine.exercises.length; i++) {
          final name = routine.exercises[i].name;
          final series = <(DateTime, Duration)>[];
          for (final r in records) {
            if (i < r.splits.length) {
              series.add((r.completedAt, r.splits[i]));
            }
          }
          if (series.isNotEmpty) splitsByExercise[name] = series;
        }
      }

      return WorkoutStats(
        routineName: routineName,
        records: records,
        totalTimeSeries: totalTimeSeries,
        splitsByExercise: splitsByExercise,
      );
    },
    loading: () => WorkoutStats.empty(routineName),
    error: (_, __) => WorkoutStats.empty(routineName),
  );
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/workout_record.dart';
import 'auth_provider.dart';
import 'workout_repository_provider.dart';

class WorkoutHistoryNotifier extends AsyncNotifier<List<WorkoutRecord>> {
  @override
  Future<List<WorkoutRecord>> build() =>
      ref.read(workoutRepositoryProvider).fetchAll();

  Future<void> save(WorkoutRecord record) async {
    await ref.read(workoutRepositoryProvider).save(record);
    ref.invalidateSelf();
    // Fire-and-forget sync — never blocks the UI or fails the local save.
    _syncToApi(record);
  }

  Future<void> delete(String id) async {
    await ref.read(workoutRepositoryProvider).delete(id);
    ref.invalidateSelf();
  }

  void _syncToApi(WorkoutRecord record) {
    final auth = ref.read(authProvider).value;
    if (auth is! AuthAuthenticated) return; // not signed in — skip

    final api = ref.read(apiClientProvider);
    // ignore: unawaited_futures
    api.post('/api/workouts', data: {
      'clientId': record.id,
      'routineName': record.routineName,
      'completedAt': record.completedAt.toUtc().toIso8601String(),
      'totalDurationMs': record.totalDuration.inMilliseconds,
      'splitsJson': _durationsToJson(record.splits),
      'roxZoneSplitsJson': _durationsToJson(record.roxZoneSplits),
      'avgHeartRate': record.avgHeartRate,
      'totalCalories': record.totalCalories,
    }).ignore(); // silent on network failure — local save is source of truth
  }

  static String _durationsToJson(List<Duration> durations) =>
      '[${durations.map((d) => d.inMilliseconds).join(',')}]';
}

final workoutHistoryProvider =
    AsyncNotifierProvider<WorkoutHistoryNotifier, List<WorkoutRecord>>(
  WorkoutHistoryNotifier.new,
);

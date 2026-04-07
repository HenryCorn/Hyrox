import 'package:freezed_annotation/freezed_annotation.dart';
import '../models/routine.dart';

part 'timer_state.freezed.dart';

enum TimerStatus {
  initial,
  running,
  paused,
  finished,
}

@freezed
abstract class TimerState with _$TimerState {
  const factory TimerState({
    required TimerStatus status,
    required Duration totalElapsed,
    required int currentExerciseIndex,
    required Duration currentExerciseElapsed,
    required List<Duration> splits, // Time for each completed exercise
    required List<Duration> roxZoneSplits, // Time for each Rox Zone transition
    required bool isInRoxZone, // Whether currently in transition zone
    Routine? activeRoutine,
    DateTime? startTime,
    DateTime? lastTickTime,
  }) = _TimerState;

  factory TimerState.initial() => const TimerState(
        status: TimerStatus.initial,
        totalElapsed: Duration.zero,
        currentExerciseIndex: 0,
        currentExerciseElapsed: Duration.zero,
        splits: [],
        roxZoneSplits: [],
        isInRoxZone: false,
      );
}

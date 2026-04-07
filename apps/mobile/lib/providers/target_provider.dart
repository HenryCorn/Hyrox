import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../models/workout_target.dart';

/// Manages the user's workout target configuration.
class TargetNotifier extends Notifier<WorkoutTarget> {
  @override
  WorkoutTarget build() => const WorkoutTarget();

  void setGlobalTargetTime(Duration? time) {
    state = state.copyWith(
      globalTargetTime: time,
      clearGlobalTargetTime: time == null,
    );
  }

  void setGlobalRunPace(Duration? pace) {
    state = state.copyWith(
      globalRunPace: pace,
      clearGlobalRunPace: pace == null,
    );
  }

  void setExerciseTarget(int index, Duration? target) {
    final updated = Map<int, Duration>.from(state.exerciseTargets);
    if (target == null) {
      updated.remove(index);
    } else {
      updated[index] = target;
    }
    state = state.copyWith(exerciseTargets: updated);
  }

  void setRunPace(int index, Duration? pace) {
    final updated = Map<int, Duration>.from(state.runPaces);
    if (pace == null) {
      updated.remove(index);
    } else {
      updated[index] = pace;
    }
    state = state.copyWith(runPaces: updated);
  }

  void clear() {
    state = const WorkoutTarget();
  }
}

final targetProvider =
    NotifierProvider<TargetNotifier, WorkoutTarget>(() => TargetNotifier());

// ── Pace status calculation ─────────────────────────────────────────────────

/// How the user is performing relative to their target.
enum PaceStatus {
  /// Ahead of target (under target time).
  ahead,

  /// Within 5% of target — roughly on pace.
  onPace,

  /// Behind target (over target time).
  behind,

  /// No target set for this segment.
  none,
}

/// Computes pace status for the current exercise.
///
/// [elapsed] is how long the user has been on this segment.
/// [target] is the target duration for this segment.
///
/// We compare the fraction of time used vs. a linear projection.
/// If no target is set, returns [PaceStatus.none].
PaceStatus computePaceStatus(Duration elapsed, Duration? target) {
  if (target == null || target == Duration.zero) return PaceStatus.none;

  final ratio = elapsed.inMilliseconds / target.inMilliseconds;

  if (ratio <= 0.95) return PaceStatus.ahead;
  if (ratio <= 1.05) return PaceStatus.onPace;
  return PaceStatus.behind;
}

/// Computes overall workout pace status using cumulative time.
///
/// [completedSplits] — durations for finished segments.
/// [currentElapsed] — time on the current (in-progress) segment.
/// [currentIndex] — index of the current segment.
/// [target] — the user's WorkoutTarget config.
/// [routine] — the active routine.
PaceStatus computeOverallPaceStatus({
  required List<Duration> completedSplits,
  required Duration currentElapsed,
  required int currentIndex,
  required WorkoutTarget target,
  required Routine routine,
}) {
  if (target.isEmpty) return PaceStatus.none;

  // Sum of targets for completed segments + current
  Duration targetSum = Duration.zero;
  Duration actualSum = Duration.zero;

  for (int i = 0; i < completedSplits.length && i < routine.exercises.length; i++) {
    final t = target.targetForExercise(i, routine);
    if (t == null) return PaceStatus.none; // can't compute without target
    targetSum += t;
    actualSum += completedSplits[i];
  }

  // Add current segment
  if (currentIndex < routine.exercises.length) {
    final t = target.targetForExercise(currentIndex, routine);
    if (t == null) return PaceStatus.none;
    targetSum += t;
    actualSum += currentElapsed;
  }

  if (targetSum == Duration.zero) return PaceStatus.none;

  final ratio = actualSum.inMilliseconds / targetSum.inMilliseconds;
  if (ratio <= 0.95) return PaceStatus.ahead;
  if (ratio <= 1.05) return PaceStatus.onPace;
  return PaceStatus.behind;
}

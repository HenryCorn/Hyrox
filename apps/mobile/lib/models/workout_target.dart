import '../models/predefined_routines.dart';
import '../models/routine.dart';

/// Holds all user-configured target times and paces for a workout.
///
/// All fields are optional — users can set none, some, or all.
/// Run paces are stored as [Duration] per km (e.g. 5:30/km → Duration(minutes: 5, seconds: 30)).
class WorkoutTarget {
  const WorkoutTarget({
    this.globalTargetTime,
    this.globalRunPace,
    this.exerciseTargets = const {},
    this.runPaces = const {},
  });

  /// Target time for the entire workout.
  final Duration? globalTargetTime;

  /// Default pace per km applied to all runs without an individual override.
  final Duration? globalRunPace;

  /// Individual target times keyed by exercise index (0–15).
  final Map<int, Duration> exerciseTargets;

  /// Individual run paces (per km) keyed by exercise index (0–15).
  /// Only meaningful for run segments.
  final Map<int, Duration> runPaces;

  /// Whether the user has configured any targets at all.
  bool get isEmpty =>
      globalTargetTime == null &&
      globalRunPace == null &&
      exerciseTargets.isEmpty &&
      runPaces.isEmpty;

  /// Effective target duration for exercise at [index] in [routine].
  ///
  /// Priority:
  ///  1. Individual exercise target (exerciseTargets[index])
  ///  2. For runs: individual run pace → converted to duration (runPaces[index])
  ///  3. For runs: global run pace → converted to duration
  ///  4. null (no target for this segment)
  Duration? targetForExercise(int index, Routine routine) {
    // Direct exercise target always wins
    if (exerciseTargets.containsKey(index)) {
      return exerciseTargets[index];
    }

    final exercise = routine.exercises[index];
    final isRun = PredefinedRoutines.isRunSegment(exercise);

    if (isRun) {
      // Individual run pace
      if (runPaces.containsKey(index)) {
        return runPaces[index]; // pace per km = time for 1 km run
      }
      // Global run pace
      if (globalRunPace != null) {
        return globalRunPace;
      }
    }

    return null;
  }

  /// Sum of all resolvable individual targets. Returns null if any segment
  /// has no target (can't compute a meaningful total).
  Duration? computedTotalFromIndividuals(Routine routine) {
    Duration total = Duration.zero;
    for (int i = 0; i < routine.exercises.length; i++) {
      final t = targetForExercise(i, routine);
      if (t == null) return null;
      total += t;
    }
    return total;
  }

  /// Effective global target: explicit global if set, otherwise computed sum.
  Duration? effectiveGlobalTarget(Routine routine) {
    return globalTargetTime ?? computedTotalFromIndividuals(routine);
  }

  /// Validates that individual targets don't exceed the global target.
  /// Returns null if valid, or an error message string.
  String? validate(Routine routine) {
    if (globalTargetTime == null) return null;

    final computed = computedTotalFromIndividuals(routine);
    if (computed == null) return null; // can't validate without full coverage

    if (computed > globalTargetTime!) {
      final overBy = computed - globalTargetTime!;
      final mins = overBy.inMinutes;
      final secs = overBy.inSeconds.remainder(60);
      return 'Individual targets exceed global by ${mins}m ${secs}s';
    }

    return null;
  }

  WorkoutTarget copyWith({
    Duration? globalTargetTime,
    Duration? globalRunPace,
    Map<int, Duration>? exerciseTargets,
    Map<int, Duration>? runPaces,
    bool clearGlobalTargetTime = false,
    bool clearGlobalRunPace = false,
  }) {
    return WorkoutTarget(
      globalTargetTime: clearGlobalTargetTime
          ? null
          : (globalTargetTime ?? this.globalTargetTime),
      globalRunPace: clearGlobalRunPace
          ? null
          : (globalRunPace ?? this.globalRunPace),
      exerciseTargets: exerciseTargets ?? this.exerciseTargets,
      runPaces: runPaces ?? this.runPaces,
    );
  }
}

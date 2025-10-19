import 'routine.dart';

/// Represents a completed workout run with durations for each exercise.
class WorkoutRun {
  /// The routine that was followed during this run.
  final Routine routine;

  /// A list of durations corresponding to each exercise in the routine.
  /// The length of this list should match the number of exercises in [routine].
  final List<Duration> exerciseDurations;

  WorkoutRun({
    required this.routine,
    required this.exerciseDurations,
  }) : assert(exerciseDurations.length == routine.exercises.length,
        'Durations must match number of exercises');

  /// Computes the total duration of the workout by summing all exercise durations.
  Duration get totalDuration => exerciseDurations.fold(
      Duration.zero, (previous, element) => previous + element);
}

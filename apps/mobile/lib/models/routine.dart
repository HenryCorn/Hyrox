import 'exercise.dart';

/// A Hyrox workout routine consisting of multiple exercises.
class Routine {
  /// Display name of the routine (e.g. Men's Single, Women's Single).
  final String name;

  /// Ordered list of exercises to perform in this routine.
  final List<Exercise> exercises;

  const Routine({
    required this.name,
    required this.exercises,
  });

  /// Number of exercises in this routine.
  int get length => exercises.length;
}

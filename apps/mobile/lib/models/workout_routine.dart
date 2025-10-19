class WorkoutRoutine {
  final String id;
  final String name;
  final String description;
  final List<Exercise> exercises;
  final int totalDuration; // in seconds

  WorkoutRoutine({
    required this.id,
    required this.name,
    required this.description,
    required this.exercises,
    required this.totalDuration,
  });
}

class Exercise {
  final String name;
  final int duration; // in seconds
  final String? description;
  final double? weight; // in kg
  final String? weightNote;

  Exercise({
    required this.name,
    required this.duration,
    this.description,
    this.weight,
    this.weightNote,
  });
}
import 'workout_routine.dart';

enum HyroxCategory {
  menSingles,
  menPro,
  womenSingles,
  womenPro,
  doubles,
}

class HyroxWorkout {
  static WorkoutRoutine getWorkout(HyroxCategory category) {
    switch (category) {
      case HyroxCategory.menSingles:
        return WorkoutRoutine(
          id: 'hyrox_men_singles',
          name: 'HYROX Men Singles',
          description: 'Standard HYROX workout for men',
          exercises: _getStandardExercises(),
          totalDuration: 0, // No fixed duration for HYROX
        );
      // Add other categories as needed
      default:
        return WorkoutRoutine(
          id: 'hyrox_men_singles',
          name: 'HYROX Men Singles',
          description: 'Standard HYROX workout for men',
          exercises: _getStandardExercises(),
          totalDuration: 0,
        );
    }
  }

  static List<Exercise> _getStandardExercises() {
    return [
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'First 1km run',
      ),
      Exercise(
        name: 'Ski Erg',
        duration: 0,
        description: '1000m Ski Erg',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Second 1km run',
      ),
      Exercise(
        name: 'Sled Push',
        duration: 0,
        description: '50m Sled Push',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Third 1km run',
      ),
      Exercise(
        name: 'Sled Pull',
        duration: 0,
        description: '50m Sled Pull',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Fourth 1km run',
      ),
      Exercise(
        name: 'Burpee Broad Jumps',
        duration: 0,
        description: '80m Burpee Broad Jumps',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Fifth 1km run',
      ),
      Exercise(
        name: 'Rowing',
        duration: 0,
        description: '1000m Row',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Sixth 1km run',
      ),
      Exercise(
        name: 'Farmers Carry',
        duration: 0,
        description: '200m Farmers Carry',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Seventh 1km run',
      ),
      Exercise(
        name: 'Sandbag Lunges',
        duration: 0,
        description: '100m Sandbag Lunges',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Final 1km run',
      ),
    ];
  }
}
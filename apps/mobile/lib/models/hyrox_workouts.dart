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
          exercises: _getExercises(category),
          totalDuration: 0,
        );
      case HyroxCategory.menPro:
        return WorkoutRoutine(
          id: 'hyrox_men_pro',
          name: 'HYROX Men Pro',
          description: 'Professional HYROX workout for men',
          exercises: _getExercises(category),
          totalDuration: 0,
        );
      case HyroxCategory.womenSingles:
        return WorkoutRoutine(
          id: 'hyrox_women_singles',
          name: 'HYROX Women Singles',
          description: 'Standard HYROX workout for women',
          exercises: _getExercises(category),
          totalDuration: 0,
        );
      case HyroxCategory.womenPro:
        return WorkoutRoutine(
          id: 'hyrox_women_pro',
          name: 'HYROX Women Pro',
          description: 'Professional HYROX workout for women',
          exercises: _getExercises(category),
          totalDuration: 0,
        );
      case HyroxCategory.doubles:
        return WorkoutRoutine(
          id: 'hyrox_doubles',
          name: 'HYROX Doubles',
          description: 'HYROX workout for teams of two',
          exercises: _getExercises(category),
          totalDuration: 0,
        );
    }
  }

  static List<Exercise> _getExercises(HyroxCategory category) {
    // Define weights based on category
    double sledPushWeight;
    double sledPullWeight;
    double farmersCarryWeight;
    double sandbagWeight;

    switch (category) {
      case HyroxCategory.menSingles:
        sledPushWeight = 175;
        sledPullWeight = 125;
        farmersCarryWeight = 32;
        sandbagWeight = 20;
        break;
      case HyroxCategory.menPro:
        sledPushWeight = 200;
        sledPullWeight = 150;
        farmersCarryWeight = 35;
        sandbagWeight = 22.5;
        break;
      case HyroxCategory.womenSingles:
        sledPushWeight = 125;
        sledPullWeight = 75;
        farmersCarryWeight = 24;
        sandbagWeight = 15;
        break;
      case HyroxCategory.womenPro:
        sledPushWeight = 150;
        sledPullWeight = 100;
        farmersCarryWeight = 27;
        sandbagWeight = 17.5;
        break;
      case HyroxCategory.doubles:
        sledPushWeight = 175;
        sledPullWeight = 125;
        farmersCarryWeight = 32;
        sandbagWeight = 20;
        break;
    }
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
        weightNote: '1000m distance',
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
        weight: sledPushWeight,
        weightNote: '${sledPushWeight.toStringAsFixed(0)}kg sled',
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
        weight: sledPullWeight,
        weightNote: '${sledPullWeight.toStringAsFixed(0)}kg sled',
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
        weightNote: '8 sets of 10m',
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
        weightNote: '1000m distance',
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
        weight: farmersCarryWeight,
        weightNote: '${farmersCarryWeight.toStringAsFixed(0)}kg per hand',
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
        weight: sandbagWeight,
        weightNote: '${sandbagWeight.toStringAsFixed(1)}kg sandbag',
      ),
      Exercise(
        name: '1000m Run',
        duration: 0,
        description: 'Final 1km run',
      ),
    ];
  }
}
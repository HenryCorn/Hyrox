import 'exercise.dart';
import 'routine.dart';

/// Provides predefined Hyrox routines for different categories.
///
/// Each routine defines the ordered list of exercises performed in a
/// standard HYROX race for that category. Distances and weights are
/// included in the description field for reference. Times are not
/// represented here; durations are captured at runtime.
class PredefinedRoutines {
  static final Routine womenSingle = Routine(
    name: 'Women Single',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 102 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 78 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×16 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 10 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 4 kg ball'),
    ],
  );

  static final Routine womenPro = Routine(
    name: 'Women Pro',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 152 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 103 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×24 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 20 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 6 kg ball'),
    ],
  );

  static final Routine menSingle = Routine(
    name: 'Men Single',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 152 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 103 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×24 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 20 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 6 kg ball'),
    ],
  );

  static final Routine menPro = Routine(
    name: 'Men Pro',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 202 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 153 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×32 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 30 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 9 kg ball'),
    ],
  );

  static final Routine doublesWomen = Routine(
    name: 'Doubles Women',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 102 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 78 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×16 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 10 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 4 kg ball'),
    ],
  );

  static final Routine doublesMen = Routine(
    name: 'Doubles Men',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 152 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 103 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×24 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 20 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 6 kg ball'),
    ],
  );

  static final Routine doublesMixed = Routine(
    name: 'Doubles Mixed',
    exercises: [
      Exercise(name: '1 km Run', description: 'Start with a 1 km run'),
      Exercise(name: '1000 m SkiErg', description: 'SkiErg for 1,000 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Push', description: '2×25 m push, 152 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sled Pull', description: '2×25 m pull, 103 kg including sled'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Burpee Broad Jump', description: '80 m'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Rowing', description: '1000 m row'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Farmers Carry', description: '200 m with 2×24 kg kettlebells'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Sandbag Lunges', description: '100 m lunges with 20 kg sandbag'),
      Exercise(name: '1 km Run', description: ''),
      Exercise(name: 'Wall Balls', description: '100 reps with 6 kg ball'),
    ],
  );

  /// Map of routine names to routine objects for easy lookup.
  static final Map<String, Routine> all = {
    womenSingle.name: womenSingle,
    womenPro.name: womenPro,
    menSingle.name: menSingle,
    menPro.name: menPro,
    doublesWomen.name: doublesWomen,
    doublesMen.name: doublesMen,
    doublesMixed.name: doublesMixed,
  };
}

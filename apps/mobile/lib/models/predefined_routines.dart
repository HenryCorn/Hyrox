import 'exercise.dart';
import 'routine.dart';

/// Canonical Hyrox race format:
///   8 × 1 km runs interleaved with 8 workout stations.
///   Order: Run → SkiErg → Run → Sled Push → Run → Sled Pull →
///          Run → Burpee Broad Jump → Run → Row → Run → Farmers Carry →
///          Run → Sandbag Lunges → Run → Wall Balls
///
/// Weights / distances sourced from official Hyrox race guide 2024/25.
class PredefinedRoutines {
  // ── Station names (shared) ────────────────────────────────────────────────
  static Exercise _run(int number) => Exercise(
        name: '1 km Run $number',
        description: '1 km run — maintain target pace',
        weightNote: '1 km',
      );

  // ── Women Open ────────────────────────────────────────────────────────────
  static final Routine womenSingle = Routine(
    name: 'Women Open',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '1,000 m on the SkiErg',
        weightNote: '1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push',
        weight: 102,
        weightNote: '102 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull with harness',
        weight: 78,
        weightNote: '78 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '80 m forward burpee broad jumps',
        weightNote: '80 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '1,000 m on the rowing machine',
        weightNote: '1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry (2 × 100 m laps)',
        weight: 16,
        weightNote: '2 × 16 kg kettlebells',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m walking lunges with sandbag on shoulders',
        weight: 10,
        weightNote: '10 kg sandbag',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '75 reps · target height 9 ft (2.75 m)',
        weight: 4,
        weightNote: '4 kg ball',
      ),
    ],
  );

  // ── Women Pro ─────────────────────────────────────────────────────────────
  static final Routine womenPro = Routine(
    name: 'Women Pro',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '1,000 m on the SkiErg',
        weightNote: '1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push',
        weight: 102,
        weightNote: '102 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull with harness',
        weight: 78,
        weightNote: '78 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '100 m forward burpee broad jumps',
        weightNote: '100 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '1,000 m on the rowing machine',
        weightNote: '1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry (2 × 100 m laps)',
        weight: 24,
        weightNote: '2 × 24 kg kettlebells',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m walking lunges with sandbag on shoulders',
        weight: 10,
        weightNote: '10 kg sandbag',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '100 reps · target height 9 ft (2.75 m)',
        weight: 4,
        weightNote: '4 kg ball',
      ),
    ],
  );

  // ── Men Open ──────────────────────────────────────────────────────────────
  static final Routine menSingle = Routine(
    name: 'Men Open',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '1,000 m on the SkiErg',
        weightNote: '1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push',
        weight: 152,
        weightNote: '152 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull with harness',
        weight: 103,
        weightNote: '103 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '80 m forward burpee broad jumps',
        weightNote: '80 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '1,000 m on the rowing machine',
        weightNote: '1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry (2 × 100 m laps)',
        weight: 24,
        weightNote: '2 × 24 kg kettlebells',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m walking lunges with sandbag on shoulders',
        weight: 20,
        weightNote: '20 kg sandbag',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '100 reps · target height 10 ft (3.05 m)',
        weight: 6,
        weightNote: '6 kg ball',
      ),
    ],
  );

  // ── Men Pro ───────────────────────────────────────────────────────────────
  static final Routine menPro = Routine(
    name: 'Men Pro',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '1,000 m on the SkiErg',
        weightNote: '1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push',
        weight: 202,
        weightNote: '202 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull with harness',
        weight: 103,
        weightNote: '103 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '100 m forward burpee broad jumps',
        weightNote: '100 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '1,000 m on the rowing machine',
        weightNote: '1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry (2 × 100 m laps)',
        weight: 32,
        weightNote: '2 × 32 kg kettlebells',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m walking lunges with sandbag on shoulders',
        weight: 20,
        weightNote: '20 kg sandbag',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '150 reps · target height 10 ft (3.05 m)',
        weight: 6,
        weightNote: '6 kg ball',
      ),
    ],
  );

  // ── Doubles Women ─────────────────────────────────────────────────────────
  static final Routine doublesWomen = Routine(
    name: 'Doubles Women',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '2 × 1,000 m — each athlete 1,000 m',
        weightNote: '2 × 1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push — athletes alternate',
        weight: 102,
        weightNote: '102 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull — athletes alternate',
        weight: 78,
        weightNote: '78 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '2 × 80 m — each athlete 80 m',
        weightNote: '2 × 80 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '2 × 1,000 m — each athlete 1,000 m',
        weightNote: '2 × 1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry — athletes alternate',
        weight: 16,
        weightNote: '2 × 16 kg kettlebells',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m — athletes alternate every 25 m',
        weight: 10,
        weightNote: '10 kg sandbag',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '2 × 75 reps — each athlete 75 reps, 9 ft target',
        weight: 4,
        weightNote: '4 kg ball',
      ),
    ],
  );

  // ── Doubles Men ───────────────────────────────────────────────────────────
  static final Routine doublesMen = Routine(
    name: 'Doubles Men',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '2 × 1,000 m — each athlete 1,000 m',
        weightNote: '2 × 1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push — athletes alternate',
        weight: 152,
        weightNote: '152 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull — athletes alternate',
        weight: 103,
        weightNote: '103 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '2 × 80 m — each athlete 80 m',
        weightNote: '2 × 80 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '2 × 1,000 m — each athlete 1,000 m',
        weightNote: '2 × 1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry — athletes alternate',
        weight: 24,
        weightNote: '2 × 24 kg kettlebells',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m — athletes alternate every 25 m',
        weight: 20,
        weightNote: '20 kg sandbag',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '2 × 100 reps — each athlete 100 reps, 10 ft target',
        weight: 6,
        weightNote: '6 kg ball',
      ),
    ],
  );

  // ── Doubles Mixed ─────────────────────────────────────────────────────────
  static final Routine doublesMixed = Routine(
    name: 'Doubles Mixed',
    exercises: [
      _run(1),
      Exercise(
        name: 'SkiErg',
        description: '2 × 1,000 m — each athlete 1,000 m',
        weightNote: '2 × 1,000 m',
      ),
      _run(2),
      Exercise(
        name: 'Sled Push',
        description: '2 × 25 m push — athletes alternate',
        weight: 152,
        weightNote: '152 kg (incl. sled)',
      ),
      _run(3),
      Exercise(
        name: 'Sled Pull',
        description: '2 × 25 m pull — athletes alternate',
        weight: 78,
        weightNote: '78 kg (incl. sled)',
      ),
      _run(4),
      Exercise(
        name: 'Burpee Broad Jump',
        description: '2 × 80 m — each athlete 80 m',
        weightNote: '2 × 80 m',
      ),
      _run(5),
      Exercise(
        name: 'Rowing',
        description: '2 × 1,000 m — each athlete 1,000 m',
        weightNote: '2 × 1,000 m',
      ),
      _run(6),
      Exercise(
        name: 'Farmers Carry',
        description: '200 m carry — athletes alternate',
        weight: 20,
        weightNote: '2 × 20 kg (mixed avg.)',
      ),
      _run(7),
      Exercise(
        name: 'Sandbag Lunges',
        description: '200 m — athletes alternate every 25 m',
        weight: 15,
        weightNote: '15 kg sandbag (mixed avg.)',
      ),
      _run(8),
      Exercise(
        name: 'Wall Balls',
        description: '75 + 100 reps — woman 75 reps (9 ft), man 100 reps (10 ft)',
        weight: 5,
        weightNote: '4 kg + 6 kg balls',
      ),
    ],
  );

  static final Map<String, Routine> all = {
    womenSingle.name: womenSingle,
    womenPro.name: womenPro,
    menSingle.name: menSingle,
    menPro.name: menPro,
    doublesWomen.name: doublesWomen,
    doublesMen.name: doublesMen,
    doublesMixed.name: doublesMixed,
  };

  /// Returns the Routine for the given name, or null if not found.
  static Routine? byName(String name) => all[name];

  // ── Helpers ───────────────────────────────────────────────────────────────
  /// Returns true if the given exercise is a 1 km run segment.
  static bool isRunSegment(Exercise exercise) =>
      exercise.name.startsWith('1 km Run');

  /// Returns the run number for a run-segment exercise name (1–8), or null.
  static int? runNumber(Exercise exercise) {
    if (!isRunSegment(exercise)) return null;
    final parts = exercise.name.split(' ');
    return int.tryParse(parts.last);
  }

  /// Station index (1–8) for a non-run exercise.
  static int stationNumber(int exerciseIndex) =>
      (exerciseIndex / 2).ceil();
}

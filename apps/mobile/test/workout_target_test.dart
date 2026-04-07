import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/models/exercise.dart';
import 'package:hyrox_tracker/models/routine.dart';
import 'package:hyrox_tracker/models/workout_target.dart';
import 'package:hyrox_tracker/models/predefined_routines.dart';

/// A small 4-exercise routine: Run 1, SkiErg, Run 2, Sled Push.
/// Indices: 0 = Run 1 (run), 1 = SkiErg (station), 2 = Run 2 (run), 3 = Sled Push (station).
final _testRoutine = Routine(
  name: 'Test',
  exercises: [
    const Exercise(name: '1 km Run 1', description: '1 km run'),
    const Exercise(name: 'SkiErg', description: '1,000 m'),
    const Exercise(name: '1 km Run 2', description: '1 km run'),
    const Exercise(name: 'Sled Push', description: '2 × 25 m'),
  ],
);

void main() {
  group('WorkoutTarget.isEmpty', () {
    test('default constructor is empty', () {
      const target = WorkoutTarget();
      expect(target.isEmpty, isTrue);
    });

    test('not empty when globalTargetTime is set', () {
      const target = WorkoutTarget(
        globalTargetTime: Duration(hours: 1),
      );
      expect(target.isEmpty, isFalse);
    });

    test('not empty when globalRunPace is set', () {
      const target = WorkoutTarget(
        globalRunPace: Duration(minutes: 5, seconds: 30),
      );
      expect(target.isEmpty, isFalse);
    });

    test('not empty when exerciseTargets has entries', () {
      final target = WorkoutTarget(
        exerciseTargets: {0: const Duration(minutes: 5)},
      );
      expect(target.isEmpty, isFalse);
    });

    test('not empty when runPaces has entries', () {
      final target = WorkoutTarget(
        runPaces: {0: const Duration(minutes: 6)},
      );
      expect(target.isEmpty, isFalse);
    });
  });

  group('WorkoutTarget.targetForExercise', () {
    test('returns null when no targets are set', () {
      const target = WorkoutTarget();
      expect(target.targetForExercise(0, _testRoutine), isNull);
      expect(target.targetForExercise(1, _testRoutine), isNull);
    });

    test('individual exercise target takes highest priority', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 6),
        runPaces: {0: const Duration(minutes: 5)},
        exerciseTargets: {0: const Duration(minutes: 4)},
      );
      // exerciseTarget wins over runPace and globalRunPace
      expect(
        target.targetForExercise(0, _testRoutine),
        const Duration(minutes: 4),
      );
    });

    test('individual run pace is second priority for runs', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 6),
        runPaces: {0: const Duration(minutes: 5)},
      );
      expect(
        target.targetForExercise(0, _testRoutine),
        const Duration(minutes: 5),
      );
    });

    test('global run pace applies to runs without individual override', () {
      const target = WorkoutTarget(
        globalRunPace: Duration(minutes: 6),
      );
      // Index 0 is a run
      expect(
        target.targetForExercise(0, _testRoutine),
        const Duration(minutes: 6),
      );
      // Index 2 is also a run
      expect(
        target.targetForExercise(2, _testRoutine),
        const Duration(minutes: 6),
      );
    });

    test('global run pace does NOT apply to station segments', () {
      const target = WorkoutTarget(
        globalRunPace: Duration(minutes: 6),
      );
      // Index 1 is SkiErg (station)
      expect(target.targetForExercise(1, _testRoutine), isNull);
      // Index 3 is Sled Push (station)
      expect(target.targetForExercise(3, _testRoutine), isNull);
    });

    test('individual run pace does NOT apply to station segments', () {
      final target = WorkoutTarget(
        runPaces: {1: const Duration(minutes: 5)}, // index 1 is a station
      );
      // runPaces for a non-run index should be ignored
      expect(target.targetForExercise(1, _testRoutine), isNull);
    });

    test('exercise target applies to stations', () {
      final target = WorkoutTarget(
        exerciseTargets: {1: const Duration(minutes: 8)},
      );
      expect(
        target.targetForExercise(1, _testRoutine),
        const Duration(minutes: 8),
      );
    });

    test('mixed: global pace + individual station targets', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7), // SkiErg
          3: const Duration(minutes: 10), // Sled Push
        },
      );
      expect(
        target.targetForExercise(0, _testRoutine),
        const Duration(minutes: 5),
      ); // run → global pace
      expect(
        target.targetForExercise(1, _testRoutine),
        const Duration(minutes: 7),
      ); // station → exercise target
      expect(
        target.targetForExercise(2, _testRoutine),
        const Duration(minutes: 5),
      ); // run → global pace
      expect(
        target.targetForExercise(3, _testRoutine),
        const Duration(minutes: 10),
      ); // station → exercise target
    });

    test('individual run pace overrides global for specific run', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 6),
        runPaces: {2: const Duration(minutes: 4, seconds: 30)},
      );
      // Run 1 (index 0) uses global
      expect(
        target.targetForExercise(0, _testRoutine),
        const Duration(minutes: 6),
      );
      // Run 2 (index 2) uses individual
      expect(
        target.targetForExercise(2, _testRoutine),
        const Duration(minutes: 4, seconds: 30),
      );
    });
  });

  group('WorkoutTarget.computedTotalFromIndividuals', () {
    test('returns null when any segment has no target', () {
      const target = WorkoutTarget(
        globalRunPace: Duration(minutes: 5),
      );
      // Runs have targets, stations don't → null
      expect(target.computedTotalFromIndividuals(_testRoutine), isNull);
    });

    test('returns sum when all segments have targets', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      // 5 + 7 + 5 + 10 = 27 minutes
      expect(
        target.computedTotalFromIndividuals(_testRoutine),
        const Duration(minutes: 27),
      );
    });

    test('returns sum using all priority levels correctly', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 6),
        runPaces: {2: const Duration(minutes: 4)},
        exerciseTargets: {
          0: const Duration(minutes: 3), // overrides global pace for run 1
          1: const Duration(minutes: 8),
          3: const Duration(minutes: 9),
        },
      );
      // index 0: exerciseTarget = 3 min
      // index 1: exerciseTarget = 8 min
      // index 2: runPace = 4 min
      // index 3: exerciseTarget = 9 min
      // Total = 3 + 8 + 4 + 9 = 24 minutes
      expect(
        target.computedTotalFromIndividuals(_testRoutine),
        const Duration(minutes: 24),
      );
    });
  });

  group('WorkoutTarget.effectiveGlobalTarget', () {
    test('returns globalTargetTime when set', () {
      const target = WorkoutTarget(
        globalTargetTime: Duration(hours: 1, minutes: 30),
      );
      expect(
        target.effectiveGlobalTarget(_testRoutine),
        const Duration(hours: 1, minutes: 30),
      );
    });

    test('returns computed total when global is not set but all segments covered', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        target.effectiveGlobalTarget(_testRoutine),
        const Duration(minutes: 27),
      );
    });

    test('prefers explicit global over computed total', () {
      final target = WorkoutTarget(
        globalTargetTime: const Duration(hours: 1),
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        target.effectiveGlobalTarget(_testRoutine),
        const Duration(hours: 1),
      );
    });

    test('returns null when neither global nor full coverage', () {
      const target = WorkoutTarget();
      expect(target.effectiveGlobalTarget(_testRoutine), isNull);
    });
  });

  group('WorkoutTarget.validate', () {
    test('returns null when no global target set', () {
      final target = WorkoutTarget(
        exerciseTargets: {0: const Duration(hours: 99)},
      );
      expect(target.validate(_testRoutine), isNull);
    });

    test('returns null when individuals cannot be computed (partial coverage)', () {
      const target = WorkoutTarget(
        globalTargetTime: Duration(minutes: 30),
        globalRunPace: Duration(minutes: 5),
        // stations not covered → computedTotal is null → can't validate
      );
      expect(target.validate(_testRoutine), isNull);
    });

    test('returns null when individuals are within global', () {
      final target = WorkoutTarget(
        globalTargetTime: const Duration(minutes: 30),
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 8),
        },
      );
      // Sum = 5 + 7 + 5 + 8 = 25 min ≤ 30 min → valid
      expect(target.validate(_testRoutine), isNull);
    });

    test('returns error when individuals exceed global', () {
      final target = WorkoutTarget(
        globalTargetTime: const Duration(minutes: 20),
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      // Sum = 5 + 7 + 5 + 10 = 27 min > 20 min
      final error = target.validate(_testRoutine);
      expect(error, isNotNull);
      expect(error, contains('Individual targets exceed global'));
      expect(error, contains('7m 0s'));
    });

    test('returns null when individuals exactly equal global', () {
      final target = WorkoutTarget(
        globalTargetTime: const Duration(minutes: 27),
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(target.validate(_testRoutine), isNull);
    });
  });

  group('WorkoutTarget.copyWith', () {
    test('copies all fields', () {
      const original = WorkoutTarget(
        globalTargetTime: Duration(hours: 1),
        globalRunPace: Duration(minutes: 5),
      );
      final copied = original.copyWith(
        globalTargetTime: const Duration(hours: 2),
      );
      expect(copied.globalTargetTime, const Duration(hours: 2));
      expect(copied.globalRunPace, const Duration(minutes: 5));
    });

    test('clearGlobalTargetTime sets it to null', () {
      const original = WorkoutTarget(
        globalTargetTime: Duration(hours: 1),
      );
      final cleared = original.copyWith(clearGlobalTargetTime: true);
      expect(cleared.globalTargetTime, isNull);
    });

    test('clearGlobalRunPace sets it to null', () {
      const original = WorkoutTarget(
        globalRunPace: Duration(minutes: 5),
      );
      final cleared = original.copyWith(clearGlobalRunPace: true);
      expect(cleared.globalRunPace, isNull);
    });

    test('replaces exerciseTargets map', () {
      final original = WorkoutTarget(
        exerciseTargets: {0: const Duration(minutes: 5)},
      );
      final updated = original.copyWith(
        exerciseTargets: {1: const Duration(minutes: 8)},
      );
      expect(updated.exerciseTargets.containsKey(0), isFalse);
      expect(updated.exerciseTargets[1], const Duration(minutes: 8));
    });

    test('replaces runPaces map', () {
      final original = WorkoutTarget(
        runPaces: {0: const Duration(minutes: 6)},
      );
      final updated = original.copyWith(
        runPaces: {2: const Duration(minutes: 4)},
      );
      expect(updated.runPaces.containsKey(0), isFalse);
      expect(updated.runPaces[2], const Duration(minutes: 4));
    });
  });

  group('WorkoutTarget with predefined routines', () {
    test('global run pace applies to all 8 runs in Women Open', () {
      const target = WorkoutTarget(
        globalRunPace: Duration(minutes: 5, seconds: 30),
      );
      final routine = PredefinedRoutines.womenSingle;
      int runCount = 0;
      for (int i = 0; i < routine.exercises.length; i++) {
        final t = target.targetForExercise(i, routine);
        if (PredefinedRoutines.isRunSegment(routine.exercises[i])) {
          runCount++;
          expect(t, const Duration(minutes: 5, seconds: 30),
              reason: 'Run at index $i should use global pace');
        } else {
          expect(t, isNull,
              reason: 'Station at index $i should have no target');
        }
      }
      expect(runCount, 8);
    });

    test('full coverage produces correct total for Women Open', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 4), // SkiErg
          3: const Duration(minutes: 5), // Sled Push
          5: const Duration(minutes: 5), // Sled Pull
          7: const Duration(minutes: 6), // Burpee Broad Jump
          9: const Duration(minutes: 4), // Rowing
          11: const Duration(minutes: 3), // Farmers Carry
          13: const Duration(minutes: 8), // Sandbag Lunges
          15: const Duration(minutes: 5), // Wall Balls
        },
      );
      final routine = PredefinedRoutines.womenSingle;
      final total = target.computedTotalFromIndividuals(routine);
      // 8 runs × 5 min = 40 min
      // stations = 4 + 5 + 5 + 6 + 4 + 3 + 8 + 5 = 40 min
      // total = 80 min
      expect(total, const Duration(minutes: 80));
    });
  });
}

/// Tests for WorkoutTarget.targetForExercise priority order.
///
/// Priority (highest → lowest):
///   1. Individual exercise target  (exerciseTargets[i])
///   2. Individual run pace         (runPaces[i])        — run segments only
///   3. Global run pace             (globalRunPace)      — run segments only
///   4. null                        (no target)
///
/// Non-run segments (stations) only ever resolve via priority 1 or 4.
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/models/exercise.dart';
import 'package:hyrox_tracker/models/routine.dart';
import 'package:hyrox_tracker/models/workout_target.dart';

// ── Helpers ──────────────────────────────────────────────────────────────────

/// A run segment (name must start with '1 km Run').
Exercise get run => const Exercise(
      name: '1 km Run 1',
      description: '1 km run',
    );

/// A non-run station exercise.
Exercise get station => const Exercise(
      name: 'SkiErg',
      description: '1000m SkiErg',
    );

/// Routine: [run, station, run, station] at indices 0–3.
Routine get mixedRoutine => Routine(
      name: 'Test',
      exercises: [run, station, run, station],
    );

// ── Tests ─────────────────────────────────────────────────────────────────────

void main() {
  group('WorkoutTarget.targetForExercise — priority order', () {
    // ── Priority 4: no target ─────────────────────────────────────────────

    group('Priority 4 — null (no target configured)', () {
      test('returns null for a run when nothing is set', () {
        const target = WorkoutTarget();
        expect(target.targetForExercise(0, mixedRoutine), isNull);
      });

      test('returns null for a station when nothing is set', () {
        const target = WorkoutTarget();
        expect(target.targetForExercise(1, mixedRoutine), isNull);
      });
    });

    // ── Priority 3: global run pace ───────────────────────────────────────

    group('Priority 3 — global run pace (runs only)', () {
      const globalPace = Duration(minutes: 5, seconds: 30);

      test('run resolves to global run pace when no individual overrides', () {
        const target = WorkoutTarget(globalRunPace: globalPace);
        expect(target.targetForExercise(0, mixedRoutine), globalPace);
      });

      test('global run pace applies to every run segment', () {
        const target = WorkoutTarget(globalRunPace: globalPace);
        // index 0 and 2 are runs
        expect(target.targetForExercise(0, mixedRoutine), globalPace);
        expect(target.targetForExercise(2, mixedRoutine), globalPace);
      });

      test('global run pace does NOT apply to station segments', () {
        const target = WorkoutTarget(globalRunPace: globalPace);
        // index 1 and 3 are stations
        expect(target.targetForExercise(1, mixedRoutine), isNull);
        expect(target.targetForExercise(3, mixedRoutine), isNull);
      });
    });

    // ── Priority 2: individual run pace ──────────────────────────────────

    group('Priority 2 — individual run pace overrides global run pace', () {
      const globalPace = Duration(minutes: 5, seconds: 30);
      const individualPace = Duration(minutes: 4, seconds: 45);

      test('individual run pace wins over global run pace', () {
        final target = WorkoutTarget(
          globalRunPace: globalPace,
          runPaces: const {0: individualPace},
        );
        expect(target.targetForExercise(0, mixedRoutine), individualPace);
      });

      test('global pace still applies to runs without an individual override', () {
        final target = WorkoutTarget(
          globalRunPace: globalPace,
          runPaces: const {0: individualPace},
        );
        // index 2 has no individual pace — falls back to global
        expect(target.targetForExercise(2, mixedRoutine), globalPace);
      });

      test('individual run pace does NOT apply to stations at same index', () {
        // runPaces is indexed by exercise index; station at index 1 must not be
        // affected even if runPaces happens to contain key 1.
        final target = WorkoutTarget(
          runPaces: const {1: individualPace},
        );
        // index 1 is a station — run paces are irrelevant
        expect(target.targetForExercise(1, mixedRoutine), isNull);
      });
    });

    // ── Priority 1: individual exercise target ────────────────────────────

    group('Priority 1 — individual exercise target wins everything', () {
      const exerciseTarget = Duration(minutes: 6);
      const globalPace = Duration(minutes: 5, seconds: 30);
      const individualPace = Duration(minutes: 4, seconds: 45);

      test('exercise target beats global run pace for a run', () {
        final target = WorkoutTarget(
          globalRunPace: globalPace,
          exerciseTargets: const {0: exerciseTarget},
        );
        expect(target.targetForExercise(0, mixedRoutine), exerciseTarget);
      });

      test('exercise target beats individual run pace for a run', () {
        final target = WorkoutTarget(
          runPaces: const {0: individualPace},
          exerciseTargets: const {0: exerciseTarget},
        );
        expect(target.targetForExercise(0, mixedRoutine), exerciseTarget);
      });

      test('exercise target beats all other sources simultaneously', () {
        final target = WorkoutTarget(
          globalRunPace: globalPace,
          runPaces: const {0: individualPace},
          exerciseTargets: const {0: exerciseTarget},
        );
        expect(target.targetForExercise(0, mixedRoutine), exerciseTarget);
      });

      test('exercise target works for station segments', () {
        final target = WorkoutTarget(
          exerciseTargets: const {1: exerciseTarget},
        );
        expect(target.targetForExercise(1, mixedRoutine), exerciseTarget);
      });

      test('exercise target on one index does not affect adjacent index', () {
        final target = WorkoutTarget(
          exerciseTargets: const {0: exerciseTarget},
        );
        // index 1 (station) has no target
        expect(target.targetForExercise(1, mixedRoutine), isNull);
        // index 2 (run) has no individual target; also no global pace → null
        expect(target.targetForExercise(2, mixedRoutine), isNull);
      });
    });

    // ── Full priority chain ───────────────────────────────────────────────

    group('Full priority chain — all levels populated simultaneously', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5, seconds: 30),   // P3
        runPaces: const {0: Duration(minutes: 4, seconds: 45)},   // P2 at index 0
        exerciseTargets: const {
          0: Duration(minutes: 6),   // P1 at index 0 (run)
          1: Duration(minutes: 8),   // P1 at index 1 (station)
        },
      );

      test('P1 wins for run at index 0', () {
        expect(
          target.targetForExercise(0, mixedRoutine),
          const Duration(minutes: 6),
        );
      });

      test('P1 wins for station at index 1', () {
        expect(
          target.targetForExercise(1, mixedRoutine),
          const Duration(minutes: 8),
        );
      });

      test('P3 wins for run at index 2 (no P1/P2 override)', () {
        expect(
          target.targetForExercise(2, mixedRoutine),
          const Duration(minutes: 5, seconds: 30),
        );
      });

      test('null for station at index 3 (stations ignore run paces)', () {
        expect(target.targetForExercise(3, mixedRoutine), isNull);
      });
    });
  });
}

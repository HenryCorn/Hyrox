import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/models/exercise.dart';
import 'package:hyrox_tracker/models/routine.dart';
import 'package:hyrox_tracker/models/workout_target.dart';
import 'package:hyrox_tracker/providers/target_provider.dart';

/// 4-exercise test routine: Run, Station, Run, Station.
final _testRoutine = Routine(
  name: 'Test',
  exercises: [
    const Exercise(name: '1 km Run 1', description: ''),
    const Exercise(name: 'SkiErg', description: ''),
    const Exercise(name: '1 km Run 2', description: ''),
    const Exercise(name: 'Sled Push', description: ''),
  ],
);

void main() {
  group('computePaceStatus', () {
    test('returns none when target is null', () {
      expect(
        computePaceStatus(const Duration(minutes: 3), null),
        PaceStatus.none,
      );
    });

    test('returns none when target is zero', () {
      expect(
        computePaceStatus(const Duration(minutes: 3), Duration.zero),
        PaceStatus.none,
      );
    });

    test('returns ahead when well under target', () {
      // 4 min elapsed of 10 min target = 0.4 ratio
      expect(
        computePaceStatus(
          const Duration(minutes: 4),
          const Duration(minutes: 10),
        ),
        PaceStatus.ahead,
      );
    });

    test('returns ahead at exactly 0% elapsed', () {
      expect(
        computePaceStatus(Duration.zero, const Duration(minutes: 5)),
        PaceStatus.ahead,
      );
    });

    test('returns ahead at boundary (ratio = 0.95)', () {
      // 950 ms of 1000 ms target = 0.95
      expect(
        computePaceStatus(
          const Duration(milliseconds: 950),
          const Duration(milliseconds: 1000),
        ),
        PaceStatus.ahead,
      );
    });

    test('returns onPace just above 0.95', () {
      // 951 ms of 1000 ms target = 0.951
      expect(
        computePaceStatus(
          const Duration(milliseconds: 951),
          const Duration(milliseconds: 1000),
        ),
        PaceStatus.onPace,
      );
    });

    test('returns onPace at exactly target time (ratio = 1.0)', () {
      expect(
        computePaceStatus(
          const Duration(minutes: 5),
          const Duration(minutes: 5),
        ),
        PaceStatus.onPace,
      );
    });

    test('returns onPace at boundary (ratio = 1.05)', () {
      // 1050 ms of 1000 ms target = 1.05
      expect(
        computePaceStatus(
          const Duration(milliseconds: 1050),
          const Duration(milliseconds: 1000),
        ),
        PaceStatus.onPace,
      );
    });

    test('returns behind just above 1.05', () {
      // 1051 ms of 1000 ms target = 1.051
      expect(
        computePaceStatus(
          const Duration(milliseconds: 1051),
          const Duration(milliseconds: 1000),
        ),
        PaceStatus.behind,
      );
    });

    test('returns behind when well over target', () {
      // 8 min elapsed of 5 min target = 1.6 ratio
      expect(
        computePaceStatus(
          const Duration(minutes: 8),
          const Duration(minutes: 5),
        ),
        PaceStatus.behind,
      );
    });
  });

  group('computeOverallPaceStatus', () {
    test('returns none when target is empty', () {
      expect(
        computeOverallPaceStatus(
          completedSplits: [],
          currentElapsed: const Duration(minutes: 3),
          currentIndex: 0,
          target: const WorkoutTarget(),
          routine: _testRoutine,
        ),
        PaceStatus.none,
      );
    });

    test('returns none when a completed segment has no target', () {
      // Only runs have targets (global pace), station at index 1 has none
      expect(
        computeOverallPaceStatus(
          completedSplits: [
            const Duration(minutes: 5), // index 0 — run (has target)
            const Duration(minutes: 7), // index 1 — SkiErg (NO target)
          ],
          currentElapsed: const Duration(minutes: 2),
          currentIndex: 2,
          target: const WorkoutTarget(
            globalRunPace: Duration(minutes: 5),
          ),
          routine: _testRoutine,
        ),
        PaceStatus.none,
      );
    });

    test('returns none when current segment has no target', () {
      expect(
        computeOverallPaceStatus(
          completedSplits: [
            const Duration(minutes: 5), // index 0 — run
          ],
          currentElapsed: const Duration(minutes: 3),
          currentIndex: 1, // SkiErg — no target
          target: const WorkoutTarget(
            globalRunPace: Duration(minutes: 5),
          ),
          routine: _testRoutine,
        ),
        PaceStatus.none,
      );
    });

    test('returns ahead when cumulative time is well under target', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        computeOverallPaceStatus(
          completedSplits: [
            const Duration(minutes: 4), // target 5 min
            const Duration(minutes: 5), // target 7 min
          ],
          currentElapsed: const Duration(minutes: 2), // target 5 min
          currentIndex: 2,
          target: target,
          routine: _testRoutine,
        ),
        // actual: 4 + 5 + 2 = 11 min, target: 5 + 7 + 5 = 17 min
        // ratio = 11/17 ≈ 0.647 → ahead
        PaceStatus.ahead,
      );
    });

    test('returns onPace when cumulative time is near target', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        computeOverallPaceStatus(
          completedSplits: [
            const Duration(minutes: 5), // target 5
            const Duration(minutes: 7), // target 7
          ],
          currentElapsed: const Duration(minutes: 5), // target 5
          currentIndex: 2,
          target: target,
          routine: _testRoutine,
        ),
        // actual: 5 + 7 + 5 = 17, target: 5 + 7 + 5 = 17
        // ratio = 1.0 → onPace
        PaceStatus.onPace,
      );
    });

    test('returns behind when cumulative time is well over target', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        computeOverallPaceStatus(
          completedSplits: [
            const Duration(minutes: 7), // target 5
            const Duration(minutes: 10), // target 7
          ],
          currentElapsed: const Duration(minutes: 8), // target 5
          currentIndex: 2,
          target: target,
          routine: _testRoutine,
        ),
        // actual: 7 + 10 + 8 = 25, target: 5 + 7 + 5 = 17
        // ratio = 25/17 ≈ 1.47 → behind
        PaceStatus.behind,
      );
    });

    test('works with no completed splits (first segment)', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        computeOverallPaceStatus(
          completedSplits: [],
          currentElapsed: const Duration(minutes: 2),
          currentIndex: 0,
          target: target,
          routine: _testRoutine,
        ),
        // actual: 2, target: 5 → ratio = 0.4 → ahead
        PaceStatus.ahead,
      );
    });

    test('works when all segments are completed (currentIndex past end)', () {
      final target = WorkoutTarget(
        globalRunPace: const Duration(minutes: 5),
        exerciseTargets: {
          1: const Duration(minutes: 7),
          3: const Duration(minutes: 10),
        },
      );
      expect(
        computeOverallPaceStatus(
          completedSplits: [
            const Duration(minutes: 5),
            const Duration(minutes: 7),
            const Duration(minutes: 5),
            const Duration(minutes: 10),
          ],
          currentElapsed: Duration.zero,
          currentIndex: 4, // past end
          target: target,
          routine: _testRoutine,
        ),
        // actual = target = 27 min, ratio = 1.0 → onPace
        PaceStatus.onPace,
      );
    });
  });
}

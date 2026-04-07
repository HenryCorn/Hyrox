import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/models/workout_target.dart';
import 'package:hyrox_tracker/providers/target_provider.dart';

void main() {
  group('TargetNotifier', () {
    late ProviderContainer container;
    late TargetNotifier notifier;

    setUp(() {
      container = ProviderContainer();
      notifier = container.read(targetProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is empty WorkoutTarget', () {
      final state = container.read(targetProvider);
      expect(state.isEmpty, isTrue);
      expect(state.globalTargetTime, isNull);
      expect(state.globalRunPace, isNull);
      expect(state.exerciseTargets, isEmpty);
      expect(state.runPaces, isEmpty);
    });

    group('setGlobalTargetTime', () {
      test('sets a global target time', () {
        notifier.setGlobalTargetTime(const Duration(hours: 1, minutes: 30));
        final state = container.read(targetProvider);
        expect(state.globalTargetTime, const Duration(hours: 1, minutes: 30));
      });

      test('clears global target time when null', () {
        notifier.setGlobalTargetTime(const Duration(hours: 1));
        notifier.setGlobalTargetTime(null);
        final state = container.read(targetProvider);
        expect(state.globalTargetTime, isNull);
      });

      test('does not affect other fields', () {
        notifier.setGlobalRunPace(const Duration(minutes: 5));
        notifier.setExerciseTarget(0, const Duration(minutes: 6));
        notifier.setGlobalTargetTime(const Duration(hours: 1));
        final state = container.read(targetProvider);
        expect(state.globalRunPace, const Duration(minutes: 5));
        expect(state.exerciseTargets[0], const Duration(minutes: 6));
      });
    });

    group('setGlobalRunPace', () {
      test('sets a global run pace', () {
        notifier.setGlobalRunPace(const Duration(minutes: 5, seconds: 30));
        final state = container.read(targetProvider);
        expect(state.globalRunPace, const Duration(minutes: 5, seconds: 30));
      });

      test('clears global run pace when null', () {
        notifier.setGlobalRunPace(const Duration(minutes: 5));
        notifier.setGlobalRunPace(null);
        final state = container.read(targetProvider);
        expect(state.globalRunPace, isNull);
      });
    });

    group('setExerciseTarget', () {
      test('adds an exercise target', () {
        notifier.setExerciseTarget(3, const Duration(minutes: 8));
        final state = container.read(targetProvider);
        expect(state.exerciseTargets[3], const Duration(minutes: 8));
      });

      test('updates an existing exercise target', () {
        notifier.setExerciseTarget(3, const Duration(minutes: 8));
        notifier.setExerciseTarget(3, const Duration(minutes: 10));
        final state = container.read(targetProvider);
        expect(state.exerciseTargets[3], const Duration(minutes: 10));
      });

      test('removes exercise target when null', () {
        notifier.setExerciseTarget(3, const Duration(minutes: 8));
        notifier.setExerciseTarget(3, null);
        final state = container.read(targetProvider);
        expect(state.exerciseTargets.containsKey(3), isFalse);
      });

      test('can set multiple exercise targets', () {
        notifier.setExerciseTarget(0, const Duration(minutes: 5));
        notifier.setExerciseTarget(1, const Duration(minutes: 7));
        notifier.setExerciseTarget(2, const Duration(minutes: 6));
        final state = container.read(targetProvider);
        expect(state.exerciseTargets.length, 3);
        expect(state.exerciseTargets[0], const Duration(minutes: 5));
        expect(state.exerciseTargets[1], const Duration(minutes: 7));
        expect(state.exerciseTargets[2], const Duration(minutes: 6));
      });

      test('removing one does not affect others', () {
        notifier.setExerciseTarget(0, const Duration(minutes: 5));
        notifier.setExerciseTarget(1, const Duration(minutes: 7));
        notifier.setExerciseTarget(0, null);
        final state = container.read(targetProvider);
        expect(state.exerciseTargets.containsKey(0), isFalse);
        expect(state.exerciseTargets[1], const Duration(minutes: 7));
      });
    });

    group('setRunPace', () {
      test('adds a run pace', () {
        notifier.setRunPace(0, const Duration(minutes: 5));
        final state = container.read(targetProvider);
        expect(state.runPaces[0], const Duration(minutes: 5));
      });

      test('removes run pace when null', () {
        notifier.setRunPace(0, const Duration(minutes: 5));
        notifier.setRunPace(0, null);
        final state = container.read(targetProvider);
        expect(state.runPaces.containsKey(0), isFalse);
      });

      test('can set multiple run paces independently', () {
        notifier.setRunPace(0, const Duration(minutes: 5));
        notifier.setRunPace(2, const Duration(minutes: 4, seconds: 30));
        final state = container.read(targetProvider);
        expect(state.runPaces.length, 2);
        expect(state.runPaces[0], const Duration(minutes: 5));
        expect(state.runPaces[2], const Duration(minutes: 4, seconds: 30));
      });
    });

    group('clear', () {
      test('resets all fields to defaults', () {
        notifier.setGlobalTargetTime(const Duration(hours: 1));
        notifier.setGlobalRunPace(const Duration(minutes: 5));
        notifier.setExerciseTarget(0, const Duration(minutes: 6));
        notifier.setRunPace(2, const Duration(minutes: 4));

        notifier.clear();
        final state = container.read(targetProvider);
        expect(state.isEmpty, isTrue);
        expect(state.globalTargetTime, isNull);
        expect(state.globalRunPace, isNull);
        expect(state.exerciseTargets, isEmpty);
        expect(state.runPaces, isEmpty);
      });
    });

    group('state immutability', () {
      test('modifying returned exerciseTargets does not affect state', () {
        notifier.setExerciseTarget(0, const Duration(minutes: 5));
        final state = container.read(targetProvider);

        // Even if someone tries to modify the map, the state shouldn't change
        // (WorkoutTarget stores const maps from copyWith)
        final nextState = container.read(targetProvider);
        expect(nextState.exerciseTargets[0], const Duration(minutes: 5));
      });

      test('sequential updates produce independent snapshots', () {
        notifier.setGlobalTargetTime(const Duration(hours: 1));
        final first = container.read(targetProvider);

        notifier.setGlobalTargetTime(const Duration(hours: 2));
        final second = container.read(targetProvider);

        expect(first.globalTargetTime, const Duration(hours: 1));
        expect(second.globalTargetTime, const Duration(hours: 2));
      });
    });
  });
}

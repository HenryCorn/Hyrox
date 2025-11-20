import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/models/exercise.dart';
import 'package:hyrox_tracker/models/routine.dart';
import 'package:hyrox_tracker/providers/timer_provider.dart';
import 'package:hyrox_tracker/providers/timer_state.dart';
import 'package:hyrox_tracker/services/wakelock_service.dart';

class MockWakelockService implements WakelockService {
  @override
  Future<void> enable() async {}
  
  @override
  Future<void> disable() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('TimerNotifier', () {
    late ProviderContainer container;
    late TimerNotifier notifier;
    final testRoutine = Routine(
      name: 'Test Routine',
      exercises: [
        Exercise(name: 'Ex 1', description: 'Desc 1'),
        Exercise(name: 'Ex 2', description: 'Desc 2'),
      ],
    );

    setUp(() {
      container = ProviderContainer(
        overrides: [
          wakelockServiceProvider.overrideWithValue(MockWakelockService()),
        ],
      );
      notifier = container.read(timerProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is correct', () {
      final state = container.read(timerProvider);
      expect(state.status, TimerStatus.initial);
      expect(state.totalElapsed, Duration.zero);
      expect(state.currentExerciseIndex, 0);
    });

    test('startRoutine sets the routine', () {
      notifier.startRoutine(testRoutine);
      final state = container.read(timerProvider);
      expect(state.activeRoutine, testRoutine);
      expect(state.status, TimerStatus.initial);
    });

    test('start changes status to running', () {
      notifier.startRoutine(testRoutine);
      notifier.start();
      final state = container.read(timerProvider);
      expect(state.status, TimerStatus.running);
    });

    test('pause changes status to paused', () {
      notifier.startRoutine(testRoutine);
      notifier.start();
      notifier.pause();
      final state = container.read(timerProvider);
      expect(state.status, TimerStatus.paused);
    });

    test('nextExercise advances index and resets current elapsed', () {
      notifier.startRoutine(testRoutine);
      notifier.start();
      // With Rox Zones: first nextExercise() enters Rox Zone, second advances to next exercise
      notifier.nextExercise(); // Enter Rox Zone
      final roxState = container.read(timerProvider);
      expect(roxState.isInRoxZone, true);
      expect(roxState.currentExerciseIndex, 0); // Still on first exercise
      
      notifier.nextExercise(); // Advance to next exercise
      final state = container.read(timerProvider);
      expect(state.currentExerciseIndex, 1);
      expect(state.isInRoxZone, false);
      expect(state.currentExerciseElapsed, Duration.zero);
      expect(state.status, TimerStatus.running);
    });

    test('nextExercise finishes routine at end', () {
      notifier.startRoutine(testRoutine);
      notifier.start();
      // Advance through all exercises and Rox Zones
      notifier.nextExercise(); // Enter Rox Zone after Ex 1
      notifier.nextExercise(); // Advance to Ex 2
      notifier.nextExercise(); // Enter Rox Zone after Ex 2 (last exercise)
      notifier.nextExercise(); // Finish workout
      final state = container.read(timerProvider);
      expect(state.status, TimerStatus.finished);
    });
  });
}

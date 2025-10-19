import 'package:flutter_test/flutter_test.dart';

import 'package:hyrox_tracker/models/exercise.dart';
import 'package:hyrox_tracker/models/routine.dart';
import 'package:hyrox_tracker/services/timer_service.dart';

void main() {
  group('TimerService', () {
    test('should accumulate durations across exercises', () async {
      final routine = Routine(
        name: 'Test',
        exercises: const [
          Exercise(name: 'ex1', description: ''),
          Exercise(name: 'ex2', description: ''),
          Exercise(name: 'ex3', description: ''),
        ],
      );
      final service = TimerService(routine);
      service.start();
      // Exercise 1: wait 20ms
      await Future.delayed(const Duration(milliseconds: 20));
      service.nextExercise();
      // Exercise 2: wait 30ms
      await Future.delayed(const Duration(milliseconds: 30));
      // Stop without going to exercise 3
      service.stop();

      // expect there are two durations recorded (last exercise not yet ended)
      expect(service.exerciseDurations.length, equals(2));
      expect(service.exerciseDurations[0] > Duration.zero, isTrue);
      expect(service.exerciseDurations[1] > Duration.zero, isTrue);
      // total elapsed should be greater than any individual duration
      expect(service.totalElapsed > service.exerciseDurations[0], isTrue);
      expect(service.totalElapsed > service.exerciseDurations[1], isTrue);
      service.dispose();
    });

    test('should pause and resume properly', () async {
      final routine = Routine(
        name: 'Test',
        exercises: const [
          Exercise(name: 'ex1', description: ''),
          Exercise(name: 'ex2', description: ''),
        ],
      );
      final service = TimerService(routine);
      service.start();
      await Future.delayed(const Duration(milliseconds: 20));
      service.pause();
      final elapsedPaused = service.currentExerciseElapsed;
      await Future.delayed(const Duration(milliseconds: 20));
      // While paused, elapsed time shouldn't change significantly
      expect(service.currentExerciseElapsed.inMilliseconds,
          closeTo(elapsedPaused.inMilliseconds, 5));
      service.resume();
      await Future.delayed(const Duration(milliseconds: 20));
      expect(service.currentExerciseElapsed > elapsedPaused, isTrue);
      service.stop();
      service.dispose();
    });
  });
}

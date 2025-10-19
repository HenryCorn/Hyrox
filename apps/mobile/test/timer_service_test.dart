import 'package:test/test.dart';
import '../lib/models/exercise.dart';
import '../lib/models/routine.dart';
import '../lib/services/timer_service.dart';

void main() {
  group('TimerService', () {
    test('should accumulate durations across exercises', () async {
      final routine = Routine('Test', [
        Exercise('ex1', ''),
        Exercise('ex2', ''),
        Exercise('ex3', ''),
      ]);
      final service = TimerService(routine);
      service.start();
      // wait a bit, then go to next exercise
      await Future.delayed(Duration(milliseconds: 20));
      service.nextExercise();
      await Future.delayed(Duration(milliseconds: 30));
      service.nextExercise();
      await Future.delayed(Duration(milliseconds: 40));
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
      final routine = Routine('Test', [
        Exercise('ex1', ''),
        Exercise('ex2', ''),
      ]);
      final service = TimerService(routine);
      service.start();
      await Future.delayed(Duration(milliseconds: 20));
      service.pause();
      final elapsedPaused = service.currentExerciseElapsed;
      await Future.delayed(Duration(milliseconds: 20));
      // While paused, elapsed time shouldn't change significantly
      expect(service.currentExerciseElapsed.inMilliseconds,
          closeTo(elapsedPaused.inMilliseconds, 5));
      service.resume();
      await Future.delayed(Duration(milliseconds: 20));
      expect(service.currentExerciseElapsed > elapsedPaused, isTrue);
      service.stop();
      service.dispose();
    });
  });
}

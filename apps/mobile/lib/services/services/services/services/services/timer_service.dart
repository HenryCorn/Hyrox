import 'dart:async';

import '../models/routine.dart';

/// A service that manages timing a workout routine and tracks per exercise and total durations.
/// It supports starting, pausing, resuming, moving to the next exercise, and resetting.
/// The service uses [Stopwatch] internally to avoid relying on `DateTime` and can notify listeners
/// through a broadcast stream on every tick.
///
/// This engine does not integrate with UI directly; the UI can listen to [tickStream]
/// and read [currentExerciseElapsed] and [totalElapsed].
class TimerService {
  TimerService(this.routine) {
    _exerciseStopwatch = Stopwatch();
    _totalStopwatch = Stopwatch();
  }

  /// The routine being timed.
  final Routine routine;

  /// Index of the current exercise.
  int _currentIndex = 0;

  /// Whether the timer has been started.
  bool _isRunning = false;

  /// Whether the timer is currently paused.
  bool _isPaused = false;

  late Stopwatch _exerciseStopwatch;
  late Stopwatch _totalStopwatch;

  Timer? _timer;

  // List of durations recorded for completed exercises.
  final List<Duration> _exerciseDurations = [];

  /// Stream controller broadcasting elapsed times for the current exercise.
  final _tickController = StreamController<Duration>.broadcast();

  /// A stream that emits the elapsed duration of the current exercise periodically.
  Stream<Duration> get tickStream => _tickController.stream;

  /// Read‑only list of recorded exercise durations.
  List<Duration> get exerciseDurations => List.unmodifiable(_exerciseDurations);

  /// Index of the current exercise.
  int get currentIndex => _currentIndex;

  /// Whether the timer is running.
  bool get isRunning => _isRunning;

  /// Whether the timer is paused.
  bool get isPaused => _isPaused;

  /// Elapsed time for the current exercise.
  Duration get currentExerciseElapsed => _exerciseStopwatch.elapsed;

  /// Elapsed time since the workout started.
  Duration get totalElapsed => _totalStopwatch.elapsed;

  /// Starts timing the routine. Does nothing if already running.
  void start() {
    if (_isRunning) return;
    _isRunning = true;
    _isPaused = false;
    _currentIndex = 0;
    _exerciseDurations.clear();
    _exerciseStopwatch
      ..reset()
      ..start();
    _totalStopwatch
      ..reset()
      ..start();
    _startTicker();
  }

  void _startTicker() {
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _tickController.add(_exerciseStopwatch.elapsed);
    });
  }

  /// Pauses the timer. Does nothing if not running or already paused.
  void pause() {
    if (!_isRunning || _isPaused) return;
    _isPaused = true;
    _exerciseStopwatch.stop();
    _totalStopwatch.stop();
    _timer?.cancel();
  }

  /// Resumes timing after a pause. Does nothing if not paused.
  void resume() {
    if (!_isRunning || !_isPaused) return;
    _isPaused = false;
    _exerciseStopwatch.start();
    _totalStopwatch.start();
    _startTicker();
  }

  /// Advances to the next exercise, recording the elapsed time of the current one.
  /// If the last exercise has been completed, this stops the timer.
  void nextExercise() {
    if (!_isRunning) return;
    // Record the duration for the current exercise.
    _exerciseStopwatch.stop();
    _exerciseDurations.add(_exerciseStopwatch.elapsed);
    _currentIndex++;
    if (_currentIndex >= routine.exercises.length) {
      stop();
      return;
    }
    // Start timing the next exercise.
    _exerciseStopwatch = Stopwatch()..start();
    // Restart ticker for the new exercise.
    _startTicker();
  }

  /// Stops the timer, recording the final exercise duration if needed.
  void stop() {
    if (!_isRunning) return;
    _isRunning = false;
    _isPaused = false;
    _timer?.cancel();
    // Record last exercise if not already added.
    if (_exerciseStopwatch.isRunning || _exerciseDurations.length < routine.exercises.length) {
      _exerciseStopwatch.stop();
      _exerciseDurations.add(_exerciseStopwatch.elapsed);
    }
    _totalStopwatch.stop();
    // Emit final tick.
    _tickController.add(_exerciseStopwatch.elapsed);
  }

  /// Resets the service to initial state. Does not emit a tick.
  void reset() {
    _timer?.cancel();
    _exerciseStopwatch.stop();
    _totalStopwatch.stop();
    _exerciseDurations.clear();
    _currentIndex = 0;
    _isRunning = false;
    _isPaused = false;
    _exerciseStopwatch = Stopwatch();
    _totalStopwatch = Stopwatch();
  }

  /// Disposes resources such as the tick stream.
  void dispose() {
    _timer?.cancel();
    _tickController.close();
  }
}

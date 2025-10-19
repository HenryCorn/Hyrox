import 'dart:async';
import 'package:flutter/material.dart';
import 'package:screen_brightness/screen_brightness.dart';
import '../models/workout_routine.dart';
import '../theme/workout_theme.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutRoutine routine;

  const ActiveWorkoutScreen({
    super.key,
    required this.routine,
  });

  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  bool _isRunning = false;
  int _currentExerciseIndex = 0;
  int _exerciseStartTime = 0;
  final Stopwatch _stopwatch = Stopwatch();
  late Timer _timer;

  int get _exerciseElapsedTime => _stopwatch.elapsed.inSeconds - _exerciseStartTime;
  int get _totalElapsedTime => _stopwatch.elapsed.inSeconds;

  @override
  void initState() {
    super.initState();
    _keepScreenOn();
    _initializeTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
    _stopwatch.stop();
    ScreenBrightness().resetScreenBrightness();
    super.dispose();
  }

  Future<void> _keepScreenOn() async {
    try {
      await ScreenBrightness().setScreenBrightness(1.0);
    } catch (e) {
      debugPrint('Failed to keep screen on: $e');
    }
  }

  void _initializeTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (_isRunning) {
        setState(() {
          // Update UI more frequently for smoother display
        });
      }
    });
  }

  void _moveToNextExercise() {
    if (_currentExerciseIndex < widget.routine.exercises.length - 1) {
      setState(() {
        _currentExerciseIndex++;
        _exerciseStartTime = _stopwatch.elapsed.inSeconds;
      });
    } else {
      _completeWorkout();
    }
  }

  void _toggleTimer() {
    setState(() {
      _isRunning = !_isRunning;
      if (_isRunning) {
        if (_stopwatch.elapsed.inSeconds == 0) {
          // First start
          _exerciseStartTime = 0;
        }
        _stopwatch.start();
      } else {
        _stopwatch.stop();
      }
    });
  }

  void _completeWorkout() {
    _stopwatch.stop();
    _isRunning = false;
    _timer.cancel();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: WorkoutTheme.surfaceBlack,
        titleTextStyle: const TextStyle(color: WorkoutTheme.primaryYellow),
        title: const Text('Workout Complete!'),
        contentTextStyle: const TextStyle(color: WorkoutTheme.textWhite),
        content: Text(
          'Total time: ${_formatTime(_totalElapsedTime)}',
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: WorkoutTheme.primaryYellow,
            ),
            onPressed: () => Navigator.of(context)
                .popUntil((route) => route.isFirst),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _restartWorkout() {
    setState(() {
      _currentExerciseIndex = 0;
      _exerciseStartTime = 0;
      _isRunning = false;
      _stopwatch.reset();
    });
  }

  Exercise get currentExercise => 
      widget.routine.exercises[_currentExerciseIndex];

  Exercise? get previousExercise =>
      _currentExerciseIndex > 0 
          ? widget.routine.exercises[_currentExerciseIndex - 1]
          : null;

  Exercise? get nextExercise =>
      _currentExerciseIndex < widget.routine.exercises.length - 1
          ? widget.routine.exercises[_currentExerciseIndex + 1]
          : null;

  String _formatTime(int seconds) {
    final minutes = (seconds / 60).floor();
    final remainingSeconds = seconds % 60;
    return '${minutes.toString()}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkoutTheme.backgroundBlack,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            const Spacer(),
            _buildExerciseInfo(),
            const Spacer(),
            _buildTimer(),
            const Spacer(flex: 2),
            _buildControls(),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.close, color: WorkoutTheme.textWhite),
            onPressed: () => Navigator.pop(context),
          ),
          const Spacer(),
          Text(
            widget.routine.name,
            style: WorkoutTheme.routineNameStyle,
          ),
          const Spacer(),
          Text(
            _formatTime(_totalElapsedTime),
            style: WorkoutTheme.totalTimerTextStyle,
          ),
        ],
      ),
    );
  }

  Widget _buildExerciseInfo() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (previousExercise != null) ...[
          Text(
            'Previous: ${previousExercise!.name}',
            style: WorkoutTheme.exerciseNameStyle,
          ),
          const SizedBox(height: 16),
        ],
        Text(
          currentExercise.name,
          style: WorkoutTheme.exerciseLabelStyle.copyWith(
            fontSize: 32,
          ),
        ),
        if (currentExercise.weightNote != null) ...[
          const SizedBox(height: 8),
          Text(
            currentExercise.weightNote!,
            style: WorkoutTheme.exerciseNameStyle.copyWith(
              color: WorkoutTheme.primaryYellow,
              fontSize: 18,
            ),
          ),
        ],
        if (nextExercise != null) ...[
          const SizedBox(height: 16),
          Text(
            'Next: ${nextExercise!.name}',
            style: WorkoutTheme.exerciseNameStyle,
          ),
          if (nextExercise!.weightNote != null)
            Text(
              nextExercise!.weightNote!,
              style: WorkoutTheme.exerciseNameStyle.copyWith(
                fontSize: 14,
                color: WorkoutTheme.textGrey,
              ),
            ),
        ],
      ],
    );
  }

  Widget _buildTimer() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(_exerciseElapsedTime),
          style: WorkoutTheme.timerTextStyle,
        ),
        const SizedBox(height: 8),
        Text(
          'Exercise Time',
          style: WorkoutTheme.exerciseNameStyle.copyWith(
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildControls() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          IconButton(
            icon: const Icon(Icons.restart_alt, color: WorkoutTheme.primaryYellow),
            iconSize: 36,
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  backgroundColor: WorkoutTheme.surfaceBlack,
                  titleTextStyle: const TextStyle(color: WorkoutTheme.primaryYellow),
                  title: const Text('Restart Workout?'),
                  contentTextStyle: const TextStyle(color: WorkoutTheme.textWhite),
                  content: const Text(
                    'This will reset all progress. Are you sure?',
                  ),
                  actions: [
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: WorkoutTheme.textGrey,
                      ),
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancel'),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: WorkoutTheme.primaryYellow,
                      ),
                      onPressed: () {
                        Navigator.pop(context);
                        _restartWorkout();
                      },
                      child: const Text('Restart'),
                    ),
                  ],
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(
              _isRunning ? Icons.pause : Icons.play_arrow,
              color: WorkoutTheme.primaryYellow,
            ),
            iconSize: 48,
            onPressed: _toggleTimer,
          ),
          IconButton(
            icon: const Icon(Icons.skip_next, color: WorkoutTheme.primaryYellow),
            iconSize: 36,
            onPressed: nextExercise != null
                ? () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        backgroundColor: WorkoutTheme.surfaceBlack,
                        titleTextStyle: const TextStyle(color: WorkoutTheme.primaryYellow),
                        title: const Text('Move to Next Exercise?'),
                        contentTextStyle: const TextStyle(color: WorkoutTheme.textWhite),
                        content: const Text(
                          'Ready to move on to the next exercise?',
                        ),
                        actions: [
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: WorkoutTheme.textGrey,
                            ),
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Stay Here'),
                          ),
                          TextButton(
                            style: TextButton.styleFrom(
                              foregroundColor: WorkoutTheme.primaryYellow,
                            ),
                            onPressed: () {
                              Navigator.pop(context);
                              _moveToNextExercise();
                            },
                            child: const Text('Next Exercise'),
                          ),
                        ],
                      ),
                    );
                  }
                : null,
          ),
        ],
      ),
    );
  }
}
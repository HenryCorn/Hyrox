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
  int _currentTime = 0;
  int _totalElapsedTime = 0;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _keepScreenOn();
    _currentTime = widget.routine.exercises[0].duration;
    _initializeTimer();
  }

  @override
  void dispose() {
    _timer.cancel();
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
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_isRunning) {
        setState(() {
          if (_currentTime > 0) {
            _currentTime--;
            _totalElapsedTime++;
          } else {
            if (_currentExerciseIndex < widget.routine.exercises.length - 1) {
              _moveToNextExercise();
            } else {
              _completeWorkout();
            }
          }
        });
      }
    });
  }

  void _moveToNextExercise() {
    setState(() {
      _currentExerciseIndex++;
      _currentTime = widget.routine.exercises[_currentExerciseIndex].duration;
    });
  }

  void _completeWorkout() {
    _timer.cancel();
    _isRunning = false;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: WorkoutTheme.surfaceBlack,
        titleTextStyle: const TextStyle(color: WorkoutTheme.primaryYellow),
        title: const Text('Workout Complete!'),
        contentTextStyle: const TextStyle(color: WorkoutTheme.textWhite),
        content: Text(
          'Total time: ${(_totalElapsedTime / 60).floor()}:${(_totalElapsedTime % 60).toString().padLeft(2, '0')}',
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
      _currentTime = widget.routine.exercises[0].duration;
      _totalElapsedTime = 0;
      _isRunning = false;
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
            '${(_totalElapsedTime / 60).floor()}:${(_totalElapsedTime % 60).toString().padLeft(2, '0')}',
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
        if (nextExercise != null) ...[
          const SizedBox(height: 16),
          Text(
            'Next: ${nextExercise!.name}',
            style: WorkoutTheme.exerciseNameStyle,
          ),
        ],
      ],
    );
  }

  Widget _buildTimer() {
    return Text(
      '${(_currentTime / 60).floor()}:${(_currentTime % 60).toString().padLeft(2, '0')}',
      style: WorkoutTheme.timerTextStyle,
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
            onPressed: () {
              setState(() {
                _isRunning = !_isRunning;
              });
            },
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
                        title: const Text('Skip Exercise?'),
                        contentTextStyle: const TextStyle(color: WorkoutTheme.textWhite),
                        content: const Text(
                          'Are you sure you want to skip to the next exercise?',
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
                              _moveToNextExercise();
                            },
                            child: const Text('Skip'),
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
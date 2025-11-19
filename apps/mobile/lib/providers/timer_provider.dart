import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/routine.dart';
import '../services/wakelock_service.dart';
import 'timer_state.dart';

class TimerNotifier extends Notifier<TimerState> {
  Timer? _ticker;
  DateTime? _lastTick;

  @override
  TimerState build() {
    final wakelock = ref.read(wakelockServiceProvider);
    ref.onDispose(() {
      _ticker?.cancel();
      wakelock.disable();
    });
    return TimerState.initial();
  }

  void startRoutine(Routine routine) {
    state = TimerState.initial().copyWith(
      activeRoutine: routine,
      status: TimerStatus.initial,
    );
  }

  void start() {
    if (state.activeRoutine == null) return;
    
    ref.read(wakelockServiceProvider).enable();
    _lastTick = DateTime.now();
    state = state.copyWith(
      status: TimerStatus.running,
      startTime: state.startTime ?? _lastTick,
      lastTickTime: _lastTick,
    );

    _ticker = Timer.periodic(const Duration(milliseconds: 100), _onTick);
  }

  void pause() {
    _ticker?.cancel();
    ref.read(wakelockServiceProvider).disable();
    state = state.copyWith(status: TimerStatus.paused);
  }

  void resume() {
    if (state.activeRoutine == null) return;
    start();
  }

  void _onTick(Timer timer) {
    final now = DateTime.now();
    final diff = now.difference(_lastTick!);
    _lastTick = now;

    state = state.copyWith(
      totalElapsed: state.totalElapsed + diff,
      currentExerciseElapsed: state.currentExerciseElapsed + diff,
      lastTickTime: now,
    );
  }

  void nextExercise() {
    if (state.activeRoutine == null) return;
    
    if (state.currentExerciseIndex < state.activeRoutine!.exercises.length - 1) {
      state = state.copyWith(
        currentExerciseIndex: state.currentExerciseIndex + 1,
        currentExerciseElapsed: Duration.zero,
      );
    } else {
      finish();
    }
  }

  void finish() {
    _ticker?.cancel();
    ref.read(wakelockServiceProvider).disable();
    state = state.copyWith(status: TimerStatus.finished);
  }
  
  void reset() {
    _ticker?.cancel();
    ref.read(wakelockServiceProvider).disable();
    if (state.activeRoutine != null) {
      startRoutine(state.activeRoutine!);
    } else {
      state = TimerState.initial();
    }
  }
}

final timerProvider = NotifierProvider<TimerNotifier, TimerState>(() {
  return TimerNotifier();
});

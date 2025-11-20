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
    
    // If currently in Rox Zone, move to the next exercise (or finish if we're past the last exercise)
    if (state.isInRoxZone) {
      final nextIndex = state.currentExerciseIndex + 1;
      // If we would go past the last exercise, finish the workout
      if (nextIndex >= state.activeRoutine!.exercises.length) {
        finish();
        return;
      }
      
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        currentExerciseElapsed: Duration.zero,
        isInRoxZone: false,
      );
      return;
    }
    
    // If on an exercise, record split and move to Rox Zone (or finish if last exercise)
    if (state.currentExerciseIndex < state.activeRoutine!.exercises.length - 1) {
      // Record the split for the current exercise
      final updatedSplits = List<Duration>.from(state.splits)
        ..add(state.currentExerciseElapsed);
      
      // Move to Rox Zone
      state = state.copyWith(
        currentExerciseElapsed: Duration.zero,
        splits: updatedSplits,
        isInRoxZone: true,
      );
    } else {
      // Last exercise - record split and move to final Rox Zone
      final updatedSplits = List<Duration>.from(state.splits)
        ..add(state.currentExerciseElapsed);
      state = state.copyWith(
        currentExerciseElapsed: Duration.zero,
        splits: updatedSplits,
        isInRoxZone: true,
      );
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

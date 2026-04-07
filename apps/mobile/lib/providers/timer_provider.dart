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
    final exercises = state.activeRoutine!.exercises;

    // Exiting Rox Zone → record rox zone split, advance to next exercise
    if (state.isInRoxZone) {
      final nextIndex = state.currentExerciseIndex + 1;
      final updatedRoxSplits = List<Duration>.from(state.roxZoneSplits)
        ..add(state.currentExerciseElapsed);
      if (nextIndex >= exercises.length) {
        state = state.copyWith(roxZoneSplits: updatedRoxSplits);
        finish();
        return;
      }
      state = state.copyWith(
        currentExerciseIndex: nextIndex,
        currentExerciseElapsed: Duration.zero,
        roxZoneSplits: updatedRoxSplits,
        isInRoxZone: false,
      );
      return;
    }

    // On an exercise → record split
    final updatedSplits = List<Duration>.from(state.splits)
      ..add(state.currentExerciseElapsed);
    final isLastExercise =
        state.currentExerciseIndex >= exercises.length - 1;

    if (isLastExercise) {
      // Last exercise: no Rox Zone, go straight to finish
      state = state.copyWith(splits: updatedSplits);
      finish();
    } else {
      // Enter Rox Zone
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

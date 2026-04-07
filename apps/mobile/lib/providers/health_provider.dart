import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/health_service.dart';
import '../services/location_service.dart';

/// Live health metrics gathered during a workout session.
class HealthMetrics {
  const HealthMetrics({
    this.heartRate,
    this.totalCalories = 0.0,
    this.currentPaceSecsPerKm = 0.0,
    this.isPermissionGranted = false,
    this.workoutStart,
  });

  final int? heartRate; // bpm — null until first reading
  final double totalCalories; // kcal since workout started
  final double currentPaceSecsPerKm; // live pace (0 = not moving / not a run)
  final bool isPermissionGranted;
  final DateTime? workoutStart;

  HealthMetrics copyWith({
    int? heartRate,
    double? totalCalories,
    double? currentPaceSecsPerKm,
    bool? isPermissionGranted,
    DateTime? workoutStart,
  }) {
    return HealthMetrics(
      heartRate: heartRate ?? this.heartRate,
      totalCalories: totalCalories ?? this.totalCalories,
      currentPaceSecsPerKm: currentPaceSecsPerKm ?? this.currentPaceSecsPerKm,
      isPermissionGranted: isPermissionGranted ?? this.isPermissionGranted,
      workoutStart: workoutStart ?? this.workoutStart,
    );
  }

  String get heartRateDisplay =>
      heartRate != null ? '$heartRate' : '--';

  String get caloriesDisplay =>
      totalCalories > 0 ? totalCalories.toStringAsFixed(0) : '--';
}

// ── Notifier ───────────────────────────────────────────────────────────────
class HealthNotifier extends Notifier<HealthMetrics> {
  final _healthService = HealthService();
  final _locationService = LocationService();

  StreamSubscription<int>? _hrSubscription;
  StreamSubscription<double>? _paceSubscription;
  Timer? _calorieTimer;

  @override
  HealthMetrics build() {
    ref.onDispose(_cleanup);
    return const HealthMetrics();
  }

  // ── Lifecycle ──────────────────────────────────────────────────────────
  Future<void> initialise() async {
    final granted = await _healthService.requestPermissions();
    state = state.copyWith(isPermissionGranted: granted);

    if (granted) {
      _startHeartRateStream();
    }
    // Location permission is requested separately (not always needed)
  }

  void workoutStarted() {
    final now = DateTime.now();
    state = state.copyWith(
      workoutStart: now,
      totalCalories: 0.0,
    );
    if (state.isPermissionGranted) {
      _startCaloriePolling(now);
    }
  }

  void workoutStopped() {
    _calorieTimer?.cancel();
    _paceSubscription?.cancel();
    _locationService.stopTracking();
  }

  Future<void> startRunTracking() async {
    _paceSubscription?.cancel();
    await _locationService.startTracking();
    _paceSubscription =
        _locationService.paceStream.listen((paceSecsPerKm) {
      state = state.copyWith(currentPaceSecsPerKm: paceSecsPerKm);
    });
  }

  void stopRunTracking() {
    _paceSubscription?.cancel();
    _paceSubscription = null;
    _locationService.stopTracking();
    state = state.copyWith(currentPaceSecsPerKm: 0.0);
  }

  // ── Internal ────────────────────────────────────────────────────────────
  void _startHeartRateStream() {
    _hrSubscription = _healthService
        .heartRateStream(interval: const Duration(seconds: 5))
        .listen((bpm) {
      state = state.copyWith(heartRate: bpm);
    });
  }

  void _startCaloriePolling(DateTime workoutStart) {
    _calorieTimer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final cals = await _healthService.totalCaloriesBurned(workoutStart);
      if (cals > 0) {
        state = state.copyWith(totalCalories: cals);
      }
    });
  }

  Future<void> syncToWatch({
    required int exerciseIndex,
    required String exerciseName,
    required bool isRun,
    required bool isRunning,
    required int totalElapsedMs,
    required int exerciseElapsedMs,
    required int totalExercises,
  }) async {
    await _healthService.sendWorkoutStateToWatch(
      exerciseIndex: exerciseIndex,
      exerciseName: exerciseName,
      isRun: isRun,
      isRunning: isRunning,
      totalElapsedMs: totalElapsedMs,
      exerciseElapsedMs: exerciseElapsedMs,
      totalExercises: totalExercises,
    );
  }

  void _cleanup() {
    _hrSubscription?.cancel();
    _paceSubscription?.cancel();
    _calorieTimer?.cancel();
    _locationService.dispose();
  }
}

// ── Providers ──────────────────────────────────────────────────────────────
final healthProvider = NotifierProvider<HealthNotifier, HealthMetrics>(() {
  return HealthNotifier();
});

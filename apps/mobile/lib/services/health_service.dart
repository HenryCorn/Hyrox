import 'dart:async';
import 'package:flutter/services.dart';
import 'package:health/health.dart';

/// Wraps HealthKit (iOS) and Health Connect (Android) to stream live
/// heart-rate and aggregate calorie data during a Hyrox workout.
///
/// On first use, [requestPermissions] must be called and awaited.
class HealthService {
  static const _channel = MethodChannel('com.hyrox/watch_connectivity');

  final Health _health = Health();
  bool _authorized = false;

  // ── Authorisation ─────────────────────────────────────────────────────────
  Future<bool> requestPermissions() async {
    final types = [
      HealthDataType.HEART_RATE,
      HealthDataType.ACTIVE_ENERGY_BURNED,
      HealthDataType.WORKOUT,
    ];

    try {
      await _health.configure();
      final granted = await _health.requestAuthorization(
        types,
        permissions: [
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
          HealthDataAccess.READ_WRITE,
        ],
      );
      _authorized = granted;
      return granted;
    } catch (_) {
      _authorized = false;
      return false;
    }
  }

  bool get isAuthorized => _authorized;

  // ── Live heart rate ───────────────────────────────────────────────────────
  /// Polls heart rate every [interval] and emits the latest bpm value.
  Stream<int> heartRateStream({Duration interval = const Duration(seconds: 5)}) {
    late StreamController<int> controller;
    Timer? timer;

    controller = StreamController<int>(
      onListen: () {
        timer = Timer.periodic(interval, (_) async {
          final bpm = await _latestHeartRate();
          if (bpm != null && !controller.isClosed) {
            controller.add(bpm);
          }
        });
      },
      onCancel: () {
        timer?.cancel();
        controller.close();
      },
    );

    return controller.stream;
  }

  Future<int?> _latestHeartRate() async {
    if (!_authorized) return null;
    try {
      final now = DateTime.now();
      final from = now.subtract(const Duration(minutes: 2));
      final data = await _health.getHealthDataFromTypes(
        startTime: from,
        endTime: now,
        types: [HealthDataType.HEART_RATE],
      );
      if (data.isEmpty) return null;
      data.sort((a, b) => b.dateTo.compareTo(a.dateTo));
      final latest = data.first;
      return (latest.value as NumericHealthValue).numericValue.round();
    } catch (_) {
      return null;
    }
  }

  // ── Calories ─────────────────────────────────────────────────────────────
  /// Returns total active calories burned since [workoutStart].
  Future<double> totalCaloriesBurned(DateTime workoutStart) async {
    if (!_authorized) return 0.0;
    try {
      final data = await _health.getHealthDataFromTypes(
        startTime: workoutStart,
        endTime: DateTime.now(),
        types: [HealthDataType.ACTIVE_ENERGY_BURNED],
      );
      if (data.isEmpty) return 0.0;
      return data.fold<double>(
        0.0,
        (sum, d) => sum + (d.value as NumericHealthValue).numericValue.toDouble(),
      );
    } catch (_) {
      return 0.0;
    }
  }

  // ── WatchConnectivity (iOS Apple Watch) ──────────────────────────────────
  /// Sends the current workout state to the paired Apple Watch.
  Future<void> sendWorkoutStateToWatch({
    required int exerciseIndex,
    required String exerciseName,
    required bool isRun,
    required bool isRunning,
    required int totalElapsedMs,
    required int exerciseElapsedMs,
    required int totalExercises,
  }) async {
    try {
      await _channel.invokeMethod('sendWorkoutState', {
        'exerciseIndex': exerciseIndex,
        'exerciseName': exerciseName,
        'isRun': isRun,
        'isRunning': isRunning,
        'totalElapsedMs': totalElapsedMs,
        'exerciseElapsedMs': exerciseElapsedMs,
        'totalExercises': totalExercises,
      });
    } on MissingPluginException {
      // Not on iOS or watch not paired — silently ignore.
    } catch (_) {
      // Watch communication is best-effort.
    }
  }
}

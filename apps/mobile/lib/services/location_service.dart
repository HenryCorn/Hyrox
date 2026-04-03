import 'dart:async';
import 'package:geolocator/geolocator.dart';

/// Provides GPS-based running pace (min/km) using the device's location.
///
/// Pace is calculated from [Position.speed] (m/s → min/km).
/// A rolling average over the last [_windowSize] readings smooths spikes.
class LocationService {
  static const int _windowSize = 5;

  StreamSubscription<Position>? _subscription;
  final _paceController = StreamController<double>.broadcast();
  final List<double> _speedWindow = [];
  bool _started = false;

  // ── Permissions ───────────────────────────────────────────────────────────
  Future<bool> requestPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return false;

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    return permission == LocationPermission.whileInUse ||
        permission == LocationPermission.always;
  }

  // ── Pace stream ───────────────────────────────────────────────────────────
  /// Stream of pace values in seconds-per-km.
  /// Returns 0 when speed is too low to be meaningful (< 0.5 m/s).
  Stream<double> get paceStream => _paceController.stream;

  Future<void> startTracking() async {
    if (_started) return;
    final granted = await requestPermission();
    if (!granted) return;

    _started = true;
    const settings = LocationSettings(
      accuracy: LocationAccuracy.bestForNavigation,
      distanceFilter: 5, // metres — avoid excessive updates while stationary
    );

    _subscription = Geolocator.getPositionStream(locationSettings: settings)
        .listen((pos) {
      final speedMs = pos.speed.clamp(0.0, double.infinity);
      _speedWindow.add(speedMs);
      if (_speedWindow.length > _windowSize) {
        _speedWindow.removeAt(0);
      }
      final avgSpeed =
          _speedWindow.reduce((a, b) => a + b) / _speedWindow.length;

      // Below 0.5 m/s (≈ walking on spot) emit 0 to signal "no pace"
      if (avgSpeed < 0.5) {
        _paceController.add(0);
        return;
      }

      // Convert m/s → seconds per km
      final secsPerKm = 1000.0 / avgSpeed;
      _paceController.add(secsPerKm);
    });
  }

  void stopTracking() {
    _subscription?.cancel();
    _subscription = null;
    _speedWindow.clear();
    _started = false;
  }

  void dispose() {
    stopTracking();
    _paceController.close();
  }

  // ── Formatting ────────────────────────────────────────────────────────────
  /// Formats seconds-per-km as "MM:SS /km".
  static String formatPace(double secsPerKm) {
    if (secsPerKm <= 0) return '--:-- /km';
    final mins = secsPerKm ~/ 60;
    final secs = (secsPerKm % 60).round();
    final mm = mins.toString().padLeft(2, '0');
    final ss = secs.toString().padLeft(2, '0');
    return '$mm:$ss /km';
  }

  /// Formats seconds-per-km as short "MM:SS".
  static String formatPaceShort(double secsPerKm) {
    if (secsPerKm <= 0) return '--:--';
    final mins = secsPerKm ~/ 60;
    final secs = (secsPerKm % 60).round();
    return '${mins.toString().padLeft(2, '0')}:${secs.toString().padLeft(2, '0')}';
  }

  /// Computes average pace given total distance (m) and total time.
  static double avgPaceSecsPerKm(double distanceMetres, Duration elapsed) {
    if (distanceMetres < 10 || elapsed.inSeconds < 1) return 0;
    final secsPerMetre = elapsed.inSeconds / distanceMetres;
    return secsPerMetre * 1000;
  }
}

// Expose a simple speed → pace helper for tests
double speedMsToSecsPerKm(double speedMs) {
  if (speedMs < 0.01) return 0;
  return 1000.0 / speedMs;
}

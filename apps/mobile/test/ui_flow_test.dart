import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/main.dart';
import 'package:hyrox_tracker/services/wakelock_service.dart';
import 'package:hyrox_tracker/ui/screens/active_workout_screen.dart';
import 'package:hyrox_tracker/ui/screens/routine_picker_screen.dart';
import 'package:hyrox_tracker/providers/health_provider.dart';

// ── Mocks ─────────────────────────────────────────────────────────────────
class MockWakelockService implements WakelockService {
  @override
  Future<void> enable() async {}
  @override
  Future<void> disable() async {}
}

/// Replaces HealthNotifier so no platform channels are invoked during tests.
class MockHealthNotifier extends HealthNotifier {
  @override
  Future<void> initialise() async {}
  @override
  void workoutStarted() {}
  @override
  void workoutStopped() {}
  @override
  Future<void> startRunTracking() async {}
  @override
  void stopRunTracking() {}
  @override
  Future<void> syncToWatch({
    required int exerciseIndex,
    required String exerciseName,
    required bool isRun,
    required bool isRunning,
    required int totalElapsedMs,
    required int exerciseElapsedMs,
    required int totalExercises,
  }) async {}
}

// ── Helper — creates a fresh scoped app for each test ─────────────────────
Widget makeTestApp() => ProviderScope(
      overrides: [
        wakelockServiceProvider.overrideWithValue(MockWakelockService()),
        healthProvider.overrideWith(MockHealthNotifier.new),
      ],
      child: const HyroxApp(),
    );

// ── Tests ─────────────────────────────────────────────────────────────────
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RoutinePickerScreen renders all 7 categories', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);

    for (final label in [
      'WOMEN OPEN',
      'WOMEN PRO',
      'MEN OPEN',
      'MEN PRO',
      'DOUBLES WOMEN',
      'DOUBLES MEN',
      'DOUBLES MIXED',
    ]) {
      expect(find.text(label), findsOneWidget, reason: '$label not found');
    }
  });

  testWidgets('Tapping a category opens ActiveWorkoutScreen', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    // First exercise: '1 km Run 1' displayed uppercased
    expect(find.text('1 KM RUN 1'), findsOneWidget);
  });

  testWidgets('START → PAUSE controls work', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    expect(find.text('[ START ]'), findsOneWidget);

    await tester.tap(find.text('[ START ]'));
    await tester.pumpAndSettle();

    expect(find.text('[ PAUSE ]'), findsOneWidget);

    await tester.tap(find.text('[ PAUSE ]'));
    await tester.pumpAndSettle();

    expect(find.text('[ RESUME ]'), findsOneWidget);
  });

  testWidgets('NEXT advances to second exercise', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('[ START ]'));
    await tester.pumpAndSettle();

    // Two NEXT taps: first enters Rox Zone, second advances to next exercise
    await tester.tap(find.text('[ NEXT ]'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('[ NEXT ]'));
    await tester.pumpAndSettle();

    // Second exercise is SkiErg
    expect(find.text('SKIERG'), findsOneWidget);
  });

  testWidgets('Back button returns to picker', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('MEN OPEN'));
    await tester.pumpAndSettle();
    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);
  });

  testWidgets('Completing all segments does not throw', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('[ START ]'));
    await tester.pumpAndSettle();

    // 16 exercises × 2 NEXT taps = 32 total
    for (int i = 0; i < 32; i++) {
      final btn = find.text('[ NEXT ]');
      if (tester.any(btn)) {
        await tester.tap(btn);
        await tester.pumpAndSettle();
      }
    }

    expect(tester.takeException(), isNull);
  });
}

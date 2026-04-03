import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/main.dart';
import 'package:hyrox_tracker/services/wakelock_service.dart';
import 'package:hyrox_tracker/ui/screens/active_workout_screen.dart';
import 'package:hyrox_tracker/ui/screens/routine_picker_screen.dart';
import 'package:hyrox_tracker/providers/health_provider.dart';

// ── Mock wakelock (unchanged) ─────────────────────────────────────────────
class MockWakelockService implements WakelockService {
  @override
  Future<void> enable() async {}

  @override
  Future<void> disable() async {}
}

// ── Mock health notifier — prevents platform channel calls in tests ────────
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

// ── Helpers ───────────────────────────────────────────────────────────────
ProviderContainer _makeContainer() => ProviderContainer(
      overrides: [
        wakelockServiceProvider.overrideWithValue(MockWakelockService()),
        healthProvider.overrideWith(MockHealthNotifier.new),
      ],
    );

Widget _makeApp(ProviderContainer container) => UncontrolledProviderScope(
      container: container,
      child: const HyroxApp(),
    );

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RoutinePickerScreen renders all 7 categories', (tester) async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_makeApp(container));
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);

    // All 7 category labels should be visible
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
    final container = _makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_makeApp(container));
    await tester.pumpAndSettle();

    // Tap Women Open
    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    // First exercise is '1 km Run 1', displayed uppercased
    expect(find.text('1 KM RUN 1'), findsOneWidget);
  });

  testWidgets('START → PAUSE → NEXT advances exercise', (tester) async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_makeApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    // Start button is present and tappable
    expect(find.text('[ START ]'), findsOneWidget);
    await tester.tap(find.text('[ START ]'));
    await tester.pumpAndSettle();

    // After starting, PAUSE button appears
    expect(find.text('[ PAUSE ]'), findsOneWidget);

    // Tap NEXT twice: first call enters Rox Zone (internal state),
    // second call advances to the next exercise
    await tester.tap(find.text('[ NEXT ]'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('[ NEXT ]'));
    await tester.pumpAndSettle();

    // Second exercise is SkiErg, displayed uppercased
    expect(find.text('SKIERG'), findsOneWidget);
  });

  testWidgets('Back button resets and returns to picker', (tester) async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_makeApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('MEN OPEN'));
    await tester.pumpAndSettle();
    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);

    // Tap the back button (arrow_back_ios icon)
    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);
  });

  testWidgets('Workout completes and does not crash', (tester) async {
    final container = _makeContainer();
    addTearDown(container.dispose);

    await tester.pumpWidget(_makeApp(container));
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    await tester.tap(find.text('[ START ]'));
    await tester.pumpAndSettle();

    // Tap through all 16 segments (each needs 2 NEXT taps: enter Rox Zone + advance)
    // 16 exercises × 2 = 32 taps total
    for (int i = 0; i < 32; i++) {
      // The NEXT button may not exist after finish navigates away
      final nextButton = find.text('[ NEXT ]');
      if (tester.any(nextButton)) {
        await tester.tap(nextButton);
        await tester.pumpAndSettle();
      }
    }

    // App should still be alive (either SummaryScreen or ActiveWorkoutScreen)
    expect(tester.takeException(), isNull);
  });
}

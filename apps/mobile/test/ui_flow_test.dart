import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/main.dart';
import 'package:hyrox_tracker/providers/auth_provider.dart';
import 'package:hyrox_tracker/providers/health_provider.dart';
import 'package:hyrox_tracker/services/wakelock_service.dart';
import 'package:hyrox_tracker/ui/screens/active_workout_screen.dart';
import 'package:hyrox_tracker/ui/screens/routine_picker_screen.dart';
import 'package:hyrox_tracker/ui/screens/target_setup_screen.dart';

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

/// Bypasses FlutterSecureStorage (unavailable in tests) and immediately
/// returns an authenticated state so _AuthGate shows RoutinePickerScreen.
class MockAuthNotifier extends AuthNotifier {
  @override
  Future<AuthState> build() async => const AuthAuthenticated(
        userId: 'test-user',
        displayName: 'Test',
        accessToken: 'test-token',
      );
}

// ── Helper — creates a fresh scoped app for each test ─────────────────────
Widget makeTestApp() => ProviderScope(
      overrides: [
        wakelockServiceProvider.overrideWithValue(MockWakelockService()),
        healthProvider.overrideWith(MockHealthNotifier.new),
        authProvider.overrideWith(MockAuthNotifier.new),
      ],
      child: const HyroxApp(),
    );

/// Helper: navigate from routine picker through target setup to active workout.
Future<void> navigateToActiveWorkout(WidgetTester tester,
    {String category = 'WOMEN OPEN'}) async {
  await tester.tap(find.text(category));
  await tester.pumpAndSettle();
  // Now on TargetSetupScreen — tap start button
  final startBtn = find.textContaining('[ START');
  expect(startBtn, findsOneWidget);
  await tester.tap(startBtn);
  await tester.pumpAndSettle();
}

// ── Tests ─────────────────────────────────────────────────────────────────
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('RoutinePickerScreen renders all 7 categories', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);

    // ListView.separated lazily renders — scroll to surface off-screen items.
    for (final label in [
      'WOMEN OPEN',
      'WOMEN PRO',
      'MEN OPEN',
      'MEN PRO',
      'DOUBLES WOMEN',
      'DOUBLES MEN',
      'DOUBLES MIXED',
    ]) {
      await tester.scrollUntilVisible(
        find.text(label),
        200,
        scrollable: find.byType(Scrollable).first,
      );
      expect(find.text(label), findsAtLeastNWidgets(1),
          reason: '$label not found');
    }
  });

  testWidgets('Tapping a category opens TargetSetupScreen', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('WOMEN OPEN'));
    await tester.pumpAndSettle();

    expect(find.byType(TargetSetupScreen), findsOneWidget);
    expect(find.text('SET TARGETS'), findsOneWidget);
  });

  testWidgets('Starting without targets opens ActiveWorkoutScreen',
      (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await navigateToActiveWorkout(tester);

    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    // First exercise name appears in at least the main display and the station
    // list — use findsAtLeastNWidgets to avoid fragile count assumptions.
    expect(find.text('1 KM RUN 1'), findsAtLeastNWidgets(1));
  });

  testWidgets('START → PAUSE controls work', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await navigateToActiveWorkout(tester);

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

    await navigateToActiveWorkout(tester);

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

  testWidgets('Back button from active workout returns to picker',
      (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await navigateToActiveWorkout(tester, category: 'MEN OPEN');
    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);
  });

  testWidgets('Back button from target setup returns to picker',
      (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await tester.tap(find.text('MEN OPEN'));
    await tester.pumpAndSettle();
    expect(find.byType(TargetSetupScreen), findsOneWidget);

    await tester.tap(find.byIcon(Icons.arrow_back_ios));
    await tester.pumpAndSettle();

    expect(find.byType(RoutinePickerScreen), findsOneWidget);
  });

  testWidgets('Completing all segments does not throw', (tester) async {
    await tester.pumpWidget(makeTestApp());
    await tester.pumpAndSettle();

    await navigateToActiveWorkout(tester);

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

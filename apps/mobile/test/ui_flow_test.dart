import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hyrox_tracker/main.dart';
import 'package:hyrox_tracker/models/predefined_routines.dart';
import 'package:hyrox_tracker/services/wakelock_service.dart';
import 'package:hyrox_tracker/ui/screens/active_workout_screen.dart';
import 'package:hyrox_tracker/ui/screens/routine_picker_screen.dart';
import 'package:hyrox_tracker/ui/screens/summary_screen.dart';

class MockWakelockService implements WakelockService {
  @override
  Future<void> enable() async {}
  
  @override
  Future<void> disable() async {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('Full workout flow test', (WidgetTester tester) async {
    // Build the app with mocked WakelockService
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          wakelockServiceProvider.overrideWithValue(MockWakelockService()),
        ],
        child: const HyroxApp(),
      ),
    );

    // 1. Verify RoutinePickerScreen
    expect(find.byType(RoutinePickerScreen), findsOneWidget);
    expect(find.text('WOMEN SINGLE'), findsOneWidget);

    // 2. Tap a routine (Women Single)
    await tester.tap(find.text('WOMEN SINGLE'));
    await tester.pumpAndSettle();

    // 3. Verify ActiveWorkoutScreen
    expect(find.byType(ActiveWorkoutScreen), findsOneWidget);
    expect(find.text('WOMEN SINGLE'), findsOneWidget); // Title
    
    // Verify first exercise (1 km Run)
    expect(find.text('1 KM RUN'), findsOneWidget);

    // 4. Verify Timer starts (check for START button initially)
    // Scroll to make button visible
    await tester.dragUntilVisible(
      find.text('START'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    expect(find.text('START'), findsOneWidget);
    
    // Tap START to start
    await tester.tap(find.text('START'));
    await tester.pumpAndSettle();
    
    //Now should see PAUSE
    await tester.dragUntilVisible(
      find.text('PAUSE'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    expect(find.text('PAUSE'), findsOneWidget);

    // 5. Tap Next
    await tester.dragUntilVisible(
      find.text('NEXT EXERCISE'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    await tester.tap(find.text('NEXT EXERCISE'));
    await tester.pumpAndSettle();

    // 6. Verify second exercise (1000 m SkiErg)
    expect(find.text('1000 M SKIERG'), findsOneWidget);

    // 7. Fast forward through exercises
    final routine = PredefinedRoutines.womenSingle;
    // We are already at index 1 (second exercise).
    for (int i = 1; i < routine.exercises.length - 1; i++) {
      await tester.dragUntilVisible(
        find.text('NEXT EXERCISE'),
        find.byType(SingleChildScrollView),
        const Offset(0, -50),
      );
      await tester.tap(find.text('NEXT EXERCISE'));
      await tester.pumpAndSettle();
    }

    // Now at last exercise. Tap Next to finish.
    await tester.dragUntilVisible(
      find.text('NEXT EXERCISE'),
      find.byType(SingleChildScrollView),
      const Offset(0, -50),
    );
    await tester.tap(find.text('NEXT EXERCISE'));
    await tester.pumpAndSettle();

    // 8. Verify SummaryScreen
    expect(find.byType(SummaryScreen), findsOneWidget);
    expect(find.text('WORKOUT COMPLETE'), findsOneWidget);

    // 9. Tap Done
    await tester.tap(find.text('DONE'));
    await tester.pumpAndSettle();

    // 10. Verify back to RoutinePickerScreen
    expect(find.byType(RoutinePickerScreen), findsOneWidget);
  });
}

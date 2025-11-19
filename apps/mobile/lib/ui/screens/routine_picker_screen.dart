import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/predefined_routines.dart';
import '../../providers/timer_provider.dart';
import '../theme/hyrox_theme.dart';
import '../widgets/glass_card.dart';
import 'active_workout_screen.dart';

class RoutinePickerScreen extends ConsumerWidget {
  const RoutinePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = [
      PredefinedRoutines.womenSingle,
      PredefinedRoutines.menSingle,
      PredefinedRoutines.womenPro,
      PredefinedRoutines.menPro,
      PredefinedRoutines.doublesMixed,
      PredefinedRoutines.doublesWomen,
      PredefinedRoutines.doublesMen,
    ];

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: HyroxTheme.darkGradient,
        ),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'HYROX',
                      style: Theme.of(context).textTheme.displayLarge?.copyWith(
                            fontSize: 48,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 2.0,
                          ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Choose Your Workout',
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: HyroxTheme.lightGrey,
                            letterSpacing: 1.0,
                          ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 24.0),
                  itemCount: routines.length,
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 16.0),
                      child: GlassCard(
                        padding: const EdgeInsets.all(20.0),
                        child: InkWell(
                          onTap: () {
                            ref.read(timerProvider.notifier).startRoutine(routine);
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => const ActiveWorkoutScreen(),
                              ),
                            );
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Row(
                            children: [
                              Container(
                                width: 4,
                                height: 48,
                                decoration: const BoxDecoration(
                                  gradient: HyroxTheme.accentGradient,
                                  borderRadius: BorderRadius.all(Radius.circular(2)),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      routine.name.toUpperCase(),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            letterSpacing: 1.2,
                                          ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '${routine.exercises.length} segments',
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontSize: 14,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                              const Icon(
                                Icons.arrow_forward_ios,
                                color: HyroxTheme.yellow,
                                size: 20,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

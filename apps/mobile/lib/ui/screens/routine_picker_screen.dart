import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/predefined_routines.dart';
import '../../models/routine.dart';
import '../../providers/timer_provider.dart';
import '../theme/hyrox_theme.dart';
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
      appBar: AppBar(
        title: const Text('SELECT ROUTINE'),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(16),
        itemCount: routines.length,
        separatorBuilder: (context, index) => const SizedBox(height: 16),
        itemBuilder: (context, index) {
          final routine = routines[index];
          return _RoutineCard(
            routine: routine,
            onTap: () {
              ref.read(timerProvider.notifier).startRoutine(routine);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const ActiveWorkoutScreen(),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _RoutineCard extends StatelessWidget {
  final Routine routine;
  final VoidCallback onTap;

  const _RoutineCard({required this.routine, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Card(
      color: HyroxTheme.darkGrey,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: HyroxTheme.yellow.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                routine.name.toUpperCase(),
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 20,
                      color: HyroxTheme.white,
                    ),
              ),
              const SizedBox(height: 8),
              Text(
                '${routine.exercises.length} Exercises',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

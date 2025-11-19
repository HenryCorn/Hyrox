import 'package:flutter/material.dart';
import '../../models/predefined_routines.dart';
import '../theme/hyrox_theme.dart';
import 'active_workout_screen.dart';
import '../../providers/timer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutinePickerScreen extends ConsumerWidget {
  const RoutinePickerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = [
      ('Women Single - Full Hyrox Race', PredefinedRoutines.womenSingle),
      ('Men Single - Full Hyrox Race', PredefinedRoutines.menSingle),
      ('Women Pro - Full Hyrox Race', PredefinedRoutines.womenPro),
      ('Men Pro - Full Hyrox Race', PredefinedRoutines.menPro),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 40),
              // Title
              Text(
                'SELECT WORKOUT',
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      fontSize: 32,
                      fontWeight: FontWeight.w900,
                      color: HyroxTheme.yellow,
                      letterSpacing: 2.0,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Choose your Hyrox routine',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Colors.grey.shade600,
                    ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              
              // Routine List
              Expanded(
                child: ListView.separated(
                  itemCount: routines.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 16),
                  itemBuilder: (context, index) {
                    final routine = routines[index];
                    return _buildRoutineCard(
                      context,
                      ref,
                      routine.$1,
                      routine.$2,
                      routine.$2.exercises.length,
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

  Widget _buildRoutineCard(
    BuildContext context,
    WidgetRef ref,
    String name,
    dynamic routine,
    int segmentCount,
  ) {
    return InkWell(
      onTap: () {
        ref.read(timerProvider.notifier).startRoutine(routine);
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const ActiveWorkoutScreen()),
        );
      },
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: HyroxTheme.yellow.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                Icons.fitness_center,
                color: HyroxTheme.yellow,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            
            // Text
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$segmentCount segments',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                  ),
                ],
              ),
            ),
            
            // Arrow
            Icon(
              Icons.arrow_forward_ios,
              color: Colors.grey.shade700,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }
}

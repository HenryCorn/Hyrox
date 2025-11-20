import 'package:flutter/material.dart';
import '../../models/predefined_routines.dart';
import '../theme/hyrox_theme.dart';
import 'active_workout_screen.dart';
import '../../providers/timer_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RoutinePickerScreen extends ConsumerWidget {
  const RoutinePickerScreen({super.key});

  IconData _getRoutineIcon(String name) {
    if (name.contains('Women')) return Icons.female;
    if (name.contains('Men')) return Icons.male;
    return Icons.people;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final routines = [
      ('Women Single - Full Hyrox Race', PredefinedRoutines.womenSingle, Icons.female),
      ('Men Single - Full Hyrox Race', PredefinedRoutines.menSingle, Icons.male),
      ('Women Pro - Full Hyrox Race', PredefinedRoutines.womenPro, Icons.emoji_events),
      ('Men Pro - Full Hyrox Race', PredefinedRoutines.menPro, Icons.workspace_premium),
      ('Doubles Women - Full Hyrox Race', PredefinedRoutines.doublesWomen, Icons.people),
      ('Doubles Men - Full Hyrox Race', PredefinedRoutines.doublesMen, Icons.people),
      ('Doubles Mixed - Full Hyrox Race', PredefinedRoutines.doublesMixed, Icons.people_outline),
    ];

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              // Icon header
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      HyroxTheme.yellow.withOpacity(0.2),
                      HyroxTheme.yellow.withOpacity(0.05),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.fitness_center,
                  size: 48,
                  color: HyroxTheme.yellow,
                ),
              ),
              const SizedBox(height: 24),
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.timer_outlined,
                    size: 16,
                    color: Colors.grey.shade600,
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Choose your Hyrox routine',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.grey.shade600,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
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
                      routine.$3,
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
    IconData icon,
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
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon with gradient background
            Container(
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    HyroxTheme.yellow.withOpacity(0.3),
                    HyroxTheme.yellow.withOpacity(0.1),
                  ],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: HyroxTheme.yellow.withOpacity(0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  ),
                ],
              ),
              child: Icon(
                icon,
                color: HyroxTheme.yellow,
                size: 28,
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
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        Icons.format_list_numbered,
                        size: 14,
                        color: HyroxTheme.yellow.withOpacity(0.7),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '$segmentCount segments',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Colors.grey.shade600,
                            ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Arrow with background
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.grey.shade900,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                Icons.arrow_forward_ios,
                color: HyroxTheme.yellow,
                size: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

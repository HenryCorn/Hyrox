import 'package:flutter/material.dart';
import '../models/workout_routine.dart';
import '../theme/workout_theme.dart';
import 'active_workout_screen.dart';

class RoutinePickerScreen extends StatelessWidget {
  final List<WorkoutRoutine> routines; // This would come from a service/provider

  const RoutinePickerScreen({
    super.key,
    required this.routines,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkoutTheme.backgroundBlack,
      appBar: AppBar(
        title: const Text('Select Workout'),
        titleTextStyle: const TextStyle(color: WorkoutTheme.textWhite),
        backgroundColor: WorkoutTheme.surfaceBlack,
      ),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
        ),
        itemCount: routines.length,
        itemBuilder: (context, index) {
          final routine = routines[index];
          return RoutineCard(routine: routine);
        },
      ),
    );
  }
}

class RoutineCard extends StatelessWidget {
  final WorkoutRoutine routine;

  const RoutineCard({
    super.key,
    required this.routine,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ActiveWorkoutScreen(routine: routine),
          ),
        );
      },
      child: Container(
        decoration: BoxDecoration(
          color: WorkoutTheme.surfaceBlack,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: WorkoutTheme.primaryYellow,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                routine.name,
                style: WorkoutTheme.routineNameStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                '${routine.exercises.length} exercises',
                style: WorkoutTheme.exerciseNameStyle,
              ),
              const SizedBox(height: 4),
              Text(
                '${(routine.totalDuration / 60).round()} min',
                style: WorkoutTheme.durationStyle,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
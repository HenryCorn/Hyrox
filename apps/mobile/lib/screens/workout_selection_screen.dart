import 'package:flutter/material.dart';
import '../models/hyrox_workouts.dart';
import '../theme/workout_theme.dart';
import 'active_workout_screen.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: WorkoutTheme.backgroundBlack,
      appBar: AppBar(
        backgroundColor: WorkoutTheme.surfaceBlack,
        title: const Text(
          'HYROX Workout',
          style: TextStyle(
            color: WorkoutTheme.primaryYellow,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: [
          _buildCategoryCard(
            context,
            'Men Singles',
            'Standard HYROX workout for men',
            HyroxCategory.menSingles,
          ),
          _buildCategoryCard(
            context,
            'Men Pro',
            'Professional HYROX workout for men',
            HyroxCategory.menPro,
          ),
          _buildCategoryCard(
            context,
            'Women Singles',
            'Standard HYROX workout for women',
            HyroxCategory.womenSingles,
          ),
          _buildCategoryCard(
            context,
            'Women Pro',
            'Professional HYROX workout for women',
            HyroxCategory.womenPro,
          ),
          _buildCategoryCard(
            context,
            'Doubles',
            'HYROX workout for teams of two',
            HyroxCategory.doubles,
          ),
        ],
      ),
    );
  }

  Widget _buildCategoryCard(
    BuildContext context,
    String title,
    String description,
    HyroxCategory category,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      color: WorkoutTheme.surfaceBlack,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12.0),
        side: const BorderSide(
          color: WorkoutTheme.primaryYellow,
          width: 1.0,
        ),
      ),
      child: InkWell(
        onTap: () {
          final workout = HyroxWorkout.getWorkout(category);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ActiveWorkoutScreen(routine: workout),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: WorkoutTheme.primaryYellow,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                description,
                style: const TextStyle(
                  color: WorkoutTheme.textWhite,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
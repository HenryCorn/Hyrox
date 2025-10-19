import 'package:flutter/material.dart';
import '../models/hyrox_workouts.dart';
import 'active_workout_screen.dart';

class WorkoutSelectionScreen extends StatelessWidget {
  const WorkoutSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('HYROX Workout'),
      ),
      body: ListView(
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
      margin: const EdgeInsets.all(8.0),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16.0),
        title: Text(
          title,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        subtitle: Text(description),
        onTap: () {
          final workout = HyroxWorkout.getWorkout(category);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => ActiveWorkoutScreen(routine: workout),
            ),
          );
        },
      ),
    );
  }
}
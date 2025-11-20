import 'package:flutter/material.dart';
import '../models/exercise.dart';

class ExerciseIcons {
  static IconData getIconForExercise(Exercise exercise) {
    final name = exercise.name.toLowerCase();
    
    // Running exercises
    if (name.contains('run')) return Icons.directions_run;
    
    // Ski Erg
    if (name.contains('ski')) return Icons.downhill_skiing;
    
    // Rowing
    if (name.contains('row')) return Icons.rowing;
    
    // Sled Push - weight plates with forward arrow
    if (name.contains('sled push')) return Icons.double_arrow;
    
    // Sled Pull - weight plates with backward arrow
    if (name.contains('sled pull')) return Icons.keyboard_double_arrow_left;
    
    // Burpee Broad Jump - jumping person (sports_handball shows a jumping figure)
    if (name.contains('burpee')) return Icons.sports_handball;
    
    // Farmers Carry - kettlebell
    if (name.contains('farmer')) return Icons.fitness_center;
    
    // Sandbag Lunges - person carrying weight (hiking shows person with backpack)
    if (name.contains('lunge')) return Icons.hiking;
    
    // Wall Balls - ball going up
    if (name.contains('wall ball')) return Icons.arrow_circle_up;
    
    return Icons.fitness_center; // Default icon
  }
}

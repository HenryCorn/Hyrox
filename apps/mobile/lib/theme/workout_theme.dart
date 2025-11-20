import 'package:flutter/material.dart';

class WorkoutTheme {
  static const Color primaryYellow = Color(0xFFFFD700);
  static const Color secondaryYellow = Color(0xFFFFA500);
  static const Color backgroundBlack = Color(0xFF000000);
  static const Color surfaceBlack = Color(0xFF121212);
  static const Color textWhite = Color(0xFFFFFFFF);
  static const Color textGrey = Color(0xFF9E9E9E);

  static const TextStyle timerTextStyle = TextStyle(
    fontSize: 72,
    fontWeight: FontWeight.bold,
    color: textWhite,
    fontFamily: 'Roboto',
  );

  static const TextStyle totalTimerTextStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w500,
    color: textGrey,
    fontFamily: 'Roboto',
  );

  static const TextStyle exerciseLabelStyle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w500,
    color: primaryYellow,
    fontFamily: 'Roboto',
  );

  static const TextStyle routineNameStyle = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textWhite,
    fontFamily: 'Roboto',
  );

  static const TextStyle durationStyle = TextStyle(
    color: primaryYellow,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );

  static const TextStyle exerciseNameStyle = TextStyle(
    color: textGrey,
    fontSize: 16,
    fontWeight: FontWeight.w500,
    fontFamily: 'Roboto',
  );

  static ButtonStyle primaryButtonStyle = ElevatedButton.styleFrom(
    backgroundColor: primaryYellow,
    foregroundColor: backgroundBlack,
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(8),
    ),
  );
}
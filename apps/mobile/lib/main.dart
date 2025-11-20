import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/routine_picker_screen.dart';
import 'ui/theme/hyrox_theme.dart';

void main() {
  runApp(const ProviderScope(child: HyroxApp()));
}

class HyroxApp extends StatelessWidget {
  const HyroxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyrox Tracker',
      theme: HyroxTheme.themeData,
      home: const RoutinePickerScreen(),
    );
  }
}

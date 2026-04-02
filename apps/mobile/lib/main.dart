import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'ui/screens/routine_picker_screen.dart';
import 'ui/theme/nothing_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  // Force portrait-only while in workout; landscape for summary.
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  // OLED black status-bar icons
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: NothingTheme.black,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const ProviderScope(child: HyroxApp()));
}

class HyroxApp extends StatelessWidget {
  const HyroxApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hyrox Tracker',
      debugShowCheckedModeBanner: false,
      theme: NothingTheme.themeData,
      home: const RoutinePickerScreen(),
    );
  }
}

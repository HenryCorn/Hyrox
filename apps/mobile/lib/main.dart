import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'providers/auth_provider.dart';
import 'services/ad_service.dart';
import 'ui/screens/auth_screen.dart';
import 'ui/screens/routine_picker_screen.dart';
import 'ui/theme/nothing_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AdService.initialise();

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
      home: const _AuthGate(),
    );
  }
}

/// Shows the auth screen until a session is confirmed, then replaces with the
/// main app. Handles both the "already signed in" (token restore) case and
/// the first-launch / signed-out case.
class _AuthGate extends ConsumerWidget {
  const _AuthGate();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    // While restoring a persisted session, show a blank OLED screen —
    // avoids a flash of the auth screen on returning users.
    if (auth.isLoading) {
      return const Scaffold(
        backgroundColor: NothingTheme.black,
        body: Center(
          child: CircularProgressIndicator(color: NothingTheme.accent),
        ),
      );
    }

    if (auth.value is AuthAuthenticated) {
      return const RoutinePickerScreen();
    }

    return const AuthScreen();
  }
}

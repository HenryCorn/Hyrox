import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../providers/auth_provider.dart';
import '../theme/nothing_theme.dart';
import 'routine_picker_screen.dart';

class AuthScreen extends ConsumerWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final auth = ref.watch(authProvider);

    ref.listen(authProvider, (_, next) {
      if (next.value is AuthAuthenticated) {
        // Replace auth screen with the main app — no back-stack entry.
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const RoutinePickerScreen()),
        );
      } else if (next is AsyncError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Sign in failed. Please try again.'),
            backgroundColor: NothingTheme.danger,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(flex: 3),

              // ── Logo / wordmark ────────────────────────────────────────────
              Text(
                'HYROX',
                textAlign: TextAlign.center,
                style: GoogleFonts.spaceMono(
                  fontSize: 48,
                  fontWeight: FontWeight.w700,
                  color: NothingTheme.textDisplay,
                  letterSpacing: 8,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'TRACK · COMPETE · CONNECT',
                textAlign: TextAlign.center,
                style: NothingTheme.label(
                  fontSize: 11,
                  color: NothingTheme.textDisabled,
                ),
              ),

              const Spacer(flex: 2),

              // ── Sign in buttons ────────────────────────────────────────────
              if (auth.isLoading)
                const Center(
                  child: CircularProgressIndicator(color: NothingTheme.accent),
                )
              else ...[
                SignInWithAppleButton(
                  onPressed: () =>
                      ref.read(authProvider.notifier).signInWithApple(),
                  style: SignInWithAppleButtonStyle.white,
                  borderRadius: BorderRadius.circular(4),
                ),

                const SizedBox(height: 12),

                _GoogleButton(
                  onPressed: () =>
                      ref.read(authProvider.notifier).signInWithGoogle(),
                ),

                const SizedBox(height: 24),

                // Skip — use locally without sync or friends
                TextButton(
                  onPressed: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute(
                        builder: (_) => const RoutinePickerScreen()),
                  ),
                  child: Text(
                    'Continue without account',
                    style: NothingTheme.label(
                      fontSize: 11,
                      color: NothingTheme.textDisabled,
                    ),
                  ),
                ),
              ],

              const Spacer(),

              Text(
                'Your data is end-to-end encrypted and never shared.',
                textAlign: TextAlign.center,
                style: NothingTheme.label(
                  fontSize: 10,
                  color: NothingTheme.borderVisible,
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

class _GoogleButton extends StatelessWidget {
  const _GoogleButton({required this.onPressed});
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        height: 44,
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: NothingTheme.borderVisible),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Minimal "G" icon since we can't use the real one without asset
            Text(
              'G',
              style: GoogleFonts.spaceMono(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: NothingTheme.accent,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              'Sign in with Google',
              style: NothingTheme.label(
                fontSize: 13,
                color: NothingTheme.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/predefined_routines.dart';
import '../../models/routine.dart';
import '../../providers/timer_provider.dart';
import '../../providers/health_provider.dart';
import '../theme/nothing_theme.dart';
import 'active_workout_screen.dart';

class RoutinePickerScreen extends ConsumerStatefulWidget {
  const RoutinePickerScreen({super.key});

  @override
  ConsumerState<RoutinePickerScreen> createState() =>
      _RoutinePickerScreenState();
}

class _RoutinePickerScreenState extends ConsumerState<RoutinePickerScreen> {
  @override
  void initState() {
    super.initState();
    // Request health permissions on first launch — non-blocking.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(healthProvider.notifier).initialise();
    });
  }

  @override
  Widget build(BuildContext context) {
    final categories = _categories();

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 32, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'HYROX',
                    style: GoogleFonts.spaceMono(
                      fontSize: 48,
                      fontWeight: FontWeight.w700,
                      color: NothingTheme.textDisplay,
                      letterSpacing: -1,
                      height: 1.0,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'SELECT CATEGORY',
                    style: NothingTheme.label(
                        fontSize: 11, color: NothingTheme.textDisabled),
                  ),
                  const SizedBox(height: 24),
                  // ── Race format info ────────────────────────────────────
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: NothingTheme.surface,
                      border: Border.all(color: NothingTheme.borderSubtle),
                    ),
                    child: Row(
                      children: [
                        _infoChip('8 KM TOTAL'),
                        const SizedBox(width: 16),
                        _infoChip('8 RUNS'),
                        const SizedBox(width: 16),
                        _infoChip('8 STATIONS'),
                        const Spacer(),
                        _infoChip('16 SEGMENTS'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),

            // ── Divider ──────────────────────────────────────────────────
            const Divider(height: 1, color: NothingTheme.borderSubtle),

            // ── Category list ────────────────────────────────────────────
            Expanded(
              child: ListView.separated(
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                itemCount: categories.length,
                separatorBuilder: (_, __) =>
                    const Divider(height: 1, color: NothingTheme.borderSubtle),
                itemBuilder: (context, index) {
                  final cat = categories[index];
                  return _CategoryRow(
                    label: cat.$1,
                    sublabel: cat.$2,
                    routine: cat.$3,
                    onTap: () => _startRoutine(context, cat.$3),
                  );
                },
              ),
            ),

            // ── Footer ───────────────────────────────────────────────────
            const Divider(height: 1, color: NothingTheme.borderSubtle),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              child: Text(
                'RACE FORMAT · 8 × 1 KM RUNS + 8 WORKOUT STATIONS',
                style: NothingTheme.label(
                    fontSize: 10, color: NothingTheme.textDisabled),
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(String text) => Text(
        text,
        style: NothingTheme.label(
            fontSize: 10, color: NothingTheme.textSecondary),
      );

  void _startRoutine(BuildContext context, Routine routine) {
    ref.read(timerProvider.notifier).startRoutine(routine);
    Navigator.of(context).push(
      MaterialPageRoute(
          builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  List<(String, String, Routine)> _categories() => [
        (
          'WOMEN OPEN',
          'SkiErg · Sled 102 kg · Wall Balls 4 kg / 75 reps',
          PredefinedRoutines.womenSingle,
        ),
        (
          'WOMEN PRO',
          'SkiErg · Sled 102 kg · Wall Balls 4 kg / 100 reps',
          PredefinedRoutines.womenPro,
        ),
        (
          'MEN OPEN',
          'SkiErg · Sled 152 kg · Wall Balls 6 kg / 100 reps',
          PredefinedRoutines.menSingle,
        ),
        (
          'MEN PRO',
          'SkiErg · Sled 202 kg · Wall Balls 6 kg / 150 reps',
          PredefinedRoutines.menPro,
        ),
        (
          'DOUBLES WOMEN',
          '2 × SkiErg 1,000 m · Sled 102 kg · Wall Balls 4 kg',
          PredefinedRoutines.doublesWomen,
        ),
        (
          'DOUBLES MEN',
          '2 × SkiErg 1,000 m · Sled 152 kg · Wall Balls 6 kg',
          PredefinedRoutines.doublesMen,
        ),
        (
          'DOUBLES MIXED',
          '2 × SkiErg 1,000 m · Sled 152/78 kg · Mixed balls',
          PredefinedRoutines.doublesMixed,
        ),
      ];
}

// ── Category row widget ─────────────────────────────────────────────────────
class _CategoryRow extends StatelessWidget {
  const _CategoryRow({
    required this.label,
    required this.sublabel,
    required this.routine,
    required this.onTap,
  });

  final String label;
  final String sublabel;
  final Routine routine;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 18),
        child: Row(
          children: [
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: NothingTheme.body(
                      fontSize: 15,
                      weight: FontWeight.w600,
                      color: NothingTheme.textDisplay,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    sublabel,
                    style: NothingTheme.label(
                        fontSize: 10, color: NothingTheme.textDisabled),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Segment count badge
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                border: Border.all(color: NothingTheme.borderVisible),
              ),
              child: Text(
                '${routine.exercises.length} SEG',
                style: NothingTheme.label(
                    fontSize: 10, color: NothingTheme.textSecondary),
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: NothingTheme.textDisabled,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/exercise.dart';
import '../../models/predefined_routines.dart';
import '../../providers/timer_provider.dart';
import '../../providers/health_provider.dart';
import '../theme/nothing_theme.dart';
import '../widgets/segmented_progress.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timer = ref.watch(timerProvider);
    final health = ref.watch(healthProvider);
    final routine = timer.activeRoutine;

    if (routine == null) {
      return const Scaffold(
        backgroundColor: NothingTheme.black,
        body: Center(
          child: Text('NO WORKOUT DATA',
              style: TextStyle(color: NothingTheme.textDisabled)),
        ),
      );
    }

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 18, color: NothingTheme.textSecondary),
                    onPressed: () {
                      ref.read(timerProvider.notifier).reset();
                      Navigator.of(context)
                          .popUntil((route) => route.isFirst);
                    },
                  ),
                  const Spacer(),
                  Text(
                    'WORKOUT COMPLETE',
                    style: NothingTheme.label(
                        fontSize: 11, color: NothingTheme.textSecondary),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),

            const Divider(height: 1, color: NothingTheme.borderSubtle),

            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Routine name ───────────────────────────────────────
                    Text(
                      routine.name.toUpperCase(),
                      style: NothingTheme.label(
                          fontSize: 11, color: NothingTheme.textDisabled),
                    ),
                    const SizedBox(height: 8),

                    // ── Hero total time ─────────────────────────────────────
                    _HeroTime(elapsed: timer.totalElapsed),

                    const SizedBox(height: 32),

                    // ── Stats grid ──────────────────────────────────────────
                    _StatsGrid(
                      health: health,
                      splits: timer.splits,
                      exercises: routine.exercises,
                    ),

                    const SizedBox(height: 32),

                    // ── Completed progress ──────────────────────────────────
                    SegmentedProgress(
                      totalSegments: routine.exercises.length,
                      completedSegments: routine.exercises.length,
                      currentSegment: routine.exercises.length,
                      height: 5,
                    ),

                    const SizedBox(height: 32),

                    // ── Splits ──────────────────────────────────────────────
                    Text(
                      'SPLITS',
                      style: NothingTheme.label(
                          fontSize: 11, color: NothingTheme.textDisabled),
                    ),
                    const SizedBox(height: 12),

                    ...List.generate(routine.exercises.length, (i) {
                      final exercise = routine.exercises[i];
                      final split = i < timer.splits.length
                          ? timer.splits[i]
                          : null;
                      final isRun =
                          PredefinedRoutines.isRunSegment(exercise);
                      return _SplitRow(
                        index: i + 1,
                        name: exercise.name,
                        split: split,
                        isRun: isRun,
                      );
                    }),

                    const SizedBox(height: 32),

                    // ── Action buttons ──────────────────────────────────────
                    _ActionButton(
                      label: '[ NEW WORKOUT ]',
                      primary: true,
                      onTap: () {
                        ref.read(timerProvider.notifier).reset();
                        Navigator.of(context)
                            .popUntil((route) => route.isFirst);
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────
class _HeroTime extends StatelessWidget {
  const _HeroTime({required this.elapsed});
  final Duration elapsed;

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);
    return Text(
      h > 0
          ? '${two(h)}:${two(m)}:${two(s)}'
          : '${two(m)}:${two(s)}',
      style: GoogleFonts.spaceMono(
        fontSize: 72,
        fontWeight: FontWeight.w700,
        color: NothingTheme.textDisplay,
        height: 1.0,
        letterSpacing: -2,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

class _StatsGrid extends StatelessWidget {
  const _StatsGrid({
    required this.health,
    required this.splits,
    required this.exercises,
  });
  final HealthMetrics health;
  final List<Duration> splits;
  final List<Exercise> exercises;

  @override
  Widget build(BuildContext context) {
    final avgHr = health.heartRate;

    // Best 1 km run split
    Duration? bestRun;
    for (var i = 0; i < splits.length && i < exercises.length; i++) {
      if (PredefinedRoutines.isRunSegment(exercises[i])) {
        final d = splits[i];
        if (bestRun == null || d < bestRun) bestRun = d;
      }
    }

    return Row(
      children: [
        _StatCell(
          label: 'AVG HR',
          value: avgHr != null ? '$avgHr' : '--',
          unit: 'BPM',
        ),
        const SizedBox(width: 1),
        _StatCell(
          label: 'CALORIES',
          value: health.totalCalories > 0
              ? health.totalCalories.toStringAsFixed(0)
              : '--',
          unit: 'KCAL',
        ),
        const SizedBox(width: 1),
        _StatCell(
          label: 'BEST RUN',
          value: bestRun != null ? _fmtSplit(bestRun) : '--:--',
          unit: 'MIN',
        ),
      ],
    );
  }

  static String _fmtSplit(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

class _StatCell extends StatelessWidget {
  const _StatCell({
    required this.label,
    required this.value,
    required this.unit,
  });
  final String label;
  final String value;
  final String unit;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: NothingTheme.surface,
          border: Border.all(color: NothingTheme.borderSubtle),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style:
                  NothingTheme.label(fontSize: 9, color: NothingTheme.textDisabled),
            ),
            const SizedBox(height: 6),
            Text(
              value,
              style: GoogleFonts.spaceMono(
                fontSize: 24,
                fontWeight: FontWeight.w700,
                color: NothingTheme.textDisplay,
                height: 1.0,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(height: 2),
            Text(
              unit,
              style:
                  NothingTheme.label(fontSize: 9, color: NothingTheme.textDisabled),
            ),
          ],
        ),
      ),
    );
  }
}

class _SplitRow extends StatelessWidget {
  const _SplitRow({
    required this.index,
    required this.name,
    required this.split,
    required this.isRun,
  });
  final int index;
  final String name;
  final Duration? split;
  final bool isRun;

  @override
  Widget build(BuildContext context) {
    final splitColor =
        isRun ? NothingTheme.accent : NothingTheme.textPrimary;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: NothingTheme.borderSubtle),
        ),
      ),
      child: Row(
        children: [
          // Index
          SizedBox(
            width: 28,
            child: Text(
              '$index',
              style: NothingTheme.label(
                  fontSize: 10, color: NothingTheme.textDisabled),
            ),
          ),
          // Run indicator dot
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRun ? NothingTheme.accent : NothingTheme.borderSubtle,
            ),
          ),
          // Name
          Expanded(
            child: Text(
              name,
              style: NothingTheme.body(
                  fontSize: 13, color: NothingTheme.textPrimary),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // Split time
          if (split != null)
            Text(
              _fmt(split!),
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: splitColor,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
          else
            Text(
              '--:--',
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                color: NothingTheme.textDisabled,
              ),
            ),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.primary,
    required this.onTap,
  });
  final String label;
  final bool primary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 18),
        decoration: BoxDecoration(
          color: primary ? NothingTheme.textDisplay : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: primary
              ? null
              : Border.all(color: NothingTheme.borderVisible),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: primary ? NothingTheme.black : NothingTheme.textPrimary,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

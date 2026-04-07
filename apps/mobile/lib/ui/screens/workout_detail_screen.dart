import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/predefined_routines.dart';
import '../../models/workout_record.dart';
import '../theme/nothing_theme.dart';
import 'progress_screen.dart';

class WorkoutDetailScreen extends StatelessWidget {
  const WorkoutDetailScreen({super.key, required this.record});
  final WorkoutRecord record;

  @override
  Widget build(BuildContext context) {
    final routine = PredefinedRoutines.byName(record.routineName);

    // Best run split
    Duration? bestRun;
    if (routine != null) {
      for (var i = 0; i < record.splits.length && i < routine.exercises.length; i++) {
        if (PredefinedRoutines.isRunSegment(routine.exercises[i])) {
          if (bestRun == null || record.splits[i] < bestRun!) {
            bestRun = record.splits[i];
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header ──────────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_ios,
                        size: 18, color: NothingTheme.textSecondary),
                    onPressed: () => Navigator.of(context).pop(),
                    padding: const EdgeInsets.all(8),
                  ),
                  const Spacer(),
                  Text(
                    record.routineName.toUpperCase(),
                    style: NothingTheme.label(
                        fontSize: 11, color: NothingTheme.textSecondary),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.show_chart,
                        size: 18, color: NothingTheme.textSecondary),
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ProgressScreen(
                            routineName: record.routineName),
                      ),
                    ),
                    padding: const EdgeInsets.all(8),
                  ),
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
                    // Date
                    Text(
                      _fmtDate(record.completedAt),
                      style: NothingTheme.label(
                          fontSize: 11, color: NothingTheme.textDisabled),
                    ),
                    const SizedBox(height: 8),

                    // Hero total time
                    _HeroTime(elapsed: record.totalDuration),

                    const SizedBox(height: 32),

                    // Stats grid
                    Row(
                      children: [
                        _StatCell(
                          label: 'AVG HR',
                          value: record.avgHeartRate != null
                              ? '${record.avgHeartRate}'
                              : '--',
                          unit: 'BPM',
                        ),
                        const SizedBox(width: 1),
                        _StatCell(
                          label: 'CALORIES',
                          value: record.totalCalories != null
                              ? record.totalCalories!.toStringAsFixed(0)
                              : '--',
                          unit: 'KCAL',
                        ),
                        const SizedBox(width: 1),
                        _StatCell(
                          label: 'BEST RUN',
                          value: bestRun != null ? _fmtShort(bestRun!) : '--:--',
                          unit: 'MIN',
                        ),
                      ],
                    ),

                    const SizedBox(height: 32),

                    // Splits header
                    Text(
                      'SPLITS',
                      style: NothingTheme.label(
                          fontSize: 11, color: NothingTheme.textDisabled),
                    ),
                    const SizedBox(height: 12),

                    // Splits interleaved with rox zone rows
                    ...() {
                      final rows = <Widget>[];
                      final exercises = routine?.exercises ?? [];
                      for (var i = 0; i < exercises.length; i++) {
                        final ex = exercises[i];
                        final split =
                            i < record.splits.length ? record.splits[i] : null;
                        final isRun = PredefinedRoutines.isRunSegment(ex);
                        rows.add(_SplitRow(
                          index: i + 1,
                          name: ex.name,
                          split: split,
                          isRun: isRun,
                        ));
                        if (i < exercises.length - 1 &&
                            i < record.roxZoneSplits.length) {
                          rows.add(_RoxZoneRow(
                            split: record.roxZoneSplits[i],
                          ));
                        }
                      }
                      return rows;
                    }(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static const _months = [
    '', 'JAN', 'FEB', 'MAR', 'APR', 'MAY', 'JUN',
    'JUL', 'AUG', 'SEP', 'OCT', 'NOV', 'DEC',
  ];

  static String _fmtDate(DateTime dt) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${dt.day} ${_months[dt.month]} ${dt.year}  ·  ${two(dt.hour)}:${two(dt.minute)}';
  }

  static String _fmtShort(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
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
            Text(label,
                style: NothingTheme.label(
                    fontSize: 9, color: NothingTheme.textDisabled)),
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
            Text(unit,
                style: NothingTheme.label(
                    fontSize: 9, color: NothingTheme.textDisabled)),
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
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: NothingTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Text('$index',
                style: NothingTheme.label(
                    fontSize: 10, color: NothingTheme.textDisabled)),
          ),
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isRun ? NothingTheme.accent : NothingTheme.borderSubtle,
            ),
          ),
          Expanded(
            child: Text(name,
                style: NothingTheme.body(
                    fontSize: 13, color: NothingTheme.textPrimary),
                overflow: TextOverflow.ellipsis),
          ),
          if (split != null)
            Text(
              _fmt(split!),
              style: GoogleFonts.spaceMono(
                fontSize: 13,
                fontWeight: FontWeight.w700,
                color: isRun ? NothingTheme.accent : NothingTheme.textPrimary,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            )
          else
            Text('--:--',
                style: GoogleFonts.spaceMono(
                    fontSize: 13, color: NothingTheme.textDisabled)),
        ],
      ),
    );
  }

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

class _RoxZoneRow extends StatelessWidget {
  const _RoxZoneRow({required this.split});
  final Duration split;

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final time =
        '${two(split.inMinutes.remainder(60))}:${two(split.inSeconds.remainder(60))}';
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: const BoxDecoration(
        border:
            Border(bottom: BorderSide(color: NothingTheme.borderSubtle)),
      ),
      child: Row(
        children: [
          const SizedBox(width: 28),
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(right: 10),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              color: NothingTheme.accent,
            ),
          ),
          Expanded(
            child: Text('ROX ZONE',
                style: NothingTheme.label(
                    fontSize: 11, color: NothingTheme.accent)),
          ),
          Text(
            time,
            style: GoogleFonts.spaceMono(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: NothingTheme.accent,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/workout_record.dart';
import '../../providers/workout_history_provider.dart';
import '../theme/nothing_theme.dart';
import 'workout_detail_screen.dart';

class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(workoutHistoryProvider);

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
                    'HISTORY',
                    style: NothingTheme.label(
                        fontSize: 11, color: NothingTheme.textSecondary),
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Divider(height: 1, color: NothingTheme.borderSubtle),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: historyAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(
                      color: NothingTheme.textDisplay),
                ),
                error: (e, _) => Center(
                  child: Text(
                    'ERROR LOADING HISTORY',
                    style: NothingTheme.label(
                        fontSize: 11, color: NothingTheme.danger),
                  ),
                ),
                data: (records) => records.isEmpty
                    ? Center(
                        child: Text(
                          'NO WORKOUTS YET',
                          style: NothingTheme.label(
                              fontSize: 11,
                              color: NothingTheme.textDisabled),
                        ),
                      )
                    : ListView.separated(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                        itemCount: records.length,
                        separatorBuilder: (_, __) => const Divider(
                            height: 1, color: NothingTheme.borderSubtle),
                        itemBuilder: (context, i) =>
                            _WorkoutHistoryRow(record: records[i]),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _WorkoutHistoryRow extends StatelessWidget {
  const _WorkoutHistoryRow({required this.record});
  final WorkoutRecord record;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => WorkoutDetailScreen(record: record),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    record.routineName.toUpperCase(),
                    style: NothingTheme.body(
                      fontSize: 14,
                      weight: FontWeight.w600,
                      color: NothingTheme.textDisplay,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _fmtDate(record.completedAt),
                    style: NothingTheme.label(
                        fontSize: 10, color: NothingTheme.textDisabled),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Text(
              _fmtDuration(record.totalDuration),
              style: GoogleFonts.spaceMono(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: NothingTheme.textDisplay,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right,
                size: 18, color: NothingTheme.textDisabled),
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

  static String _fmtDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
    }
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

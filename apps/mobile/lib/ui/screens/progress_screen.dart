import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/predefined_routines.dart';
import '../../providers/workout_stats_provider.dart';
import '../theme/nothing_theme.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key, required this.routineName});
  final String routineName;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final stats = ref.watch(workoutStatsProvider(routineName));

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
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text('PROGRESS',
                          style: NothingTheme.label(
                              fontSize: 11,
                              color: NothingTheme.textSecondary)),
                      Text(routineName.toUpperCase(),
                          style: NothingTheme.label(
                              fontSize: 9,
                              color: NothingTheme.textDisabled)),
                    ],
                  ),
                  const Spacer(),
                  const SizedBox(width: 40),
                ],
              ),
            ),
            const Divider(height: 1, color: NothingTheme.borderSubtle),

            // ── Body ─────────────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Total time chart ─────────────────────────────────────
                    Text('TOTAL TIME',
                        style: NothingTheme.label(
                            fontSize: 11, color: NothingTheme.textDisabled)),
                    const SizedBox(height: 12),
                    SizedBox(
                      height: 200,
                      child: stats.hasEnoughData
                          ? _TotalTimeChart(
                              series: stats.totalTimeSeries)
                          : _NoDataPlaceholder(
                              count: stats.records.length),
                    ),

                    const SizedBox(height: 40),

                    // ── Per-exercise split charts ─────────────────────────────
                    Text('EXERCISE SPLITS',
                        style: NothingTheme.label(
                            fontSize: 11, color: NothingTheme.textDisabled)),
                    const SizedBox(height: 12),

                    if (stats.splitsByExercise.isEmpty)
                      _NoDataPlaceholder(count: stats.records.length)
                    else
                      ...() {
                        final routine =
                            PredefinedRoutines.byName(routineName);
                        if (routine == null) return <Widget>[];
                        return routine.exercises.where((ex) {
                          return stats.splitsByExercise
                                  .containsKey(ex.name) &&
                              stats.splitsByExercise[ex.name]!.length >= 2;
                        }).map((ex) {
                          final isRun =
                              PredefinedRoutines.isRunSegment(ex);
                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 5,
                                    height: 5,
                                    margin: const EdgeInsets.only(right: 8),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isRun
                                          ? NothingTheme.accent
                                          : NothingTheme.textSecondary,
                                    ),
                                  ),
                                  Text(
                                    ex.name.toUpperCase(),
                                    style: NothingTheme.label(
                                        fontSize: 10,
                                        color: NothingTheme.textSecondary),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              SizedBox(
                                height: 140,
                                child: _SplitChart(
                                  series:
                                      stats.splitsByExercise[ex.name]!,
                                  isRun: isRun,
                                ),
                              ),
                              const SizedBox(height: 28),
                            ],
                          );
                        }).toList();
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
}

// ── Chart helpers ────────────────────────────────────────────────────────────

String _fmtSeconds(double seconds) {
  String two(int n) => n.toString().padLeft(2, '0');
  final m = seconds ~/ 60;
  final s = (seconds % 60).round();
  return '${two(m)}:${two(s)}';
}

FlGridData _gridData(double interval) => FlGridData(
      show: true,
      drawVerticalLine: false,
      horizontalInterval: interval,
      getDrawingHorizontalLine: (_) => const FlLine(
        color: NothingTheme.borderSubtle,
        strokeWidth: 1,
      ),
    );

FlTitlesData _titlesData(double interval) => FlTitlesData(
      show: true,
      bottomTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      topTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      rightTitles:
          const AxisTitles(sideTitles: SideTitles(showTitles: false)),
      leftTitles: AxisTitles(
        sideTitles: SideTitles(
          showTitles: true,
          reservedSize: 44,
          interval: interval,
          getTitlesWidget: (value, _) => Text(
            _fmtSeconds(value),
            style: GoogleFonts.spaceMono(
              fontSize: 8,
              color: NothingTheme.textDisabled,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ),
    );

LineChartBarData _barData(List<FlSpot> spots, Color color) =>
    LineChartBarData(
      spots: spots,
      isCurved: false,
      color: color,
      barWidth: 1.5,
      dotData: FlDotData(
        show: true,
        getDotPainter: (_, __, ___, ____) => FlDotCirclePainter(
          radius: 3,
          color: color,
          strokeWidth: 0,
        ),
      ),
    );

// ── Total time chart ─────────────────────────────────────────────────────────
class _TotalTimeChart extends StatelessWidget {
  const _TotalTimeChart({required this.series});
  final List<(DateTime, Duration)> series;

  @override
  Widget build(BuildContext context) {
    final spots = series
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              e.value.$2.inSeconds.toDouble(),
            ))
        .toList();

    final values = spots.map((s) => s.y).toList()..sort();
    final minY = (values.first * 0.95).floorToDouble();
    final maxY = (values.last * 1.05).ceilToDouble();
    final interval = ((maxY - minY) / 4).ceilToDouble().clamp(30.0, 600.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        border: Border.all(color: NothingTheme.borderSubtle),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: _gridData(interval),
          titlesData: _titlesData(interval),
          borderData: FlBorderData(show: false),
          lineBarsData: [_barData(spots, NothingTheme.accent)],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => NothingTheme.surface,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        _fmtSeconds(s.y),
                        GoogleFonts.spaceMono(
                          fontSize: 11,
                          color: NothingTheme.accent,
                          fontWeight: FontWeight.w700,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Per-exercise split chart ──────────────────────────────────────────────────
class _SplitChart extends StatelessWidget {
  const _SplitChart({required this.series, required this.isRun});
  final List<(DateTime, Duration)> series;
  final bool isRun;

  @override
  Widget build(BuildContext context) {
    final color =
        isRun ? NothingTheme.accent : NothingTheme.textSecondary;
    final spots = series
        .asMap()
        .entries
        .map((e) => FlSpot(
              e.key.toDouble(),
              e.value.$2.inSeconds.toDouble(),
            ))
        .toList();

    final values = spots.map((s) => s.y).toList()..sort();
    final minY = (values.first * 0.95).floorToDouble();
    final maxY = (values.last * 1.05).ceilToDouble();
    final interval = ((maxY - minY) / 3).ceilToDouble().clamp(10.0, 300.0);

    return Container(
      padding: const EdgeInsets.fromLTRB(0, 8, 16, 8),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        border: Border.all(color: NothingTheme.borderSubtle),
      ),
      child: LineChart(
        LineChartData(
          minY: minY,
          maxY: maxY,
          gridData: _gridData(interval),
          titlesData: _titlesData(interval),
          borderData: FlBorderData(show: false),
          lineBarsData: [_barData(spots, color)],
          lineTouchData: LineTouchData(
            touchTooltipData: LineTouchTooltipData(
              getTooltipColor: (_) => NothingTheme.surface,
              getTooltipItems: (spots) => spots
                  .map((s) => LineTooltipItem(
                        _fmtSeconds(s.y),
                        GoogleFonts.spaceMono(
                          fontSize: 11,
                          color: color,
                          fontWeight: FontWeight.w700,
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ),
    );
  }
}

// ── No-data placeholder ───────────────────────────────────────────────────────
class _NoDataPlaceholder extends StatelessWidget {
  const _NoDataPlaceholder({required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    final msg = count == 0
        ? 'NO WORKOUTS YET'
        : count == 1
            ? '1 WORKOUT LOGGED\n2+ REQUIRED FOR CHARTS'
            : 'NOT ENOUGH DATA';
    return Container(
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        border: Border.all(color: NothingTheme.borderSubtle),
      ),
      child: Center(
        child: Text(
          msg,
          style: NothingTheme.label(
              fontSize: 11, color: NothingTheme.textDisabled),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}

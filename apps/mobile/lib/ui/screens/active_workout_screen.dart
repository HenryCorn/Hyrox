import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/predefined_routines.dart';
import '../../providers/timer_provider.dart';
import '../../providers/timer_state.dart';
import '../../providers/health_provider.dart';
import '../../providers/target_provider.dart';
import '../theme/nothing_theme.dart';
import '../widgets/segmented_progress.dart';
import '../widgets/pace_indicator.dart';
import 'summary_screen.dart';

class ActiveWorkoutScreen extends ConsumerStatefulWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  ConsumerState<ActiveWorkoutScreen> createState() =>
      _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends ConsumerState<ActiveWorkoutScreen> {
  bool _workoutStartedHealth = false;

  @override
  Widget build(BuildContext context) {
    final timer = ref.watch(timerProvider);
    final health = ref.watch(healthProvider);
    final target = ref.watch(targetProvider);
    final routine = timer.activeRoutine;

    // Navigate to summary when workout finishes
    ref.listen(timerProvider, (prev, next) {
      if (next.status == TimerStatus.finished) {
        ref.read(healthProvider.notifier).workoutStopped();
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const SummaryScreen()),
        );
      }
      // Start health tracking on first start
      if (prev?.status == TimerStatus.initial &&
          next.status == TimerStatus.running &&
          !_workoutStartedHealth) {
        _workoutStartedHealth = true;
        ref.read(healthProvider.notifier).workoutStarted();
        _updateRunTracking(next);
      }
      // When exercise index changes, update run tracking
      if (prev?.currentExerciseIndex != next.currentExerciseIndex ||
          prev?.isInRoxZone != next.isInRoxZone) {
        _updateRunTracking(next);
        _syncToWatch(next);
      }
    });

    if (routine == null) {
      return const Scaffold(
        backgroundColor: NothingTheme.black,
        body: Center(
            child: CircularProgressIndicator(color: NothingTheme.textDisplay)),
      );
    }

    final exercise = routine.exercises[timer.currentExerciseIndex];
    final isRun = PredefinedRoutines.isRunSegment(exercise);
    final isRunning = timer.status == TimerStatus.running;
    final isPaused = timer.status == TimerStatus.paused;
    final isInitial = timer.status == TimerStatus.initial;

    // ── Pace status computation ──────────────────────────────────────────
    final segmentTarget =
        target.targetForExercise(timer.currentExerciseIndex, routine);
    final segmentPaceStatus =
        computePaceStatus(timer.currentExerciseElapsed, segmentTarget);
    final overallPaceStatus = computeOverallPaceStatus(
      completedSplits: timer.splits,
      currentElapsed: timer.currentExerciseElapsed,
      currentIndex: timer.currentExerciseIndex,
      target: target,
      routine: routine,
    );

    // Color: use pace status when targets are set, otherwise default behavior
    final Color accentColor;
    if (segmentPaceStatus != PaceStatus.none) {
      accentColor = paceColor(segmentPaceStatus, isRun: isRun);
    } else {
      accentColor = isRun ? NothingTheme.accent : NothingTheme.textDisplay;
    }

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ────────────────────────────────────────────────────
            _TopBar(
              routineName: routine.name,
              overallStatus: overallPaceStatus,
              onBack: () {
                ref.read(timerProvider.notifier).reset();
                ref.read(healthProvider.notifier).workoutStopped();
                Navigator.of(context).pop();
              },
            ),

            // ── Segmented progress ─────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SegmentedProgress(
                totalSegments: routine.exercises.length,
                completedSegments: timer.splits.length,
                currentSegment: timer.currentExerciseIndex,
                accentCurrent: isRun,
                height: 5,
              ),
            ),
            const SizedBox(height: 20),

            // ── Main content ───────────────────────────────────────────────
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Segment counter + pace indicator
                    Row(
                      children: [
                        Text(
                          '${timer.currentExerciseIndex + 1} / ${routine.exercises.length}',
                          style: NothingTheme.label(
                              fontSize: 11, color: NothingTheme.textDisabled),
                        ),
                        const Spacer(),
                        PaceIndicator(status: segmentPaceStatus),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Hero timer (the "one break") ─────────────────────
                    _HeroTimer(
                      elapsed: timer.currentExerciseElapsed,
                      color: accentColor,
                    ),

                    // ── Target line below hero timer ─────────────────────
                    if (segmentTarget != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Text(
                            'TARGET  ${_fmt(segmentTarget)}',
                            style: NothingTheme.label(
                                fontSize: 10, color: NothingTheme.textDisabled),
                          ),
                          const SizedBox(width: 12),
                          PaceDelta(
                            elapsed: timer.currentExerciseElapsed,
                            target: segmentTarget,
                          ),
                        ],
                      ),
                    ],

                    const SizedBox(height: 16),

                    // Exercise name
                    Text(
                      exercise.name.toUpperCase(),
                      style: NothingTheme.body(
                        fontSize: 20,
                        weight: FontWeight.w600,
                        color: NothingTheme.textDisplay,
                      ),
                    ),
                    if (exercise.description.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        exercise.description,
                        style: NothingTheme.label(
                            fontSize: 11, color: NothingTheme.textSecondary),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    if (exercise.weight != null) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          border: Border.all(color: NothingTheme.borderVisible),
                        ),
                        child: Text(
                          '${exercise.weight} KG',
                          style: NothingTheme.label(
                              fontSize: 11,
                              color: NothingTheme.textPrimary),
                        ),
                      ),
                    ],

                    const Spacer(),

                    // ── Live metrics row ──────────────────────────────────
                    _MetricsRow(
                      health: health,
                      totalElapsed: timer.totalElapsed,
                      isRun: isRun,
                    ),

                    const SizedBox(height: 20),

                    // ── Control buttons ───────────────────────────────────
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _PillButton(
                            label: isInitial
                                ? '[ START ]'
                                : (isPaused ? '[ RESUME ]' : '[ PAUSE ]'),
                            primary: isInitial || isPaused,
                            onTap: () {
                              if (isInitial || isPaused) {
                                ref.read(timerProvider.notifier).resume();
                              } else {
                                ref.read(timerProvider.notifier).pause();
                              }
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 2,
                          child: _PillButton(
                            label: '[ NEXT ]',
                            primary: false,
                            onTap: isRunning || isPaused
                                ? () => ref
                                    .read(timerProvider.notifier)
                                    .nextExercise()
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),

                    // ── Total time + overall pace ────────────────────────
                    Center(
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'TOTAL  ${_fmt(timer.totalElapsed)}',
                            style: NothingTheme.label(
                                fontSize: 11, color: NothingTheme.textDisabled),
                          ),
                          if (overallPaceStatus != PaceStatus.none) ...[
                            const SizedBox(width: 8),
                            PaceIndicator(
                              status: overallPaceStatus,
                              fontSize: 9,
                              showLabel: false,
                            ),
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _updateRunTracking(TimerState state) {
    if (state.activeRoutine == null) return;
    final exercise =
        state.activeRoutine!.exercises[state.currentExerciseIndex];
    final isRun = PredefinedRoutines.isRunSegment(exercise);
    if (isRun && state.status == TimerStatus.running) {
      ref.read(healthProvider.notifier).startRunTracking();
    } else {
      ref.read(healthProvider.notifier).stopRunTracking();
    }
  }

  void _syncToWatch(TimerState state) {
    if (state.activeRoutine == null) return;
    final exercise =
        state.activeRoutine!.exercises[state.currentExerciseIndex];
    ref.read(healthProvider.notifier).syncToWatch(
          exerciseIndex: state.currentExerciseIndex,
          exerciseName: exercise.name,
          isRun: PredefinedRoutines.isRunSegment(exercise),
          isRunning: state.status == TimerStatus.running,
          totalElapsedMs: state.totalElapsed.inMilliseconds,
          exerciseElapsedMs: state.currentExerciseElapsed.inMilliseconds,
          totalExercises: state.activeRoutine!.exercises.length,
        );
  }

  static String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
    }
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

// ── Sub-widgets ──────────────────────────────────────────────────────────────
class _TopBar extends StatelessWidget {
  const _TopBar({
    required this.routineName,
    required this.overallStatus,
    required this.onBack,
  });
  final String routineName;
  final PaceStatus overallStatus;
  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(8, 8, 16, 8),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios,
                size: 18, color: NothingTheme.textSecondary),
            onPressed: onBack,
            padding: const EdgeInsets.all(8),
          ),
          const Spacer(),
          Text(
            routineName.toUpperCase(),
            style: NothingTheme.label(
                fontSize: 11, color: NothingTheme.textSecondary),
          ),
          if (overallStatus != PaceStatus.none) ...[
            const SizedBox(width: 6),
            PaceIndicator(
              status: overallStatus,
              fontSize: 9,
              showLabel: false,
            ),
          ],
          const Spacer(),
          const SizedBox(width: 40), // balance the back button
        ],
      ),
    );
  }
}

class _HeroTimer extends StatelessWidget {
  const _HeroTimer({required this.elapsed, required this.color});
  final Duration elapsed;
  final Color color;

  @override
  Widget build(BuildContext context) {
    String two(int n) => n.toString().padLeft(2, '0');
    final h = elapsed.inHours;
    final m = elapsed.inMinutes.remainder(60);
    final s = elapsed.inSeconds.remainder(60);
    final cs = (elapsed.inMilliseconds.remainder(1000) ~/ 10);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (h > 0) ...[
          Text(
            '${two(h)}:',
            style: GoogleFonts.spaceMono(
              fontSize: 64,
              fontWeight: FontWeight.w700,
              color: color,
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
        Text(
          '${two(m)}:${two(s)}',
          style: GoogleFonts.spaceMono(
            fontSize: 64,
            fontWeight: FontWeight.w700,
            color: color,
            height: 1.0,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
        Padding(
          padding: const EdgeInsets.only(bottom: 8, left: 4),
          child: Text(
            '.${two(cs)}',
            style: GoogleFonts.spaceMono(
              fontSize: 24,
              fontWeight: FontWeight.w400,
              color: color.withValues(alpha: 0.5),
              height: 1.0,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _MetricsRow extends StatelessWidget {
  const _MetricsRow({
    required this.health,
    required this.totalElapsed,
    required this.isRun,
  });
  final HealthMetrics health;
  final Duration totalElapsed;
  final bool isRun;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        border: Border.all(color: NothingTheme.borderSubtle),
      ),
      child: Row(
        children: [
          _Metric(
            label: 'BPM',
            value: health.heartRateDisplay,
            highlight: health.heartRate != null &&
                health.heartRate! > 170,
          ),
          _vDivider(),
          _Metric(
            label: 'KCAL',
            value: health.caloriesDisplay,
          ),
          _vDivider(),
          if (isRun)
            _Metric(
              label: 'PACE /KM',
              value: health.currentPaceSecsPerKm > 0
                  ? _fmtPace(health.currentPaceSecsPerKm)
                  : '--:--',
              highlight: true,
              highlightColor: NothingTheme.accent,
            )
          else
            _Metric(
              label: 'TIME',
              value: _fmtShort(totalElapsed),
            ),
        ],
      ),
    );
  }

  Widget _vDivider() => Container(
        width: 1,
        height: 32,
        margin: const EdgeInsets.symmetric(horizontal: 12),
        color: NothingTheme.borderSubtle,
      );

  static String _fmtPace(double secsPerKm) {
    final m = secsPerKm ~/ 60;
    final s = (secsPerKm % 60).round();
    return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
  }

  static String _fmtShort(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

class _Metric extends StatelessWidget {
  const _Metric({
    required this.label,
    required this.value,
    this.highlight = false,
    this.highlightColor = NothingTheme.textDisplay,
  });
  final String label;
  final String value;
  final bool highlight;
  final Color highlightColor;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Text(
            label,
            style: NothingTheme.label(
                fontSize: 9, color: NothingTheme.textDisabled),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: GoogleFonts.spaceMono(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: highlight ? highlightColor : NothingTheme.textPrimary,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
        ],
      ),
    );
  }
}

class _PillButton extends StatelessWidget {
  const _PillButton({
    required this.label,
    required this.primary,
    this.onTap,
  });
  final String label;
  final bool primary;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final enabled = onTap != null;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: primary ? NothingTheme.textDisplay : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: primary
              ? null
              : Border.all(
                  color: enabled
                      ? NothingTheme.borderVisible
                      : NothingTheme.borderSubtle,
                ),
        ),
        child: Center(
          child: Text(
            label,
            style: GoogleFonts.spaceMono(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: primary
                  ? NothingTheme.black
                  : (enabled
                      ? NothingTheme.textPrimary
                      : NothingTheme.textDisabled),
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/app_database.dart';
import '../../models/exercise.dart';
import '../../models/predefined_routines.dart';
import '../../models/workout_record.dart';
import '../../providers/ad_provider.dart';
import '../../providers/timer_provider.dart';
import '../../providers/timer_state.dart';
import '../../providers/health_provider.dart';
import '../../providers/target_provider.dart';
import '../../providers/workout_history_provider.dart';
import '../../services/ad_service.dart';
import '../theme/nothing_theme.dart';
import '../widgets/banner_ad_widget.dart';
import '../widgets/pace_indicator.dart';
import '../widgets/segmented_progress.dart';
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

    // Navigate to summary when workout finishes (via rewarded ad gate)
    ref.listen(timerProvider, (prev, next) {
      if (next.status == TimerStatus.finished) {
        ref.read(healthProvider.notifier).workoutStopped();
        _finishWithAd(next, ref.read(healthProvider));
      }
      // Start health tracking and preload the save-gate ad on first start
      if (prev?.status == TimerStatus.initial &&
          next.status == TimerStatus.running &&
          !_workoutStartedHealth) {
        _workoutStartedHealth = true;
        ref.read(healthProvider.notifier).workoutStarted();
        _updateRunTracking(next);
        ref.read(adServiceProvider).preloadSaveAd();
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
    final isRoxZone = timer.isInRoxZone;

    // In Rox Zone show next exercise info; otherwise show current.
    final nextExerciseIndex = timer.currentExerciseIndex + 1;
    final nextExercise = nextExerciseIndex < routine.exercises.length
        ? routine.exercises[nextExerciseIndex]
        : null;

    // ── Pace status computation ──────────────────────────────────────────
    // Rox Zone is an untimed transition — never apply an exercise target there.
    final segmentTarget = isRoxZone
        ? null
        : target.targetForExercise(timer.currentExerciseIndex, routine);
    final segmentPaceStatus =
        computePaceStatus(timer.currentExerciseElapsed, segmentTarget);
    final overallPaceStatus = computeOverallPaceStatus(
      completedSplits: timer.splits,
      currentElapsed: timer.currentExerciseElapsed,
      currentIndex: timer.currentExerciseIndex,
      target: target,
      routine: routine,
    );

    // Pace status drives color when targets are set; fall back to
    // Rox Zone / run defaults when no targets are configured.
    final Color accentColor;
    if (segmentPaceStatus != PaceStatus.none) {
      accentColor = paceColor(segmentPaceStatus, isRun: isRun);
    } else {
      accentColor = (isRun || isRoxZone) ? NothingTheme.accent : NothingTheme.textDisplay;
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

                    // ── Hero timer ────────────────────────────────────────
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

                    // Exercise name / Rox Zone header
                    if (isRoxZone) ...[
                      Text(
                        'ROX ZONE',
                        style: NothingTheme.body(
                          fontSize: 20,
                          weight: FontWeight.w600,
                          color: NothingTheme.accent,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'TRANSITION — HEAD TO NEXT STATION',
                        style: NothingTheme.label(
                            fontSize: 11, color: NothingTheme.textSecondary),
                      ),
                      if (nextExercise != null) ...[
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            border: Border.all(color: NothingTheme.accent),
                          ),
                          child: Text(
                            'UP NEXT: ${nextExercise.name.toUpperCase()}${nextExercise.weightNote != null ? "  ·  ${nextExercise.weightNote}" : ""}',
                            style: NothingTheme.label(
                                fontSize: 11, color: NothingTheme.accent),
                          ),
                        ),
                      ],
                    ] else ...[
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
                            border:
                                Border.all(color: NothingTheme.borderVisible),
                          ),
                          child: Text(
                            '${exercise.weight} KG',
                            style: NothingTheme.label(
                                fontSize: 11,
                                color: NothingTheme.textPrimary),
                          ),
                        ),
                      ],
                    ],

                    const SizedBox(height: 16),

                    // ── Programme tracker ─────────────────────────────────
                    Expanded(
                      child: _WorkoutTimeline(
                        exercises: routine.exercises,
                        currentIndex: timer.currentExerciseIndex,
                        splits: timer.splits,
                        isRoxZone: isRoxZone,
                      ),
                    ),

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
                          child: _HoldNextButton(
                            enabled: isRunning || isPaused,
                            onConfirm: () => ref
                                .read(timerProvider.notifier)
                                .nextExercise(),
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

            // ── Station banner ad ─────────────────────────────────────────
            // Shown only during station exercises. User is doing burpees or
            // rowing — they are NOT looking at the phone. Slides in/out
            // smoothly when exercise type changes.
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: (!isRun && !isRoxZone)
                  ? Center(
                      key: const ValueKey('station-banner'),
                      child: BannerAdWidget(adUnitId: AdIds.bannerStation),
                    )
                  : const SizedBox.shrink(key: ValueKey('no-banner')),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _finishWithAd(TimerState timer, HealthMetrics health) async {
    // Show the rewarded ad. Save & navigate regardless of the outcome —
    // never block the user from their workout data due to ad issues.
    await ref.read(adServiceProvider).showSaveRewardedAd();
    _saveWorkout(timer, health);
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const SummaryScreen()),
      );
    }
  }

  void _saveWorkout(TimerState timer, HealthMetrics health) async {
    if (timer.activeRoutine == null) return;
    final userId = await AppDatabase.instance.localUserId;
    final now = DateTime.now();
    final record = WorkoutRecord(
      id: '${now.millisecondsSinceEpoch}-${timer.startTime?.millisecondsSinceEpoch ?? 0}',
      userId: userId,
      routineName: timer.activeRoutine!.name,
      completedAt: now,
      totalDuration: timer.totalElapsed,
      splits: List.unmodifiable(timer.splits),
      roxZoneSplits: List.unmodifiable(timer.roxZoneSplits),
      avgHeartRate: health.heartRate,
      totalCalories: health.totalCalories > 0 ? health.totalCalories : null,
    );
    // ignore: use_build_context_synchronously
    await ref.read(workoutHistoryProvider.notifier).save(record);
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
            highlight: health.heartRate != null && health.heartRate! > 170,
            highlightColor: NothingTheme.danger,
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
              highlightColor: NothingTheme.accent, // Hyrox yellow
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

class _HoldNextButton extends StatefulWidget {
  const _HoldNextButton({required this.enabled, required this.onConfirm});
  final bool enabled;
  final VoidCallback onConfirm;

  @override
  State<_HoldNextButton> createState() => _HoldNextButtonState();
}

class _HoldNextButtonState extends State<_HoldNextButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  bool _fired = false;

  static const _holdDuration = Duration(milliseconds: 700);

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: _holdDuration);
    _ctrl.addStatusListener((status) {
      if (status == AnimationStatus.completed && !_fired) {
        _fired = true;
        widget.onConfirm();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails _) {
    if (!widget.enabled) return;
    _fired = false;
    _ctrl.forward(from: 0);
  }

  void _onTapUp(TapUpDetails _) => _ctrl.reverse();
  void _onCancel() => _ctrl.reverse();

  @override
  Widget build(BuildContext context) {
    final borderColor = widget.enabled
        ? NothingTheme.borderVisible
        : NothingTheme.borderSubtle;
    final labelColor = widget.enabled
        ? NothingTheme.textPrimary
        : NothingTheme.textDisabled;

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onCancel,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, child) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(100),
                border: Border.all(
                  color: _ctrl.value > 0 ? NothingTheme.accent : borderColor,
                  width: _ctrl.value > 0 ? 1.5 : 1,
                ),
              ),
              child: Stack(
                children: [
                  // fill — rises from bottom to top
                  Positioned.fill(
                    child: Align(
                      alignment: Alignment.bottomCenter,
                      child: FractionallySizedBox(
                        heightFactor: _ctrl.value,
                        child: Container(
                          color: NothingTheme.accent.withValues(alpha: 0.28),
                        ),
                      ),
                    ),
                  ),
                  // label
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(child: child),
                  ),
                ],
              ),
            ),
          );
        },
        child: Text(
          '[ NEXT ]',
          style: GoogleFonts.spaceMono(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: labelColor,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

class _WorkoutTimeline extends StatefulWidget {
  const _WorkoutTimeline({
    required this.exercises,
    required this.currentIndex,
    required this.splits,
    required this.isRoxZone,
  });
  final List<Exercise> exercises;
  final int currentIndex;
  final List<Duration> splits;
  final bool isRoxZone;

  @override
  State<_WorkoutTimeline> createState() => _WorkoutTimelineState();
}

class _WorkoutTimelineState extends State<_WorkoutTimeline> {
  final _scrollCtrl = ScrollController();

  static const _itemHeight = 36.0;

  @override
  void didUpdateWidget(_WorkoutTimeline old) {
    super.didUpdateWidget(old);
    if (old.currentIndex != widget.currentIndex ||
        old.isRoxZone != widget.isRoxZone) {
      _scrollToCurrentItem();
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrentItem());
  }

  void _scrollToCurrentItem() {
    if (!_scrollCtrl.hasClients) return;
    // Show 1 completed item above current (if any), then current + upcoming.
    final targetOffset =
        ((widget.currentIndex - 1).clamp(0, widget.exercises.length - 1)) *
            _itemHeight;
    final maxOffset = _scrollCtrl.position.maxScrollExtent;
    _scrollCtrl.animateTo(
      targetOffset.clamp(0.0, maxOffset),
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOut,
    );
  }

  @override
  void dispose() {
    _scrollCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      controller: _scrollCtrl,
      itemCount: widget.exercises.length,
      itemExtent: _itemHeight,
      padding: EdgeInsets.zero,
      itemBuilder: (context, i) {
        final ex = widget.exercises[i];
        // In Rox Zone: current exercise is "transitioning" (yellow dot, dimmed),
        // the next one is "up next" (highlighted).
        final isCompleted = widget.isRoxZone
            ? i < widget.currentIndex
            : i < widget.currentIndex;
        final isCurrent = !widget.isRoxZone && i == widget.currentIndex;
        final isTransitioning = widget.isRoxZone && i == widget.currentIndex;
        final isUpNext = i == widget.currentIndex + 1;
        final detail = ex.weightNote ?? ex.description;

        Color dotColor;
        Color nameColor;
        Widget? trailing;

        if (isCompleted) {
          dotColor = NothingTheme.textDisabled;
          nameColor = NothingTheme.textDisabled;
          trailing = i < widget.splits.length
              ? Text(
                  _fmt(widget.splits[i]),
                  style: NothingTheme.label(
                      fontSize: 10, color: NothingTheme.textDisabled),
                )
              : null;
        } else if (isTransitioning) {
          dotColor = NothingTheme.accent;
          nameColor = NothingTheme.textDisabled;
          trailing = i < widget.splits.length
              ? Text(
                  _fmt(widget.splits[i]),
                  style: NothingTheme.label(
                      fontSize: 10, color: NothingTheme.textDisabled),
                )
              : null;
        } else if (isCurrent) {
          dotColor = NothingTheme.accent;
          nameColor = NothingTheme.textDisplay;
          trailing = null;
        } else if (isUpNext) {
          dotColor = NothingTheme.textSecondary;
          nameColor = NothingTheme.textPrimary;
          trailing = detail.isNotEmpty
              ? Text(
                  detail,
                  style: NothingTheme.label(
                      fontSize: 10, color: NothingTheme.textSecondary),
                )
              : null;
        } else {
          dotColor = NothingTheme.borderVisible;
          nameColor = NothingTheme.textDisabled;
          trailing = detail.isNotEmpty
              ? Text(
                  detail,
                  style: NothingTheme.label(
                      fontSize: 10, color: NothingTheme.borderVisible),
                )
              : null;
        }

        return SizedBox(
          height: _itemHeight,
          child: Row(
            children: [
              // dot + connector
              SizedBox(
                width: 20,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (i > 0)
                      Container(
                        width: 1,
                        height: 10,
                        color: NothingTheme.borderSubtle,
                      ),
                    Container(
                      width: (isCurrent || isTransitioning) ? 8 : 5,
                      height: (isCurrent || isTransitioning) ? 8 : 5,
                      decoration: BoxDecoration(
                        color: dotColor,
                        shape: BoxShape.circle,
                      ),
                    ),
                    Container(
                      width: 1,
                      height: 10,
                      color: i < widget.exercises.length - 1
                          ? NothingTheme.borderSubtle
                          : Colors.transparent,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              // name
              Expanded(
                child: Text(
                  ex.name.toUpperCase(),
                  style: NothingTheme.label(
                    fontSize: isCurrent
                        ? 12
                        : isUpNext
                            ? 11
                            : 10,
                    color: nameColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              // trailing (time or detail)
              if (trailing != null) ...[
                const SizedBox(width: 8),
                trailing,
              ],
            ],
          ),
        );
      },
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

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../models/predefined_routines.dart';
import '../../models/routine.dart';
import '../../providers/target_provider.dart';
import '../../providers/timer_provider.dart';
import '../theme/nothing_theme.dart';
import 'active_workout_screen.dart';

/// Optional screen between routine picker and active workout.
/// Lets users configure target times and paces before starting.
class TargetSetupScreen extends ConsumerStatefulWidget {
  const TargetSetupScreen({super.key, required this.routine});
  final Routine routine;

  @override
  ConsumerState<TargetSetupScreen> createState() => _TargetSetupScreenState();
}

class _TargetSetupScreenState extends ConsumerState<TargetSetupScreen> {
  bool _showIndividual = false;

  @override
  void initState() {
    super.initState();
    // Clear any previous targets
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(targetProvider.notifier).clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    final target = ref.watch(targetProvider);
    final routine = widget.routine;
    final validationError = target.validate(routine);
    final computedTotal = target.computedTotalFromIndividuals(routine);

    return Scaffold(
      backgroundColor: NothingTheme.black,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Top bar ──────────────────────────────────────────────────
            _TopBar(
              routineName: routine.name,
              onBack: () => Navigator.of(context).pop(),
            ),
            const Divider(height: 1, color: NothingTheme.borderSubtle),

            // ── Content ──────────────────────────────────────────────────
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'SET TARGETS',
                      style: NothingTheme.label(
                          fontSize: 11, color: NothingTheme.textDisabled),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Optional — skip to start without targets.',
                      style: NothingTheme.body(
                          fontSize: 13, color: NothingTheme.textSecondary),
                    ),
                    const SizedBox(height: 24),

                    // ── Global target time ──────────────────────────────
                    _DurationField(
                      label: 'TOTAL TARGET TIME',
                      hint: 'HH : MM : SS',
                      value: target.globalTargetTime,
                      onChanged: (d) =>
                          ref.read(targetProvider.notifier).setGlobalTargetTime(d),
                    ),

                    if (computedTotal != null && target.globalTargetTime == null) ...[
                      const SizedBox(height: 4),
                      Text(
                        'Computed from segments: ${_fmtDuration(computedTotal)}',
                        style: NothingTheme.label(
                            fontSize: 10, color: NothingTheme.textSecondary),
                      ),
                    ],

                    const SizedBox(height: 20),

                    // ── Global run pace ─────────────────────────────────
                    _DurationField(
                      label: 'RUN PACE (ALL RUNS)',
                      hint: 'MM : SS  /KM',
                      value: target.globalRunPace,
                      showHours: false,
                      onChanged: (d) =>
                          ref.read(targetProvider.notifier).setGlobalRunPace(d),
                    ),

                    const SizedBox(height: 24),

                    // ── Individual targets toggle ───────────────────────
                    GestureDetector(
                      onTap: () => setState(() => _showIndividual = !_showIndividual),
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          color: NothingTheme.surface,
                          border: Border.all(color: NothingTheme.borderSubtle),
                        ),
                        child: Row(
                          children: [
                            Text(
                              'INDIVIDUAL SEGMENT TARGETS',
                              style: NothingTheme.label(
                                  fontSize: 10,
                                  color: NothingTheme.textSecondary),
                            ),
                            const Spacer(),
                            Icon(
                              _showIndividual
                                  ? Icons.keyboard_arrow_up
                                  : Icons.keyboard_arrow_down,
                              size: 18,
                              color: NothingTheme.textSecondary,
                            ),
                          ],
                        ),
                      ),
                    ),

                    if (_showIndividual) ...[
                      const SizedBox(height: 16),
                      ...List.generate(routine.exercises.length, (i) {
                        final exercise = routine.exercises[i];
                        final isRun =
                            PredefinedRoutines.isRunSegment(exercise);
                        return _SegmentTargetRow(
                          index: i,
                          name: exercise.name,
                          isRun: isRun,
                          exerciseTarget: target.exerciseTargets[i],
                          runPace: isRun ? target.runPaces[i] : null,
                          globalRunPace: target.globalRunPace,
                          onExerciseTargetChanged: (d) => ref
                              .read(targetProvider.notifier)
                              .setExerciseTarget(i, d),
                          onRunPaceChanged: isRun
                              ? (d) => ref
                                  .read(targetProvider.notifier)
                                  .setRunPace(i, d)
                              : null,
                        );
                      }),
                    ],

                    // ── Validation error ────────────────────────────────
                    if (validationError != null) ...[
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: NothingTheme.surface,
                          border: Border.all(color: NothingTheme.accent),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.warning_amber,
                                size: 16, color: NothingTheme.warning),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                validationError,
                                style: NothingTheme.label(
                                    fontSize: 10, color: NothingTheme.warning),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),

            // ── Bottom buttons ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 16),
              child: Column(
                children: [
                  _ActionButton(
                    label: target.isEmpty
                        ? '[ START WITHOUT TARGETS ]'
                        : '[ START WITH TARGETS ]',
                    primary: true,
                    onTap: validationError == null
                        ? () => _startWorkout(context)
                        : null,
                  ),
                  if (!target.isEmpty) ...[
                    const SizedBox(height: 8),
                    _ActionButton(
                      label: '[ CLEAR ALL ]',
                      primary: false,
                      onTap: () => ref.read(targetProvider.notifier).clear(),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _startWorkout(BuildContext context) {
    ref.read(timerProvider.notifier).startRoutine(widget.routine);
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => const ActiveWorkoutScreen()),
    );
  }

  static String _fmtDuration(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    if (d.inHours > 0) {
      return '${two(d.inHours)}:${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
    }
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

// ── Duration input field ────────────────────────────────────────────────────

class _DurationField extends StatefulWidget {
  const _DurationField({
    required this.label,
    required this.hint,
    required this.value,
    required this.onChanged,
    this.showHours = true,
  });
  final String label;
  final String hint;
  final Duration? value;
  final ValueChanged<Duration?> onChanged;
  final bool showHours;

  @override
  State<_DurationField> createState() => _DurationFieldState();
}

class _DurationFieldState extends State<_DurationField> {
  late TextEditingController _hoursCtrl;
  late TextEditingController _minsCtrl;
  late TextEditingController _secsCtrl;

  @override
  void initState() {
    super.initState();
    _hoursCtrl = TextEditingController(
      text: widget.value != null ? widget.value!.inHours.toString().padLeft(2, '0') : '',
    );
    _minsCtrl = TextEditingController(
      text: widget.value != null
          ? widget.value!.inMinutes.remainder(60).toString().padLeft(2, '0')
          : '',
    );
    _secsCtrl = TextEditingController(
      text: widget.value != null
          ? widget.value!.inSeconds.remainder(60).toString().padLeft(2, '0')
          : '',
    );
  }

  @override
  void didUpdateWidget(covariant _DurationField oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Sync controllers when value is cleared externally
    if (widget.value == null && oldWidget.value != null) {
      _hoursCtrl.text = '';
      _minsCtrl.text = '';
      _secsCtrl.text = '';
    }
  }

  @override
  void dispose() {
    _hoursCtrl.dispose();
    _minsCtrl.dispose();
    _secsCtrl.dispose();
    super.dispose();
  }

  void _onFieldChanged() {
    final h = int.tryParse(_hoursCtrl.text) ?? 0;
    final m = int.tryParse(_minsCtrl.text) ?? 0;
    final s = int.tryParse(_secsCtrl.text) ?? 0;

    if (h == 0 && m == 0 && s == 0 &&
        _hoursCtrl.text.isEmpty && _minsCtrl.text.isEmpty && _secsCtrl.text.isEmpty) {
      widget.onChanged(null);
    } else {
      widget.onChanged(Duration(hours: h, minutes: m, seconds: s));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          widget.label,
          style: NothingTheme.label(fontSize: 9, color: NothingTheme.textDisabled),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            if (widget.showHours) ...[
              _TimeBox(controller: _hoursCtrl, hint: 'HH', onChanged: _onFieldChanged),
              _separator(),
            ],
            _TimeBox(controller: _minsCtrl, hint: 'MM', onChanged: _onFieldChanged),
            _separator(),
            _TimeBox(controller: _secsCtrl, hint: 'SS', onChanged: _onFieldChanged),
          ],
        ),
      ],
    );
  }

  Widget _separator() => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 6),
        child: Text(
          ':',
          style: GoogleFonts.spaceMono(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: NothingTheme.textDisabled,
          ),
        ),
      );
}

class _TimeBox extends StatelessWidget {
  const _TimeBox({
    required this.controller,
    required this.hint,
    required this.onChanged,
  });
  final TextEditingController controller;
  final String hint;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 56,
      child: TextField(
        controller: controller,
        keyboardType: TextInputType.number,
        textAlign: TextAlign.center,
        maxLength: 2,
        onChanged: (_) => onChanged(),
        style: GoogleFonts.spaceMono(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: NothingTheme.textDisplay,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
        decoration: InputDecoration(
          counterText: '',
          hintText: hint,
          hintStyle: GoogleFonts.spaceMono(
            fontSize: 20,
            fontWeight: FontWeight.w400,
            color: NothingTheme.textDisabled,
          ),
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: NothingTheme.borderVisible),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: const BorderSide(color: NothingTheme.textDisplay),
          ),
          filled: true,
          fillColor: NothingTheme.surface,
        ),
      ),
    );
  }
}

// ── Segment target row ──────────────────────────────────────────────────────

class _SegmentTargetRow extends StatelessWidget {
  const _SegmentTargetRow({
    required this.index,
    required this.name,
    required this.isRun,
    required this.exerciseTarget,
    required this.runPace,
    required this.globalRunPace,
    required this.onExerciseTargetChanged,
    this.onRunPaceChanged,
  });
  final int index;
  final String name;
  final bool isRun;
  final Duration? exerciseTarget;
  final Duration? runPace;
  final Duration? globalRunPace;
  final ValueChanged<Duration?> onExerciseTargetChanged;
  final ValueChanged<Duration?>? onRunPaceChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: NothingTheme.surface,
        border: Border.all(
          color: isRun ? NothingTheme.accent.withValues(alpha: 0.3) : NothingTheme.borderSubtle,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 6,
                height: 6,
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isRun ? NothingTheme.accent : NothingTheme.borderVisible,
                ),
              ),
              Text(
                '${index + 1}. ${name.toUpperCase()}',
                style: NothingTheme.label(
                    fontSize: 10,
                    color: isRun ? NothingTheme.accent : NothingTheme.textPrimary),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Target time for this segment
          _DurationField(
            label: isRun ? 'TARGET TIME (OR SET PACE BELOW)' : 'TARGET TIME',
            hint: 'MM : SS',
            value: exerciseTarget,
            showHours: false,
            onChanged: onExerciseTargetChanged,
          ),

          // Run pace override (only for run segments)
          if (isRun && onRunPaceChanged != null) ...[
            const SizedBox(height: 10),
            _DurationField(
              label: 'PACE /KM${globalRunPace != null && runPace == null ? "  (USING GLOBAL: ${_fmtPace(globalRunPace!)})" : ""}',
              hint: 'MM : SS',
              value: runPace,
              showHours: false,
              onChanged: onRunPaceChanged!,
            ),
          ],
        ],
      ),
    );
  }

  static String _fmtPace(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}';
  }
}

// ── Shared sub-widgets ──────────────────────────────────────────────────────

class _TopBar extends StatelessWidget {
  const _TopBar({required this.routineName, required this.onBack});
  final String routineName;
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
          const Spacer(),
          const SizedBox(width: 40),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
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
          color: primary && enabled
              ? NothingTheme.textDisplay
              : Colors.transparent,
          borderRadius: BorderRadius.circular(100),
          border: primary && enabled
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
              color: primary && enabled
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

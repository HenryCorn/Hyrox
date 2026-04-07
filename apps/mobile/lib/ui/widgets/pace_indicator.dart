import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../providers/target_provider.dart';
import '../theme/nothing_theme.dart';

/// Compact pace indicator with color + text symbol for colorblind users.
///
/// Shows:
///   ahead  →  green  + "▲"
///   onPace →  white  + "●"
///   behind →  red    + "▼"
///   none   →  hidden
class PaceIndicator extends StatelessWidget {
  const PaceIndicator({
    super.key,
    required this.status,
    this.fontSize = 11,
    this.showLabel = true,
  });
  final PaceStatus status;
  final double fontSize;
  final bool showLabel;

  @override
  Widget build(BuildContext context) {
    if (status == PaceStatus.none) return const SizedBox.shrink();

    final (Color color, String symbol, String label) = switch (status) {
      PaceStatus.ahead => (NothingTheme.success, '▲', 'AHEAD'),
      PaceStatus.onPace => (NothingTheme.textDisplay, '●', 'ON PACE'),
      PaceStatus.behind => (NothingTheme.accent, '▼', 'BEHIND'),
      PaceStatus.none => (Colors.transparent, '', ''),
    };

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          symbol,
          style: TextStyle(fontSize: fontSize, color: color),
        ),
        if (showLabel) ...[
          const SizedBox(width: 4),
          Text(
            label,
            style: NothingTheme.label(fontSize: fontSize - 2, color: color),
          ),
        ],
      ],
    );
  }
}

/// Color for the hero timer based on pace status.
Color paceColor(PaceStatus status, {required bool isRun}) {
  return switch (status) {
    PaceStatus.ahead => NothingTheme.success,
    PaceStatus.onPace => isRun ? NothingTheme.accent : NothingTheme.textDisplay,
    PaceStatus.behind => NothingTheme.accent,
    PaceStatus.none => isRun ? NothingTheme.accent : NothingTheme.textDisplay,
  };
}

/// Inline delta label showing +/- time vs target. E.g. "+0:12" or "-1:05".
class PaceDelta extends StatelessWidget {
  const PaceDelta({
    super.key,
    required this.elapsed,
    required this.target,
  });
  final Duration elapsed;
  final Duration? target;

  @override
  Widget build(BuildContext context) {
    if (target == null || target == Duration.zero) return const SizedBox.shrink();

    final diff = elapsed - target!;
    final ahead = diff.isNegative;
    final absDiff = diff.abs();
    final m = absDiff.inMinutes.remainder(60);
    final s = absDiff.inSeconds.remainder(60);
    final sign = ahead ? '-' : '+';
    final color = ahead ? NothingTheme.success : NothingTheme.accent;

    return Text(
      '$sign${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}',
      style: GoogleFonts.spaceMono(
        fontSize: 13,
        fontWeight: FontWeight.w700,
        color: color,
        fontFeatures: const [FontFeature.tabularFigures()],
      ),
    );
  }
}

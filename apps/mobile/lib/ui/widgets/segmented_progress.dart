import 'package:flutter/material.dart';
import '../theme/nothing_theme.dart';

/// Nothing design–style segmented progress bar.
///
/// Renders [totalSegments] rectangular blocks separated by 2 px gaps.
/// Completed segments are dimmed, the current is bright white (or accent
/// red when [accentCurrent] is true), and future segments are dark.
class SegmentedProgress extends StatelessWidget {
  const SegmentedProgress({
    super.key,
    required this.totalSegments,
    required this.completedSegments,
    required this.currentSegment,
    this.accentCurrent = false,
    this.height = 6.0,
  });

  final int totalSegments;
  final int completedSegments;
  final int currentSegment;

  /// When true the current-segment block uses [NothingTheme.accent] (Hyrox yellow),
  /// intended for run segments.
  final bool accentCurrent;
  final double height;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (totalSegments <= 0) return const SizedBox();
        const gap = 2.0;
        final totalGaps = (totalSegments - 1) * gap;
        final blockWidth =
            (constraints.maxWidth - totalGaps) / totalSegments;

        return Row(
          children: List.generate(totalSegments, (i) {
            final Color color;
            if (i < completedSegments) {
              color = NothingTheme.borderVisible; // done — dimmed
            } else if (i == currentSegment) {
              color = accentCurrent
                  ? NothingTheme.accent // run segment — Hyrox yellow
                  : NothingTheme.textDisplay; // station — white
            } else {
              color = NothingTheme.borderSubtle; // future — very dark
            }

            return Container(
              width: blockWidth.clamp(2.0, double.infinity),
              height: height,
              margin: EdgeInsets.only(right: i < totalSegments - 1 ? gap : 0),
              color: color,
            );
          }),
        );
      },
    );
  }
}

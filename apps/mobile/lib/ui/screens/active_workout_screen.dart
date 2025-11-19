import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../../providers/timer_state.dart';
import '../theme/hyrox_theme.dart';
import 'summary_screen.dart';

class ActiveWorkoutScreen extends ConsumerWidget {
  const ActiveWorkoutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final routine = timerState.activeRoutine;

    // Handle finish state navigation
    ref.listen(timerProvider, (previous, next) {
      if (next.status == TimerStatus.finished) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => const SummaryScreen()),
        );
      }
    });

    if (routine == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final currentExercise = routine.exercises[timerState.currentExerciseIndex];
    final isPaused = timerState.status == TimerStatus.paused;

    return Scaffold(
      appBar: AppBar(
        title: Text(routine.name.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            // Confirm exit? For now just pop and reset.
            ref.read(timerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Total Time (Small)
            Text(
              'TOTAL TIME: ${_formatDuration(timerState.totalElapsed)}',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            const Spacer(),
            
            // Current Exercise Timer (Big)
            Text(
              _formatDuration(timerState.currentExerciseElapsed),
              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                fontSize: 80,
                fontFeatures: [const FontFeature.tabularFigures()],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            
            // Exercise Info
            Text(
              currentExercise.name.toUpperCase(),
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: HyroxTheme.yellow,
              ),
              textAlign: TextAlign.center,
            ),
            if (currentExercise.weight != null) ...[
              const SizedBox(height: 16),
              Text(
                '${currentExercise.weight} kg',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              if (currentExercise.weightNote != null)
                Text(
                  currentExercise.weightNote!,
                  style: Theme.of(context).textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
            ],
            if (currentExercise.description.isNotEmpty) ...[
              const SizedBox(height: 16),
              Text(
                currentExercise.description,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
            ],
            
            const Spacer(),
            
            // Controls
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isPaused ? HyroxTheme.yellow : HyroxTheme.darkGrey,
                      foregroundColor: isPaused ? HyroxTheme.black : HyroxTheme.white,
                      side: BorderSide(color: HyroxTheme.yellow),
                    ),
                    onPressed: () {
                      if (isPaused || timerState.status == TimerStatus.initial) {
                        ref.read(timerProvider.notifier).resume();
                      } else {
                        ref.read(timerProvider.notifier).pause();
                      }
                    },
                    child: Text(isPaused || timerState.status == TimerStatus.initial ? 'RESUME' : 'PAUSE'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      ref.read(timerProvider.notifier).nextExercise();
                    },
                    child: const Text('NEXT'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0 ? '$hours:$minutes:$seconds' : '$minutes:$seconds';
  }
}


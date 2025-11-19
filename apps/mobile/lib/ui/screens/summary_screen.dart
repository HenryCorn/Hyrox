import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../theme/hyrox_theme.dart';

class SummaryScreen extends ConsumerWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(timerProvider);
    final routine = timerState.activeRoutine;

    if (routine == null) {
      return const Scaffold(body: Center(child: Text('No workout data')));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('SUMMARY'),
        automaticallyImplyLeading: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'WORKOUT COMPLETE',
              style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: HyroxTheme.yellow,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Text(
              'TOTAL TIME',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
            Text(
              _formatDuration(timerState.totalElapsed),
              style: Theme.of(context).textTheme.displayLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            Expanded(
              child: ListView.separated(
                itemCount: routine.exercises.length,
                separatorBuilder: (context, index) => const Divider(color: HyroxTheme.darkGrey),
                itemBuilder: (context, index) {
                  final exercise = routine.exercises[index];
                  // Note: We need to store splits in TimerState to show them here.
                  // Currently TimerState only has currentExerciseElapsed.
                  // We should update TimerState to hold a list of splits.
                  // For now, we'll just list exercises.
                  return ListTile(
                    title: Text(exercise.name, style: const TextStyle(color: HyroxTheme.white)),
                    // trailing: Text(_formatDuration(split)), 
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: () {
                ref.read(timerProvider.notifier).reset();
                Navigator.of(context).popUntil((route) => route.isFirst);
              },
              child: const Text('DONE'),
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

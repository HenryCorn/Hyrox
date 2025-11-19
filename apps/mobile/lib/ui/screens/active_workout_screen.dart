import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../../providers/timer_state.dart';
import '../theme/hyrox_theme.dart';
import '../widgets/glass_card.dart';
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
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text(routine.name.toUpperCase()),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            ref.read(timerProvider.notifier).reset();
            Navigator.of(context).pop();
          },
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: HyroxTheme.darkGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: constraints.maxHeight - 32,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Total Time (Small) - Compact
                      Text(
                        'TOTAL TIME',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: HyroxTheme.lightGrey,
                              letterSpacing: 1.2,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDuration(timerState.totalElapsed),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                              color: HyroxTheme.yellow,
                              fontWeight: FontWeight.bold,
                            ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Current Exercise Timer (Big) in Glass Card
                      GlassCard(
                        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                _formatDuration(timerState.currentExerciseElapsed),
                                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                      fontSize: 64,
                                      fontWeight: FontWeight.w900,
                                      fontFeatures: [const FontFeature.tabularFigures()],
                                      color: HyroxTheme.white,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            const SizedBox(height: 16),
                            
                            // Show ROX ZONE or Exercise Info
                            if (timerState.isInRoxZone) ...[
                              // ROX ZONE UI
                              Icon(
                                Icons.sports_score,
                                size: 48,
                                color: HyroxTheme.yellow,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'ROX ZONE',
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontSize: 28,
                                      fontWeight: FontWeight.w900,
                                      color: HyroxTheme.yellow,
                                      letterSpacing: 2.0,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Get Ready for Next Exercise',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: HyroxTheme.lightGrey,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 12),
                              // Show next exercise name
                              if (timerState.currentExerciseIndex + 1 < routine.exercises.length)
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: HyroxTheme.yellow.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: HyroxTheme.yellow.withOpacity(0.3),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    routine.exercises[timerState.currentExerciseIndex + 1].name.toUpperCase(),
                                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          color: HyroxTheme.yellow,
                                          fontWeight: FontWeight.bold,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                            ] else ...[
                              // Exercise Info
                              Text(
                                currentExercise.name.toUpperCase(),
                                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                      color: HyroxTheme.yellow,
                                      letterSpacing: 1.2,
                                    ),
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              if (currentExercise.weight != null) ...[
                                const SizedBox(height: 12),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    gradient: HyroxTheme.accentGradient,
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  child: Text(
                                    '${currentExercise.weight} kg',
                                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                          color: HyroxTheme.black,
                                          fontWeight: FontWeight.bold,
                                        ),
                                  ),
                                ),
                                if (currentExercise.weightNote != null)
                                  Padding(
                                    padding: const EdgeInsets.only(top: 6),
                                    child: Text(
                                      currentExercise.weightNote!,
                                      style: Theme.of(context).textTheme.bodySmall,
                                      textAlign: TextAlign.center,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                              ],
                              if (currentExercise.description.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Text(
                                  currentExercise.description,
                                  style: Theme.of(context).textTheme.bodySmall,
                                  textAlign: TextAlign.center,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ],
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Next/Prev Exercises in Glass Card - Hide during Rox Zone
                      if (!timerState.isInRoxZone)
                        GlassCard(
                          padding: const EdgeInsets.all(12),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous
                              if (timerState.currentExerciseIndex > 0)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'PREVIOUS',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: HyroxTheme.lightGrey.withOpacity(0.6),
                                              letterSpacing: 1.0,
                                              fontSize: 10,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        routine.exercises[timerState.currentExerciseIndex - 1].name.toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: HyroxTheme.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const SizedBox(width: 48),

                              const SizedBox(width: 12),

                              // Next
                              if (timerState.currentExerciseIndex < routine.exercises.length - 1)
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        'UP NEXT',
                                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                                              color: HyroxTheme.lightGrey.withOpacity(0.6),
                                              letterSpacing: 1.0,
                                              fontSize: 10,
                                            ),
                                        textAlign: TextAlign.end,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        routine.exercises[timerState.currentExerciseIndex + 1].name.toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: HyroxTheme.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 12,
                                            ),
                                        textAlign: TextAlign.end,
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                )
                              else
                                const SizedBox(width: 48),
                            ],
                          ),
                        ),
                      
                      const SizedBox(height: 24),
                      
                      // Controls - Fixed height for stability
                      SizedBox(
                        height: 56,
                        child: Row(
                          children: [
                            Expanded(
                              child: GlassCard(
                                padding: EdgeInsets.zero,
                                backgroundColor: (isPaused || timerState.status == TimerStatus.initial)
                                    ? HyroxTheme.yellow.withOpacity(0.2)
                                    : Colors.white.withOpacity(0.05),
                                child: InkWell(
                                  onTap: () {
                                    if (isPaused || timerState.status == TimerStatus.initial) {
                                      ref.read(timerProvider.notifier).resume();
                                    } else {
                                      ref.read(timerProvider.notifier).pause();
                                    }
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Text(
                                      timerState.status == TimerStatus.initial 
                                          ? 'START' 
                                          : (isPaused ? 'RESUME' : 'PAUSE'),
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: (isPaused || timerState.status == TimerStatus.initial)
                                                ? HyroxTheme.yellow
                                                : HyroxTheme.white,
                                            letterSpacing: 1.5,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: GlassCard(
                                padding: EdgeInsets.zero,
                                child: InkWell(
                                  onTap: () {
                                    ref.read(timerProvider.notifier).nextExercise();
                                  },
                                  borderRadius: BorderRadius.circular(16),
                                  child: Center(
                                    child: Text(
                                      'NEXT',
                                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color: HyroxTheme.white,
                                            letterSpacing: 1.5,
                                          ),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
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

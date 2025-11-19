import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../theme/hyrox_theme.dart';
import '../widgets/glass_card.dart';

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
      body: Container(
        decoration: const BoxDecoration(
          gradient: HyroxTheme.darkGradient,
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header section - Fixed
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        // Completion Icon - Smaller
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: HyroxTheme.accentGradient,
                          ),
                          child: const Icon(
                            Icons.check_circle_outline,
                            size: 48,
                            color: HyroxTheme.black,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'WORKOUT COMPLETE',
                          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: HyroxTheme.yellow,
                                letterSpacing: 1.5,
                              ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        
                        // Total Time Glass Card - More Compact
                        GlassCard(
                          padding: const EdgeInsets.all(20),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'TOTAL TIME',
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      letterSpacing: 1.5,
                                      color: HyroxTheme.lightGrey,
                                    ),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 6),
                              FittedBox(
                                fit: BoxFit.scaleDown,
                                child: Text(
                                  _formatDuration(timerState.totalElapsed),
                                  style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                        fontSize: 48,
                                        fontWeight: FontWeight.w900,
                                        color: HyroxTheme.white,
                                      ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ],
                          ),
                        ),
                        
                        const SizedBox(height: 16),
                        
                        Text(
                          'SEGMENTS',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                letterSpacing: 1.5,
                                color: HyroxTheme.lightGrey,
                              ),
                        ),
                      ],
                    ),
                  ),
                  
                  // Exercise List - Scrollable
                  Expanded(
                    child: ListView.separated(
                      padding: const EdgeInsets.symmetric(horizontal: 16.0),
                      itemCount: routine.exercises.length,
                      separatorBuilder: (context, index) => const SizedBox(height: 8),
                      itemBuilder: (context, index) {
                        final exercise = routine.exercises[index];
                        // Get split time if available
                        final splitTime = index < timerState.splits.length 
                            ? timerState.splits[index] 
                            : null;
                        
                        return GlassCard(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                          child: Row(
                            children: [
                              Container(
                                width: 28,
                                height: 28,
                                decoration: BoxDecoration(
                                  color: HyroxTheme.yellow.withOpacity(0.2),
                                  shape: BoxShape.circle,
                                ),
                                child: Center(
                                  child: Text(
                                    '${index + 1}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: HyroxTheme.yellow,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12,
                                        ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  exercise.name,
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: HyroxTheme.white,
                                        fontSize: 14,
                                      ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                              ),
                              // Display split time if available
                              if (splitTime != null)
                                Text(
                                  _formatDuration(splitTime),
                                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                        color: HyroxTheme.yellow,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 14,
                                      ),
                                ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                  
                  // Button - Fixed at bottom
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: SizedBox(
                      height: 56,
                      child: GlassCard(
                        padding: EdgeInsets.zero,
                        backgroundColor: HyroxTheme.yellow.withOpacity(0.2),
                        child: InkWell(
                          onTap: () {
                            ref.read(timerProvider.notifier).reset();
                            Navigator.of(context).popUntil((route) => route.isFirst);
                          },
                          borderRadius: BorderRadius.circular(16),
                          child: Center(
                            child: Text(
                              'DONE',
                              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: HyroxTheme.yellow,
                                    letterSpacing: 1.5,
                                  ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
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

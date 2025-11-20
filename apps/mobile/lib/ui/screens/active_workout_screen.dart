import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/timer_provider.dart';
import '../../providers/timer_state.dart';
import '../theme/hyrox_theme.dart';
import '../../utils/exercise_icons.dart';
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
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: HyroxTheme.yellow),
                    onPressed: () {
                      ref.read(timerProvider.notifier).reset();
                      Navigator.of(context).pop();
                    },
                  ),
                  Expanded(
                    child: Text(
                      routine.name.toUpperCase(),
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: HyroxTheme.yellow,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.2,
                          ),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onPressed: () {},
                  ),
                ],
              ),
              
              const SizedBox(height: 20),
              
              // Main Timer Card with Yellow Glow
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(24),
                    gradient: LinearGradient(
                      colors: [
                        HyroxTheme.yellow.withOpacity(0.3),
                        HyroxTheme.yellow.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: HyroxTheme.yellow.withOpacity(0.3),
                        blurRadius: 30,
                        spreadRadius: 0,
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(2),
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFF1A1A1A),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    padding: const EdgeInsets.all(20),
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          child: ConstrainedBox(
                            constraints: BoxConstraints(
                              minHeight: constraints.maxHeight,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Routine name label - always visible
                                Text(
                                  routine.name,
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: Colors.grey.shade600,
                                        fontSize: 11,
                                      ),
                                  textAlign: TextAlign.center,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                
                                // Big Timer
                                FittedBox(
                                  fit: BoxFit.scaleDown,
                                  child: Text(
                                    _formatDuration(timerState.currentExerciseElapsed),
                                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                          fontSize: 64,
                                          fontWeight: FontWeight.w900,
                                          color: HyroxTheme.yellow,
                                          fontFeatures: [const FontFeature.tabularFigures()],
                                          shadows: [
                                            Shadow(
                                              color: HyroxTheme.yellow.withOpacity(0.5),
                                              blurRadius: 20,
                                            ),
                                          ],
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                                
                                const SizedBox(height: 20),
                                
                                // Show ROX ZONE or Exercise Info
                                if (timerState.isInRoxZone) ...[
                                  // ROX ZONE UI
                                  Icon(
                                    Icons.sports_score,
                                    size: 36,
                                    color: HyroxTheme.yellow.withOpacity(0.8),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    'ROX ZONE',
                                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                                          fontSize: 22,
                                          fontWeight: FontWeight.w900,
                                          color: HyroxTheme.yellow,
                                          letterSpacing: 2.0,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'Get Ready',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: Colors.grey.shade600,
                                          fontSize: 12,
                                        ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: 12),
                                  // Next exercise
                                  if (timerState.currentExerciseIndex + 1 < routine.exercises.length)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        color: HyroxTheme.yellow.withOpacity(0.1),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: HyroxTheme.yellow.withOpacity(0.3),
                                          width: 1,
                                        ),
                                      ),
                                      child: Text(
                                        routine.exercises[timerState.currentExerciseIndex + 1].name.toUpperCase(),
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: HyroxTheme.yellow,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 11,
                                            ),
                                        textAlign: TextAlign.center,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                ] else ...[
                                  // Exercise Icon
                                  Container(
                                    padding: const EdgeInsets.all(14),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          HyroxTheme.yellow.withOpacity(0.2),
                                          HyroxTheme.yellow.withOpacity(0.05),
                                        ],
                                      ),
                                      shape: BoxShape.circle,
                                    ),
                                    child: Icon(
                                      ExerciseIcons.getIconForExercise(currentExercise),
                                      size: 32,
                                      color: HyroxTheme.yellow,
                                    ),
                                  ),
                                  const SizedBox(height: 12),
                                  
                                  // Exercise Info
                                  Text(
                                    currentExercise.name.toUpperCase(),
                                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.white,
                                          letterSpacing: 0.8,
                                        ),
                                    textAlign: TextAlign.center,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  if (currentExercise.weight != null) ...[
                                    const SizedBox(height: 10),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                      decoration: BoxDecoration(
                                        gradient: HyroxTheme.accentGradient,
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      child: Text(
                                        '${currentExercise.weight} kg',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: HyroxTheme.black,
                                              fontWeight: FontWeight.bold,
                                              fontSize: 12,
                                            ),
                                      ),
                                    ),
                                  ],
                                  if (currentExercise.description.isNotEmpty) ...[
                                    const SizedBox(height: 8),
                                    Text(
                                      currentExercise.description,
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.grey.shade600,
                                            fontSize: 11,
                                          ),
                                      textAlign: TextAlign.center,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ],
                                
                                const SizedBox(height: 16),
                                
                                // Stat Cards Row (like reference image)
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        'TOTAL TIME',
                                        _formatDuration(timerState.totalElapsed),
                                        Icons.timer_outlined,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildStatCard(
                                        context,
                                        'SEGMENTS',
                                        '${timerState.currentExerciseIndex + (timerState.isInRoxZone ? 1 : 0)}/${routine.exercises.length}',
                                        Icons.list_alt,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 20),
              
              // Control Buttons
              Row(
                children: [
                  Expanded(
                    child: _buildControlButton(
                      context,
                      text: timerState.status == TimerStatus.initial 
                          ? 'START' 
                          : (isPaused ? 'RESUME' : 'PAUSE'),
                      isYellow: isPaused || timerState.status == TimerStatus.initial,
                      onTap: () {
                        if (isPaused || timerState.status == TimerStatus.initial) {
                          ref.read(timerProvider.notifier).resume();
                        } else {
                          ref.read(timerProvider.notifier).pause();
                        }
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildControlButton(
                      context,
                      text: 'NEXT',
                      isYellow: false,
                      onTap: () {
                        ref.read(timerProvider.notifier).nextExercise();
                      },
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade900,
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: HyroxTheme.yellow, size: 16),
              const SizedBox(width: 6),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.grey.shade600,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.0,
                    ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: HyroxTheme.yellow,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton(BuildContext context, {
    required String text,
    required bool isYellow,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: isYellow ? HyroxTheme.yellow : const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(16),
          border: isYellow ? null : Border.all(
            color: Colors.grey.shade800,
            width: 1,
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: isYellow ? Colors.black : Colors.white,
                  letterSpacing: 1.5,
                ),
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
